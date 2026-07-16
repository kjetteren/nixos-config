{ config, pkgs, inputs, lib, ... }: {
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    settings = {
      timeout = 0;
      default = "nixos-*";
    };
  };
  
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  boot.kernelParams = [ "quiet" "splash" "loglevel=0" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" "i8042.dumbkbd=1" ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "amdgpu" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "asus_wmi" "asus_nb_wmi" ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/1647454c-0bf6-4453-a438-d82c8cf61d11";
    allowDiscards = true;
  };
  boot.resumeDevice = "/dev/mapper/vg0-swap";

  system.activationScripts.tpm-warn = {
    supportsDryActivation = true;
    text = ''
      # Compare the booted kernel path with the newly built kernel path
      if [ -e /run/booted-system/kernel ] && [ -e /run/current-system/kernel ]; then
        if [ "$(readlink /run/booted-system/kernel)" != "$(readlink /run/current-system/kernel)" ]; then
          echo -e "\033[1;33m"
          echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          echo "   WARNING: KERNEL/BOOT FILES UPDATED"
          echo "   Your TPM PIN will NOT work on the next reboot."
          echo "   Please run 'nix-seal' NOW to update your PIN slot."
          echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          echo -e "\033[0m"
        fi
      fi
    '';
  };
}
