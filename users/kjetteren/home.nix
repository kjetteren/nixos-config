{ pkgs, inputs, ... }: {
  imports = [ 
    ./hyprland.nix
    ./packages.nix
    ./shell.nix
    ./theme.nix
    inputs.lazyvim.homeManagerModules.default
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
  services.cliphist.enable = true;

  home.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/card2:/dev/dri/card1";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "radeonsi";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
  };

  systemd.user.services.protonvpn-autostart = {
    Unit = {
      Description = "ProtonVPN Autostart";
      After = [ "graphical-session.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.uwsm}/bin/uwsm app -- protonvpn-app";
      Restart = "on-failure";
      RestartSec = 2;
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
}
