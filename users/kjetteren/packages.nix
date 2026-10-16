{ pkgs, osConfig, ... }: {
  home.packages = with pkgs; [
    # System / security
    brightnessctl
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
    spotifast
    syncplay

    # Apps
    alacritty
    brave
    discord
    firefox
    obsidian
    onlyoffice-desktopeditors
    pinta
    printcraft
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
    grimblast
    hyprpicker

    # Icons
    hicolor-icon-theme
    papirus-icon-theme

    # TPM sync check
    (writeShellApplication {
      name = "nix-seal";
      runtimeInputs = [ tpm2-tools ];
      text = ''
        dev=${osConfig.boot.initrd.luks.devices.cryptroot.device}
        pcrs=0+2+7+12

        if ! tpm_state=$(sudo tpm2_getcap -T device:/dev/tpmrm0 properties-variable); then
          echo "Could not query the TPM. Nothing was changed." >&2
          exit 1
        fi
        if grep -Eq '^[[:space:]]*inLockout:[[:space:]]*1' <<<"$tpm_state"; then
          echo "TPM is in dictionary-attack lockout. Nothing was changed." >&2
          grep -E 'lockoutAuthSet|TPM2_PT_(LOCKOUT_COUNTER|MAX_AUTH_FAIL|LOCKOUT_INTERVAL)' <<<"$tpm_state" >&2 || true
          echo "Clear it with: sudo tpm2_dictionarylockout -T device:/dev/tpmrm0 --clear-lockout" >&2
          exit 1
        fi

        echo "Sealing LUKS to current system state (PCR $pcrs) with PIN..."
        if ! sudo systemd-cryptenroll \
          --tpm2-device=auto \
          --tpm2-pcrs="$pcrs" \
          --tpm2-with-pin=yes \
          --wipe-slot=tpm2 \
          "$dev"; then
          echo "Enrollment failed. No key slots were wiped." >&2
          exit 1
        fi

        sudo systemd-cryptenroll "$dev"
        echo "Sync complete! Your PIN will work on the next boot."
      '';
    })
  ];
}
