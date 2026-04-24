{ inputs, pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # managed by UWSM
    package = null;
    portalPackage = null;
    settings = {
      "$mod" = "SUPER";
      monitor = [
        "eDP-1, 1920x1080@300, 1920x0, 1"
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
      ];
      workspace = [
        "1, monitor:HDMI-A-1, default:true"
        "2, monitor:eDP-1, default:true"
      ];
      input = {
        kb_layout = "gb,ru";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };
      bind =
        [
          "$mod, A, exec, sh -c 'while true; do ydotool click 0xC0; sleep 0.01; done'"
          "$mod SHIFT, A, exec, pkill -f 'ydotool click 0xC0'"
          "$mod, Q, killactive"
          "$mod, F, fullscreen, 0"
          "$mod, T, togglefloating"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, right, resizeactive, 100 0"
          "$mod SHIFT, left, resizeactive, -100 0"
          "$mod SHIFT, down, resizeactive, 0 100"
          "$mod SHIFT, up, resizeactive, 0 -100"
          "$mod, B, exec, uwsm app -- brave"
          "$mod, Return, exec, uwsm app -- alacritty"
          "$mod, E, exec, uwsm app -- thunar"
          "$mod Ctrl, Return, global, caelestia:launcher"
          "$mod, V, exec, cliphist list | wofi --dmenu --pre-display-cmd \"echo '%s' | cut -f 2\" | cliphist decode | wl-copy"
          ", Print, exec, grimblast copy output"
          "$mod, Print, exec, grimblast copy area"
          ", XF86MonBrightnessUp, exec, brightnessctl -q s +10%"
          ", XF86MonBrightnessDown, exec, brightnessctl -q s 10%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPause, exec, playerctl pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ]
        ++ (builtins.concatLists (builtins.genList (i:
          let ws = i + 1; in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9));
      bindm = [ "$mod, mouse:272, movewindow" ];
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;
      };
      decoration = {
        rounding = 12;
      };
    };
  };

  programs.wofi.enable = true;

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };
}
