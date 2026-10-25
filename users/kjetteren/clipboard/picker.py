"""Clipboard history picker: cliphist entries in a rofi window styled like caelestia.

  Enter               copy the entry back to the clipboard
  Shift+Delete        remove the entry from the history
  Ctrl+Shift+Delete   clear the whole history (asks first)
  Esc                 close

The key hints in the footer are clickable too. Colours follow the current
caelestia scheme. Starting the picker while it is open closes it, so one key
both opens and dismisses it.
"""

import fcntl
import hashlib
import io
import json
import os
import re
import signal
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

# rofi exit codes: 0 = entry accepted, 10 = kb-custom-1, 11 = kb-custom-2.
# Everything else (1 = Esc, terminated by a second press, ...) means "dismissed".
ACCEPT, DELETE, WIPE = 0, 10, 11

ROFI_FLAGS = [
    "-no-config",  # only this theme and these flags, not ~/.config/rofi
    "-replace",  # take over from a rofi that is somehow still open
    "-disable-history",  # don't keep what was searched for in ~/.cache
    "-dmenu",
    "-i",  # case-insensitive search
    "-format",
    "i",  # hand back the row index, so no ids have to be shown
    "-kb-delete-entry",
    "",  # Shift+Delete is bound to "delete entry" by default
    "-kb-custom-1",
    "Shift+Delete",
    "-kb-custom-2",
    "Control+Shift+Delete",
]
# Enter on text that matches nothing must not invent an entry. (-only-match would
# also do that, but it makes Esc stop working; -no-custom quits at once on an
# empty list, so the empty-history prompt goes without it.)
NO_CUSTOM = "-no-custom"
# Theme overrides for the two small dialogs
CONFIRM_LAYOUT = "mainbox { children: [ message, listview ]; } listview { lines: 2; }"
EMPTY_LAYOUT = (
    "mainbox { children: [ inputbar ]; }"
    ' inputbar { children: [ textbox-search-icon, entry ]; } entry { placeholder: "Clipboard history is empty"; }'
)

# Theme variable -> caelestia colour role
COLOUR_ROLES = {
    "surface": "surface",
    "surface-container": "surfaceContainer",
    "surface-container-high": "surfaceContainerHigh",
    "on-surface": "onSurface",
    "on-surface-variant": "onSurfaceVariant",
    "outline": "outline",
    "outline-variant": "outlineVariant",
    "primary": "primary",
}
HEX_COLOUR = re.compile(r"[0-9a-fA-F]{6}")

# cliphist describes images as "[[ binary data 1.2 MiB png 1920x1080 ]]"
IMAGE = re.compile(r"\[\[ binary data (?P<size>.+?) (?P<fmt>\w+) (?P<w>\d+)x(?P<h>\d+) \]\]")
# The <meta …><img src=…> HTML that Chromium puts next to a copied image
HTML_IMAGE_WRAPPER = re.compile(r"<meta http-equiv=")
CONTROL_CHARS = re.compile(r"[\x00-\x1f\x7f]")

THUMB_SIZE = 128  # px; drawn at 28 px in the list
MAX_PIXELS = 40_000_000  # don't try to thumbnail absurdly large images

THEME = os.environ.get("CLIPBOARD_PICKER_THEME", str(Path(__file__).with_name("picker.rasi")))
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}")
CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "clipboard-picker"
THUMB_DIR = CACHE_DIR / "thumbnails"


class Entry:
    def __init__(self, entry_id: str, preview: str):
        self.id = entry_id
        self.preview = preview
        self.image = IMAGE.fullmatch(preview)

    @property
    def label(self) -> str:
        if self.image:
            m = self.image
            return f"Image · {m['w']}×{m['h']} · {m['fmt'].upper()} · {m['size']}"
        return CONTROL_CHARS.sub(" ", self.preview) or " "

    @property
    def mime(self) -> str | None:
        return f"image/{self.image['fmt']}" if self.image else None

    @property
    def thumbnail(self) -> Path:
        # ids restart after a wipe, so key the cache on the preview text as well
        digest = hashlib.sha1(self.preview.encode()).hexdigest()[:12]
        return THUMB_DIR / f"{self.id}-{digest}.png"


def cliphist(*args: str, data: bytes | None = None) -> bytes:
    return subprocess.run(["cliphist", *args], input=data, capture_output=True, check=True).stdout


def history() -> list[Entry]:
    entries = []
    for line in cliphist("list").decode("utf-8", "replace").splitlines():
        entry_id, sep, preview = line.partition("\t")
        if sep and entry_id.isdigit() and not HTML_IMAGE_WRAPPER.match(preview):
            entries.append(Entry(entry_id, preview))
    return entries


def make_thumbnail(entry: Entry) -> None:
    path = entry.thumbnail
    if int(entry.image["w"]) * int(entry.image["h"]) > MAX_PIXELS:
        return
    try:
        from PIL import Image

        with Image.open(io.BytesIO(cliphist("decode", entry.id))) as image:
            image.thumbnail((THUMB_SIZE, THUMB_SIZE))
            THUMB_DIR.mkdir(mode=0o700, parents=True, exist_ok=True)  # private, like cliphist's db
            tmp = path.with_suffix(f".{os.getpid()}.tmp")
            image.convert("RGBA").save(tmp, "PNG")
            tmp.replace(path)
    except Exception as err:  # a broken image shouldn't take the picker down
        print(f"clipboard-picker: no thumbnail for entry {entry.id}: {err}", file=sys.stderr)


