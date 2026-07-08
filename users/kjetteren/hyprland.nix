{ inputs, pkgs, lib, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # managed by UWSM
    package = null;
    portalPackage = null;
    configType = "lua";
    settings = {
      mod = {
        _var = "SUPER";
      };
      monitor = [
        {
          output = "eDP-1";
          mode = "1920x1080@300";
          position = "1920x0";
          scale = 1;
        }
        {
          output = "HDMI-A-1";
          mode = "1920x1080@60";
          position = "0x0";
          scale = 1;
        }
      ];
      workspace_rule = [
        {
          workspace = "1";
          monitor = "HDMI-A-1";
          default = true;
        }
        {
          workspace = "2";
          monitor = "eDP-1";
          default = true;
        }
      ];
      config = {
        input = {
          kb_layout = "gb,ru";
          kb_options = "grp:win_space_toggle";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
          };
        };
        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 10;
        };
        decoration = {
          rounding = 12;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };
      bind = [
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + mouse:272"'') (lib.generators.mkLuaInline ''hl.dsp.window.drag()'') { mouse = true; } ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + A"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("sh -c 'while true; do ydotool click 0xC0; sleep 0.01; done'")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + A"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pkill -f 'ydotool click 0xC0'")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + B"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- brave")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + RETURN"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- alacritty")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + E"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- thunar")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + RETURN"'') (lib.generators.mkLuaInline ''hl.dsp.global("caelestia:launcher")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + V"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("cliphist list | wofi --dmenu --pre-display-cmd \"echo '%s' | cut -f 2\" | cliphist decode | wl-copy")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + Q"'') (lib.generators.mkLuaInline ''hl.dsp.window.close()'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + F"'') (lib.generators.mkLuaInline ''hl.dsp.window.fullscreen({ mode = 0 })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + T"'') (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + left"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "l" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + right"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "r" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + up"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "u" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + down"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "d" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + right"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 100, y = 0, relative = true })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + left"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = -100, y = 0, relative = true })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + down"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = 100, relative = true })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + up"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = -100, relative = true })'') ]; }
        { _args = [ "Print" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("grimblast copy output")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + Print"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("grimblast copy area")'') ]; }
        { _args = [ "XF86MonBrightnessUp" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -q s +10%")'') ]; }
        { _args = [ "XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -q s 10%-")'') ]; }
        { _args = [ "XF86AudioMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'') ]; }
        { _args = [ "XF86AudioMicMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'') ]; }
        { _args = [ "XF86AudioPlay" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'') ]; }
        { _args = [ "XF86AudioPause" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl pause")'') ]; }
        { _args = [ "XF86AudioNext" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'') ]; }
        { _args = [ "XF86AudioPrev" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'') ]; }
      ]
      ++ [
        {
          _args = [
            "XF86AudioRaiseVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')
            { locked = true; repeating = true; }
          ];
        }
        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
            { locked = true; repeating = true; }
          ];
        }
      ]
      ++ (builtins.concatLists (builtins.genList (i:
        let ws = i + 1; in [
          {
            _args = [
              (lib.generators.mkLuaInline ''mod .. " + code:1${toString i}"'')
              (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "${toString ws}" })'')
            ];
          }
          {
            _args = [
              (lib.generators.mkLuaInline ''mod .. " + SHIFT + code:1${toString i}"'')
              (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "${toString ws}" })'')
            ];
          }
        ]) 9));
    };
  };

  programs.wofi.enable = true;

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };
}
