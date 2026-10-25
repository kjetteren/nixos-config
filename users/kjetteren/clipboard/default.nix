{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # `wl-paste --watch` handler: stores one entry per copy (see store.sh)
  store = pkgs.writeShellApplication {
    name = "cliphist-store";
    runtimeInputs = with pkgs; [
      cliphist
      coreutils
      gnugrep
      wl-clipboard
    ];
    text = builtins.readFile ./store.sh;
  };

  picker = pkgs.writeShellApplication {
    name = "clipboard-picker";
    runtimeInputs = with pkgs; [
      cliphist
      libnotify
      rofi
      wl-clipboard
    ];
    text = ''
      export CLIPBOARD_PICKER_THEME=${./picker.rasi}
      exec ${pkgs.python3.withPackages (ps: [ ps.pillow ])}/bin/python3 -I ${./picker.py} "$@"
    '';
  };

  shellFont = pkgs.runCommand "caelestia-google-sans-flex" { } ''
    mkdir -p $out/share/fonts/truetype
    find ${inputs.caelestia-shell} -name 'GoogleSansFlex*.ttf' -exec cp -t $out/share/fonts/truetype {} +
  '';
in
{
  home.packages = [
    pkgs.cliphist
    picker
    shellFont
    pkgs.material-symbols
  ];

  # Read by every cliphist call: the watcher, the picker and `caelestia clipboard`
  xdg.configFile."cliphist/config".text = ''
    max-items 1000
    max-dedupe-search 1000
  '';

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history (cliphist)";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch ${lib.getExe store}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        (lib.generators.mkLuaInline ''mod .. " + V"'')
        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua { } (lib.getExe picker)})")
      ];
    }
  ];
}
