{ pkgs, inputs, lib, ... }: {
  imports = [ ./shell.nix inputs.lazyvim.homeManagerModules.default inputs.plasma-manager.homeModules.plasma-manager ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.file.".p10k.zsh".source = ./p10k.zsh;
  home.packages = with pkgs; [
    btop
    wget
    alacritty
    sbctl
    tpm2-tools
    brave
    teamspeak6-client
    telegram-desktop
    discord
    mpv
    git
    mangohud
    onlyoffice-desktopeditors
    libimobiledevice
    ifuse
    protonvpn-gui
    obsidian
    zsh-powerlevel10k
    eza
    bat
    fzf
    fastfetch
    gcc
    ripgrep
    fd
    unzip
    winboat
    prismlauncher
    logmein-hamachi
    haguichi
    wl-clipboard
    papirus-icon-theme
  ];

  programs.lazyvim = {
    enable = true;
    extras = {
      lang.nix.enable = true;
      lang.python = {
        enable = true;
	installDependencies = true;
	installRuntimeDependencies = true;
      };
      lang.clangd.enable = true;
      editor.telescope.enable = true;
      editor.harpoon2.enable = true;
    };
  };
  
  fonts.fontconfig.enable = true;

  programs.plasma = {
    enable = true;

    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    configFile."kdeglobals"."Icons"."Theme" = "Papirus";
    configFile."kdeglobals"."KDE" = {
      AutomaticDarkLightLookAndFeel = true;
      AutomaticLookAndFeel = true; 
      DefaultLightLookAndFeel = "org.kde.breeze.desktop";
      DefaultDarkLookAndFeel = "org.kde.breezedark.desktop";
    };

    kwin.nightLight = {
      enable = true;
      mode = "location";
      location = {
        latitude = "50.88";
        longitude = "4.70";
      };
    };

    kscreenlocker = {
      timeout = 30;
      passwordRequiredDelay = 30;
    };

    workspace = {
      wallpaper = ./wallpapers/Nix;
      iconTheme = null;
    };

    panels = [
      {
        floating = true;
        screen = "all";
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake"; 
              };
            };
          }
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:systemsettings.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:Alacritty.desktop"
                "applications:brave-browser.desktop"
                "applications:discord.desktop"
                "applications:org.telegram.desktop.desktop"
                "applications:TeamSpeak.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    shortcuts = {
      "services/Alacritty.desktop"."_launch" = "Ctrl+Alt+T";
      "services/org.kde.konsole.desktop"."_launch"="None";
    };
  };

  home.file.".local/share/icons/breeze".source = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Light";
  home.file.".local/share/icons/breeze-dark".source = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          IdentityAgent = "~/.1password/agent.sock";
        };
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
