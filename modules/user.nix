{ pkgs, inputs, ... }: {
  # User & Security
  users.users.kjetteren = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" "ydotool" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.histSize = 10000;

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.NetworkManager.settings.modify.system" ||
           action.id == "org.freedesktop.NetworkManager.network-control") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      } 
    });
  '';
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  hardware.i2c.enable = true;

  # Programs
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "kjetteren" ];
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Home Manager Link
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.kjetteren = import ../users/kjetteren/home.nix;
  };
}
