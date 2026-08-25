{ pkgs, ... }: {
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = { package = pkgs.nordic; name = "Nordic-darker"; };
    iconTheme = { package = pkgs.adwaita-icon-theme; name = "Adwaita"; };
    font = { name = "Sans"; size = 11; };
    gtk4.theme = null;
  };
}
