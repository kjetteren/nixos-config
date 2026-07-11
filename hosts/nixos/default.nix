{ pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ../../modules/asus.nix
    ../../modules/boot.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/nix.nix
    ../../modules/nvidia.nix
    ../../modules/obs.nix
    ../../modules/sddm.nix
    ../../modules/user.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_GB.UTF-8";

  # TTY & Locale
  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # Inherits layout and options from services.xserver.xkb
  };

  # Keyboard Layout
  services.xserver.xkb = {
    layout = "gb,ru";
    options = "grp:win_space_toggle";
  };

  # Services
  services.upower.enable = true;
  services.libinput.enable = true;
  services.usbmuxd.enable = true;
  services.logmein-hamachi.enable = true;

  system.stateVersion = "25.11";
}
