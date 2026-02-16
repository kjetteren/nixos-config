{ pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/nvidia.nix
    ../../modules/obs.nix
    ../../modules/gaming.nix
    ../../modules/asus.nix
    ../../modules/sddm.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_GB.UTF-8";

  # TTY & Locale
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
  };

  # Keyboard Layout
  services.xserver.xkb = {
    layout = "gb, ru";
    options = "grp:win_space_toggle";
  };

  # User & Security
  users.users.kjetteren = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  
  security.polkit.extraConfig = '' polkit.addRule(function(action, subject) { if ((action.id == "org.freedesktop.NetworkManager.settings.modify.system" || action.id == "org.freedesktop.NetworkManager.network-control") && subject.isInGroup("wheel")) { return polkit.Result.YES; } }); '';

  # Services
  services.pipewire = { enable = true; pulse.enable = true; };
  services.libinput.enable = true;
  services.flatpak.enable = true;
  services.usbmuxd.enable = true;
  services.logmein-hamachi.enable = true;
  virtualisation.docker.enable = true;

  # Programs
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true; # Add this line!
    polkitPolicyOwners = [ "kjetteren" ];
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Desktop Environment
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa gwenview kate konsole ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Home Manager Link
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.kjetteren = import ../../users/kjetteren/home.nix;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };
  system.stateVersion = "25.11";
}
