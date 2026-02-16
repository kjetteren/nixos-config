{ pkgs, inputs, lib, ... }: {
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = { enable = true; pkiBundle = "/var/lib/sbctl"; };
  
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
  boot.kernelParams = [ "quiet" "splash" "loglevel=0" "rd.systemd.show_status=false" "rd.udev.log_level=0" ];

  boot.plymouth.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/1647454c-0bf6-4453-a438-d82c8cf61d11";
    allowDiscards = true;
  };
  boot.resumeDevice = "/dev/mapper/vg0-swap";
}
