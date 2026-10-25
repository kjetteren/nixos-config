{ pkgs, inputs, ... }: {
  imports = [
    ./clipboard
    ./flatpak.nix
    ./hyprland.nix
    ./packages.nix
    ./shell.nix
    ./theme.nix
    ./thunar.nix
    ./zed.nix
    inputs.lazyvim.homeManagerModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.file.".p10k.zsh".source = ./p10k.zsh;

  fonts.fontconfig.enable = true;

  programs.lazyvim = {
    enable = true;
    extras = {
      lang.nix.enable = true;
      lang.python = {
        enable = true;
        installDependencies = true;
      };
      lang.clangd.enable = true;
      editor.telescope.enable = true;
      editor.harpoon2.enable = true;
    };
  };

  services.hyprpolkitagent.enable = true;

  home.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/amd-card";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "radeonsi";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
  };

  systemd.user.services.protonvpn-autostart = {
    Unit = {
      Description = "ProtonVPN Autostart";
      After = [
        "graphical-session.target"
        "tray.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.proton-vpn}/bin/protonvpn-app";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.user.services.tray-reregister = {
    Unit = {
      Description = "Re-register tray icons when the tray restarts";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${
        pkgs.writeShellApplication {
          name = "tray-reregister";
          runtimeInputs = [
            pkgs.systemd
            pkgs.glib
            pkgs.gawk
          ];
          text = ''
            reregister() {
              busctl --user list --acquired --no-legend \
                | awk '$1 ~ /^org\.(kde|freedesktop)\.StatusNotifierItem-/ { print $1 }' \
                | while read -r item; do
                    busctl --user call org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
                      org.kde.StatusNotifierWatcher RegisterStatusNotifierItem s "$item" || true
                  done
            }

            gdbus monitor --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
              | while read -r line; do
                  case "$line" in
                    *"NameOwnerChanged ('org.kde.StatusNotifierWatcher', "*"', ':"*) reregister ;;
                  esac
                done
          '';
        }
      }/bin/tray-reregister";
      Restart = "always";
      RestartSec = "2s";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      commit.gpgsign = true;
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLQs6d0wZWg/B+31QFzHEuVTeYIpfbeiWOWHj+JzqDn";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