def refresh_thumbnails(entries: list[Entry]) -> None:
    images = [e for e in entries if e.image]
    keep = {e.thumbnail.name for e in images}
    for path in THUMB_DIR.glob("*"):
        if path.name not in keep:
            path.unlink(missing_ok=True)
    missing = [e for e in images if not e.thumbnail.exists()]
    if missing:  # decoding big screenshots is the slow part; Pillow releases the GIL
        with ThreadPoolExecutor() as pool:
            list(pool.map(make_thumbnail, missing))


def menu_line(entry: Entry) -> str:
    line = entry.label
    if entry.image and entry.thumbnail.exists():
        line += f"\0icon\x1f{entry.thumbnail}"
    return line


def scheme_colours() -> str:
    """Theme overrides with the current caelestia colours (the theme has defaults)."""
    try:
        colours = json.loads((STATE_DIR / "caelestia/scheme.json").read_text())["colours"]
    except (OSError, ValueError, KeyError, TypeError):
        return ""
    picked = {
        name: colours[role]
        for name, role in COLOUR_ROLES.items()
        if isinstance(colours.get(role), str) and HEX_COLOUR.fullmatch(colours[role])
    }
    overrides = " ".join(f"{name}: #{value};" for name, value in picked.items())
    if "on-surface" in picked:  # caelestia's launcher highlights the row with on-surface at ~8%
        overrides += f" selected: #{picked['on-surface']}1a;"
    theme = f"* {{ {overrides} }}"
    if "primary" in picked:  # highlight can't take a variable
        theme += f" element-text {{ highlight: bold #{picked['primary']}; }}"
    return theme


class Rofi:
    proc: subprocess.Popen | None = None

    def __init__(self):
        self.colours = scheme_colours()

    def run(self, lines: list[str], *flags: str, layout: str = "") -> tuple[int, int | None]:
        theme = f"{self.colours} {layout}".strip()
        with subprocess.Popen(
            ["rofi", *ROFI_FLAGS, "-theme", THEME, *(["-theme-str", theme] if theme else []), *flags],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        ) as self.proc:
            out, err = self.proc.communicate("".join(line + "\n" for line in lines))
        rc, self.proc = self.proc.returncode, None
        if rc not in (ACCEPT, DELETE, WIPE) and ("ERROR" in err or "Failed" in err):
            notify("rofi failed", err.strip())
        out = out.strip()
        return rc, int(out) if out.isdigit() and int(out) < len(lines) else None

    def close(self, *_) -> None:
        if self.proc:
            self.proc.terminate()
        raise SystemExit(0)


def notify(summary: str, body: str = "") -> None:
    subprocess.run(
        ["notify-send", "--app-name=Clipboard", "--icon=edit-paste", summary, body],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )


def copy(entry: Entry) -> None:
    data = cliphist("decode", entry.id)
    mime = entry.mime
    if mime is None:
        try:
            data.decode("utf-8")
            # Explicit type: wl-copy would otherwise guess with xdg-mime and,
            # say, offer copied HTML *source* as text/html.
            mime = "text/plain;charset=utf-8"
        except UnicodeDecodeError:
            pass  # unknown binary: let wl-copy infer the type
    subprocess.run(
        ["wl-copy", *(["--type", mime] if mime else [])],
        input=data,
        stdout=subprocess.DEVNULL,  # wl-copy forks a server that keeps these open
        stderr=subprocess.DEVNULL,
        check=True,
    )


def confirm_wipe(rofi: Rofi, count: int) -> bool:
    rc, index = rofi.run(
        ["No, keep it", f"Yes, delete all {count} entries"],
        NO_CUSTOM,
        "-mesg",
        "Clear the whole clipboard history?",
        layout=CONFIRM_LAYOUT,
    )
    return rc == ACCEPT and index == 1


def pick(rofi: Rofi) -> None:
    select = 0
    while True:
        entries = history()
        refresh_thumbnails(entries)
        if not entries:
            rofi.run([], layout=EMPTY_LAYOUT)
            return

        rc, index = rofi.run(
            [menu_line(e) for e in entries],
            NO_CUSTOM,
            "-show-icons",
            "-selected-row",
            str(min(select, len(entries) - 1)),
        )
        if rc == WIPE:
            if confirm_wipe(rofi, len(entries)):
                cliphist("wipe")
                refresh_thumbnails([])
            return
        if index is None:  # dismissed, or nothing selected
            return
        if rc == ACCEPT:
            copy(entries[index])
            return
        if rc != DELETE:
            return
        cliphist("delete", data=f"{entries[index].id}\n".encode())
        select = index  # the next entry slides into the deleted one's place


def main() -> int:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    lock_fd = os.open(RUNTIME_DIR / "clipboard-picker.lock", os.O_RDWR | os.O_CREAT, 0o600)
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:  # already open: close it instead
        pid = os.pread(lock_fd, 16, 0).decode().strip()
        try:
            # only signal it if that pid still is a picker (pids get reused)
            if pid.isdigit() and "picker.py" in Path(f"/proc/{pid}/cmdline").read_text():
                os.kill(int(pid), signal.SIGTERM)
        except (FileNotFoundError, ProcessLookupError):
            pass
        return 0
    os.ftruncate(lock_fd, 0)
    os.pwrite(lock_fd, str(os.getpid()).encode(), 0)

    rofi = Rofi()
    signal.signal(signal.SIGTERM, rofi.close)
    try:
        pick(rofi)
    except subprocess.CalledProcessError as err:
        notify(f"{err.cmd[0]} failed", (err.stderr or b"").decode(errors="replace").strip())
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
