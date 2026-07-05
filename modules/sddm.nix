{ pkgs, inputs, ... }: {
  imports = [ inputs.silentSDDM.nixosModules.default ];

  services.displayManager.sddm = {
    enable = true;
    extraPackages = [ pkgs.kdePackages.qtvirtualkeyboard ];
    settings.General.InputMethod = "qtvirtualkeyboard";
  };

  programs.silentSDDM = {
    enable = true;
    theme = "nord";
    profileIcons = {
      kjetteren = ../users/kjetteren/icon.png;
    };
    settings = {
      "General" = {
        DisplayServer = "wayland";
        GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
      };
    };
  };
}
