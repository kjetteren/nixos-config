{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # File manager
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-archive-plugin ];
  };
  environment.systemPackages = [ pkgs.file-roller ];
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  programs.gphoto2.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
