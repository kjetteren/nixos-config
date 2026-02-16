# nixos-config

A modular, Flake-powered NixOS configuration featuring Secure Boot (Lanzaboote), CachyOS kernels, and 1Password integration.

## 🛠 Features

* **Flake-Based**: Fully reproducible system and user management via Nix Flakes.
* **Modular Architecture**: Clean separation of concerns for hardware, boot, gaming, and services.
* **High Performance**: Powered by the **CachyOS-Bore** kernel for enhanced system responsiveness.
* **Security & Encryption**: 
    * **Secure Boot**: Implemented via `lanzaboote` and `sbctl`.
    * **LUKS**: Full disk encryption using `systemd-initrd`.
    * **1Password**: System-wide integration with SSH agent and Git commit signing.
* **Desktop Environment**: **KDE Plasma 6** on Wayland with a customized **SilentSDDM** theme.
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
│   ├── nvidia.nix        # Nvidia driver and Prime configuration
│   ├── sddm.nix          # SilentSDDM greeter setup
│   ├── obs.nix           # OBS Studio with CUDA support
│   ├── asus.nix          # ASUS-specific system services
│   └── gaming.nix        # Steam, Gamescope, and Firewall settings
└── users/
    └── kjetteren/
        ├── home.nix      # Home Manager configuration
        ├── shell.nix     # Zsh configuration and aliases
        ├── p10k.zsh      # Powerlevel10k theme configuration
        └── icon.png      # User profile picture
```

## 🚀 Installation
**1. Initialize Secure Boot**
Before applying the configuration on a new install, initialize `sbctl`:

```Bash
sudo sbctl create-keys
```

**2. Apply Configuration**

```Bash
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

## 🧹 Maintenance

**Standard Rebuild:**

```Bash
sudo nixos-rebuild switch --flake .#nixos
```

**Update System (Update Lockfile):**

```Bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

**Garbage Collection:**

```Bash
sudo nix-collect-garbage -d
```
