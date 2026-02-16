{ pkgs, inputs, ... }: {
  imports = [ ./shell.nix inputs.lazyvim.homeManagerModules.default ];

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
