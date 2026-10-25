{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  wlroots = pkgs.wlroots_0_19;
  home = config.users.users.kjetteren.home;

  cage-waydroid = pkgs.stdenv.mkDerivation {
    pname = "cage-waydroid";
    version = "0.2.0-unstable-${builtins.substring 0 8 inputs.cage-waydroid.lastModifiedDate}";
    src = inputs.cage-waydroid;

    strictDeps = true;
    depsBuildBuild = [ pkgs.pkg-config ];
    nativeBuildInputs = wlroots.nativeBuildInputs;
    buildInputs = wlroots.buildInputs ++ wlroots.propagatedBuildInputs;

    # Same wlroots settings as the fork's own release build (no DRM backend);
    # Waydroid is Wayland-native, so XWayland is left out.
    mesonFlags = [
      (lib.mesonOption "werror" "false")
      (lib.mesonOption "wlroots:werror" "false")
      (lib.mesonOption "wlroots:backends" "libinput,x11")
      (lib.mesonEnable "wlroots:xwayland" false)
      (lib.mesonBool "wlroots:examples" false)
      (lib.mesonEnable "man-pages" false)
    ];

    # The fork never detaches its pointer-constraints listener, so wlroots aborts
    # cage when it shuts down.
    postPatch = ''
      substituteInPlace cage.c --replace-fail \
        'wl_list_remove(&server.output_layout_change.link);' \
        'wl_list_remove(&server.output_layout_change.link);
      	wl_list_remove(&server.pointer_constraint.link);'
    '';

    # Avoid clashing with nixpkgs' upstream cage.
    postInstall = ''
      mv $out/bin/cage $out/bin/cage-waydroid
    '';

    meta = {
      description = "Cage fork used by waydroid-helper's Key Mapper";
      homepage = "https://github.com/waydroid-helper/cage";
      license = lib.licenses.mit;
      mainProgram = "cage-waydroid";
      platforms = lib.platforms.linux;
    };
  };

  # Starts only waydroid-helper's Key Mapper overlay (no main window) on a
  # Wayland display, loads a saved layout and switches to Mapping Mode.
  keymapper-entry = pkgs.writeText "waydroid-helper-keymapper" ''
    #!/usr/bin/env python3
    # Usage: waydroid-helper-keymapper [DISPLAY] [LAYOUT.json]
    import gettext
    import locale
    import multiprocessing
    import os
    import sys

    PKGDATADIR = "@out@/share/waydroid-helper"
    LOCALEDIR = "@out@/share/locale"

    # multiprocessing re-runs this file in its helper processes, so the module
    # level only sets up paths, like waydroid-helper's own launcher does.
    sys.path.insert(1, PKGDATADIR)
    os.environ["PKGDATADIR"] = PKGDATADIR
    os.environ.setdefault("PROJECT_NAME", "waydroid-helper")
    locale.bindtextdomain("waydroid-helper", LOCALEDIR)
    locale.textdomain("waydroid-helper")
    gettext.bindtextdomain("waydroid-helper", LOCALEDIR)
    gettext.textdomain("waydroid-helper")


    def main():
        display = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("WAYLAND_DISPLAY", "waydroid-0")
        layout = sys.argv[2] if len(sys.argv) > 2 else ""

        # waydroid-helper normally runs the Key Mapper as a child process of its
        # main window. Under that name its logging stays in this process instead
        # of starting a log listener process that only the main window stops.
        multiprocessing.current_process().name = f"KeyMapper-{display}"

        import asyncio
        import warnings

        import gi

        gi.require_version("Gtk", "4.0")
        gi.require_version("Adw", "1")
        gi.require_version("Gdk", "4.0")

        from gi.events import GLibEventLoopPolicy
        from gi.repository import GLib

        from waydroid_helper.controller.app.window import KeyMapper, TransparentWindow
        from waydroid_helper.controller.core.control_msg import ScreenInfo

        class LauncherKeyMapper(KeyMapper):
            def do_activate(self):
                super().do_activate()
                GLib.timeout_add(200, self._load_layout)

            def _load_layout(self):
                window = self.window
                # Widget positions are scaled to the overlay's size, so wait
                # until the overlay has been maximized.
                if window is None or 0 in ScreenInfo().get_host_resolution():
                    return True
                if layout and os.path.isfile(layout):
                    window.menu_manager._on_load_layout_file_selected(True, layout, window.widget_factory)
                    window.switch_mode(TransparentWindow.MAPPING_MODE)
                return False

        # Same call as waydroid-helper's own Key Mapper; deprecated in Python 3.14.
        warnings.filterwarnings(
            "ignore", message=r"'asyncio\.set_event_loop_policy' is deprecated", category=DeprecationWarning
        )
        asyncio.set_event_loop_policy(GLibEventLoopPolicy())
        return LauncherKeyMapper(display).run([sys.argv[0]])


    if __name__ == "__main__":
        multiprocessing.freeze_support()
        sys.exit(main())
  '';

  # Installed next to waydroid-helper's own program, so it gets the same
  # Python and GTK environment when the package is wrapped.
  waydroid-helper = pkgs.waydroid-helper.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      install -Dm755 ${keymapper-entry} $out/bin/waydroid-helper-keymapper
      substituteInPlace $out/bin/waydroid-helper-keymapper --subst-var out
    '';
  });

  azur-lane = pkgs.writeShellApplication {
    name = "azur-lane";
    runtimeInputs = [
      config.virtualisation.waydroid.package
      cage-waydroid
      waydroid-helper
      pkgs.android-tools
      pkgs.coreutils
      pkgs.gawk
      pkgs.jq
      pkgs.libnotify
      pkgs.wayland-utils
    ];
    text = ''
      game=com.YoStarEN.AzurLane
      config_dir=''${XDG_CONFIG_HOME:-$HOME/.config}/waydroid-helper
      layout=''${AZUR_LANE_LAYOUT:-$config_dir/layouts/azur-lane.json}

      notify() {
        echo "azur-lane: $1" >&2
        notify-send --app-name="Azur Lane" "Azur Lane" "$1" || true
      }

      setting() {
        local value=""
        if [[ -r $config_dir/config.json ]]; then
          value=$(jq -r --arg key "$1" '.cage[$key] // empty' "$config_dir/config.json" 2>/dev/null || true)
        fi
        echo "''${value:-$2}"
      }

      session_running() {
        local status
        status=$(waydroid status 2>/dev/null || true)
        [[ $status =~ Session:[[:space:]]+RUNNING ]]
      }

      width=$(setting window_width 1920)
      height=$(setting window_height 1080)
      logical_width=$(setting logical_width "$width")
      logical_height=$(setting logical_height "$height")
      scale=$(awk -v percent="$(setting scale 100)" 'BEGIN { print percent / 100 }')
      refresh=$(setting refresh_rate 60)
      socket=$(setting socket_name waydroid-0)

      # Android has to start inside cage, so stop a session that is already running.
      if session_running; then
        waydroid session stop >/dev/null 2>&1 || true
        for _ in {1..30}; do
          session_running || break
          sleep 1
        done
      fi

      cage-waydroid -W "$width" -H "$height" -w "$logical_width" -h "$logical_height" \
        -S "$socket" --scale "$scale" --refresh-rate "$refresh" -- waydroid show-full-ui &
      cage=$!

      cleanup() {
        waydroid session stop >/dev/null 2>&1 || true
        wait "$cage" 2>/dev/null || true
      }
      trap cleanup EXIT

      # Once its window is closed, cage stops answering on its socket and only
      # waits for Android to shut down.
      cage_open() {
        local _
        for _ in 1 2; do
          kill -0 "$cage" 2>/dev/null || return 1
          WAYLAND_DISPLAY=$socket timeout 3 wayland-info >/dev/null 2>&1 && return 0
        done
        return 1
      }

      booted=false
      cage_seen=false
      for _ in {1..180}; do
        if ! kill -0 "$cage" 2>/dev/null; then
          notify "The game window closed before Android finished starting. Run azur-lane in a terminal to see why."
          exit 1
        fi
        if cage_open; then
          cage_seen=true
        elif $cage_seen; then
          exit 0
        fi
        boot=$(waydroid prop get sys.boot_completed 2>/dev/null || true)
        if grep -qx 1 <<<"$boot"; then
          booted=true
          break
        fi
        sleep 1
      done
      if ! $booted; then
        notify "Android didn't finish starting."
        exit 1
      fi

      ip=$(waydroid status 2>/dev/null | awk -F '\t' '/^IP address:/ { print $2 }' || true)
      [[ $ip =~ ^[0-9.]+$ ]] || ip=192.168.240.112
      serial=$ip:5555
      state=""
      asked=false
      for _ in {1..90}; do
        adb connect "$serial" >/dev/null 2>&1 || true
        state=$(adb -s "$serial" get-state 2>&1 || true)
        state=''${state%%$'\n'*}
        [[ $state == device ]] && break
        if [[ $state == *unauthorized* ]] && ! $asked; then
          notify "Android is asking to allow USB debugging: tick \"Always allow\" and press Allow."
          asked=true
        fi
        sleep 1
      done
      # Start the game the way tapping its icon does, then check that it is in
      # front: right after boot Android can still be bringing up its home screen.
      if [[ $state != device ]]; then
        notify "Can't reach Android over ADB ($state), so the game and key mapping won't start."
      else
        component=$(adb -s "$serial" shell cmd package resolve-activity --brief \
          -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$game" 2>/dev/null |
          tail -n 1 | tr -d '\r' || true)
        if [[ $component != "$game"/* ]]; then
          notify "Azur Lane ($game) isn't installed in Android."
        else
          launched=false
          out=""
          focus=""
          for _ in {1..5}; do
            # 0x10200000 = NEW_TASK | RESET_TASK_IF_NEEDED, as the launcher uses
            out=$(timeout 30 adb -s "$serial" shell am start -W -a android.intent.action.MAIN \
              -c android.intent.category.LAUNCHER -f 0x10200000 -n "$component" 2>&1 || true)
            sleep 3
            focus=$(adb -s "$serial" shell dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' || true)
            if [[ $focus == *"$game"* ]]; then
              launched=true
              break
            fi
          done
          if ! $launched; then
            printf 'azur-lane: am start said:\n%s\nazur-lane: focus is:\n%s\n' "$out" "$focus" >&2
            notify "Azur Lane didn't come to the front. Run azur-lane in a terminal for details."
          fi
        fi
      fi

      # The overlay runs until the cage window is closed (it loses its display).
      if cage_open; then
        if [[ ! -f $layout ]]; then
          notify "No saved layout at $layout yet: set one up and save it there."
        fi
        WAYLAND_DISPLAY=$socket waydroid-helper-keymapper "$socket" "$layout" || true
      fi
    '';
  };
in
{
  environment.systemPackages = [
    waydroid-helper
    cage-waydroid
    azur-lane
    pkgs.android-tools
  ];

  home-manager.users.kjetteren.xdg.desktopEntries.azur-lane = {
    name = "Azur Lane (Key Mapper)";
    exec = lib.getExe azur-lane;
    icon = "${home}/.local/share/waydroid/data/icons/com.YoStarEN.AzurLane.png";
    categories = [ "Game" ];
  };
}
