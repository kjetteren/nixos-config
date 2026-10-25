{ config, ... }: {
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:05:00.0", SYMLINK+="dri/amd-card"
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:5@0:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    dynamicBoost.enable = true;
  };
}
