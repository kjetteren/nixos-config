{ pkgs, inputs, config, lib, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:5@0:0:0";
    };
  };
  
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
}
