{ pkgs, ... }: {
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  boot.initrd.services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/asus-battery-charge-threshold.rules" ''
      ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}="60"
    '')
  ];
}
