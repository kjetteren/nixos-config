{ ... }: {
  services.flatpak = {
    enable = true;
    update.auto.enable = true;
    packages = [
      "org.vinegarhq.Sober"
    ];
  };
}
