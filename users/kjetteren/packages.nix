{ pkgs, ...}: {
  home.packages = with pkgs; [
    # System / security
    brightnessctl
    nh
    nix-output-monitor
    nvd
    sbctl
    tpm2-tools

    # CLI tools
    bat
    btop
    eza
    fastfetch
    fd
    fzf
    gcc
    ripgrep
    unzip
    wget
    wl-clipboard
    zsh-powerlevel10k

    # Media
    mpv
    pavucontrol
    playerctl
    spotify

    # Apps
    alacritty
    brave
    discord
    firefox
    obsidian
    onlyoffice-desktopeditors
    pinta
    protonmail-desktop
    proton-vpn
    qbittorrent
    teamspeak6-client
    telegram-desktop
    thunderbird

    # Gaming
    lutris
    mangohud
    prismlauncher
    flycast

    # iOS
    ifuse
    libimobiledevice

    # Hyprland utilities
    cliphist
    grimblast
    hyprpicker

    # Icons
    hicolor-icon-theme
    papirus-icon-theme

    # TPM sync check
    (writeShellScriptBin "nix-seal" ''
      echo "Removing old/broken TPM slots..."
      sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2

      echo "Sealing LUKS to new system state (PCR 0+2+7+12) with PIN..."
      sudo systemd-cryptenroll --tpm2-device=auto \
        --tpm2-pcrs=0+2+7+12 \
        --tpm2-with-pin=yes \
        /dev/nvme0n1p2

      echo "Sync complete! Your PIN will work on the next boot."
    '')
  ];
}
