# nixos-config

A modular, Flake-powered NixOS configuration featuring Secure Boot (Lanzaboote), CachyOS kernels, Hyprland with caelestia-dots, and 1Password integration.

## 🛠 Features

* **Flake-Based**: Fully reproducible system and user management via Nix Flakes.
* **Modular Architecture**: Clean separation of concerns for hardware, boot, gaming, and services.
* **High Performance**: Powered by the **CachyOS-Bore** kernel for enhanced system responsiveness.
* **Security & Encryption**:
    * **Secure Boot**: Implemented via `lanzaboote` and `sbctl`.
    * **LUKS**: Full disk encryption with TPM2 + PIN sealing via `systemd-cryptenroll`.
    * **1Password**: System-wide integration with SSH agent and Git commit signing.
* **Desktop Environment**: **Hyprland** on Wayland via UWSM, with [caelestia-dots](https://github.com/caelestia-dots/shell) (Quickshell + Material You) and a customized **SilentSDDM** theme.
* **NVIDIA**: Open kernel module with Prime offload (AMD iGPU + NVIDIA dGPU), fine-grained power management, and VA-API hardware decode.
* **Shell Environment**: **Zsh** with Powerlevel10k, syntax highlighting, and modern CLI tools (`eza`, `bat`, `fzf`).

## 📂 Structure

```text
/etc/nixos
├── flake.nix             # Entry point for the system configuration
├── flake.lock            # Generated lockfile for dependency version pinning
├── hosts/
│   └── nixos/
│       ├── default.nix   # Main system configuration
│       └── hardware.nix  # Auto-generated hardware configuration
├── modules/              # Reusable system modules
│   ├── boot.nix          # Bootloader, Plymouth, and Lanzaboote
│   ├── desktop.nix       # Hyprland, PipeWire, fonts, and Bluetooth
│   ├── gaming.nix        # Steam, Gamescope, and firewall settings
│   ├── nix.nix           # Nix settings, binary caches, and GC
│   ├── nvidia.nix        # NVIDIA driver and Prime offload configuration
│   ├── obs.nix           # OBS Studio with CUDA support
│   ├── sddm.nix          # SilentSDDM greeter setup
│   ├── user.nix          # User account, Home Manager link, and programs
│   └── asus.nix          # ASUS-specific system services
└── users/
    └── kjetteren/
        ├── flatpak.nix   # Declarative Flatpak management (nix-flatpak)
        ├── home.nix      # Home Manager entry point
        ├── hyprland.nix  # Hyprland config, keybinds, and caelestia integration
        ├── packages.nix  # User packages
        ├── shell.nix     # Zsh configuration and aliases
        ├── theme.nix     # GTK theme and cursor configuration
        ├── p10k.zsh      # Powerlevel10k theme configuration
        └── icon.png      # User profile picture
```

## 🚀 Installation

**1. Initialize Secure Boot**

Before applying the configuration on a new install, initialize `sbctl`:

```bash
sudo sbctl create-keys
```

**2. Apply Configuration**

```bash
git clone git@github.com:kjetteren/dotfiles-nixos.git /tmp/dotfiles
sudo cp -r /tmp/dotfiles/* /etc/nixos/
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

## 🔑 1Password & SSH Agent

This configuration uses 1Password for SSH authentication and Git signing.

1. Enable **SSH Agent** in 1Password Settings > Developer.
2. Commit signing is handled automatically via the `op-ssh-sign` helper.
3. The SSH agent is mapped to `~/.1password/agent.sock` via Home Manager configuration.

## 🔒 TPM2 + LUKS Sealing

After any rebuild that updates the kernel or boot files, the TPM PIN slot must be resealed or it will reject your PIN on next boot. The activation script will warn you when this is needed.

```bash
nix-seal
```

## 🧹 Maintenance

**Rebuild:**

```bash
nh os switch /etc/nixos
```

**Update and rebuild:**

```bash
nix flake update /etc/nixos && nh os switch /etc/nixos
```

**Garbage collection:**

```bash
nh clean all
```
