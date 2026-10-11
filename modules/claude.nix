{ inputs, ... }: {
  imports = [ inputs.claude-desktop-nix-flake.nixosModules.default ];

  programs.claude-desktop.enable = true;

  # Cowork runs its tasks in a QEMU/KVM virtual machine
  users.users.kjetteren.extraGroups = [ "kvm" ];
  boot.kernelModules = [ "vhost_vsock" ];
}
