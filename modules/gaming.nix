{ pkgs, inputs, ... }: {
  imports = [ inputs.epic-games-launcher.nixosModules.default ];
  programs.epic-games-launcher.enable = true;
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  programs.ydotool.enable = true;
}
