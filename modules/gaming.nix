{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 25565 5520 ];
    allowedUDPPorts = [ 25565 5520 ];
  };
  programs.haguichi.enable = true;
  services.tailscale.enable = true;
  programs.ydotool.enable = true;
}
