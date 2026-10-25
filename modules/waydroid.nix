{ pkgs, inputs, ... }: {
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  environment.systemPackages = [
    inputs.waydroid-script.packages.${pkgs.stdenv.hostPlatform.system}.waydroid_script
    pkgs.waydroid-helper
  ];
}
