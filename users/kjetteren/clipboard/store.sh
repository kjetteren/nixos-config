if [[ ${CLIPBOARD_STATE:-data} != data ]]; then
  exec cliphist store
fi

types=$(timeout 2 wl-paste --list-types 2>/dev/null || true)

if ! grep -qxE 'text/plain(;charset=utf-8)?|UTF8_STRING|STRING|TEXT' <<<"$types"; then
  image=$(grep -m1 -x 'image/png' <<<"$types" || grep -m1 '^image/' <<<"$types" || true)
  if [[ -n $image ]]; then
    exec </dev/null
    timeout 5 wl-paste --no-newline --type "$image" | cliphist store
    exit
  fi
fi

exec cliphist store
