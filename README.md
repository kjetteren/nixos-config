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
    * **caelestia**: Patched (`caelestia-relock-on-start.patch`) to take the session lock back if the shell restarts while the session is locked; apps launched from it keep running across shell restarts and their tray icons re-register.
    * **Clipboard**: `cliphist` history with a caelestia-styled rofi picker on Super+V.
    * **File Manager**: **Thunar** with archive support, thumbnails, and `gvfs`.
* **NVIDIA**: Open kernel module with Prime offload (desktop on the AMD iGPU, NVIDIA dGPU on demand via `nvidia-offload`), fine-grained power management, Dynamic Boost, and VA-API hardware decode.
* **Gaming**: **Steam** with Proton-GE, `protontricks`, and a Gamescope session; the **Epic Games Launcher** from [epic-games-launcher-flake](https://github.com/kjetteren/epic-games-launcher-flake); **Sober** (Roblox) as a Flatpak via `nix-flatpak`, offloaded to the NVIDIA dGPU; Xbox controller drivers (`xone`, `xpadneo`).
* **Android**: **Waydroid** (nftables backend) with `waydroid_script` and `waydroid-helper`, plus an Azur Lane launcher with waydroid-helper's Key Mapper (see [below](#-waydroid--azur-lane)).
* **Shell Environment**: **Zsh** with Powerlevel10k, syntax highlighting, and modern CLI tools (`eza`, `bat`, `fzf`).
* **Development**: **Zed** with `nixd` (formatting with `nixfmt`), `rust-analyzer`, `clangd`, `pyright`, and `taplo`, plus Claude Code as an agent via `claude-agent-acp`; **LazyVim** via `lazyvim-nix`; `direnv` + `nix-direnv` for per-project shells.
* **Claude Desktop**: With Cowork support, which runs its tasks in a QEMU/KVM virtual machine (`kvm` group + `vhost_vsock`).

## 📂 Structure

```text
/etc/nixos
├── flake.nix                   # Entry point for the system configuration
├── flake.lock                  # Generated lockfile for dependency version pinning
├── hosts/
│   └── nixos/
│       ├── default.nix         # Main system configuration
│       └── hardware.nix        # Auto-generated hardware configuration
├── modules/                    # Reusable system modules
│   ├── asus.nix                # asusd and a 60% battery charge limit
│   ├── boot.nix                # Lanzaboote, CachyOS kernel, Plymouth, and LUKS
│   ├── claude.nix              # Claude Desktop with Cowork (KVM + vhost_vsock)
│   ├── desktop.nix             # Hyprland, Thunar, PipeWire, Bluetooth, gphoto2, and fonts
│   ├── gaming.nix              # Steam, Gamescope, Epic Games Launcher, and controller drivers
│   ├── nix.nix                 # Nix settings, binary caches, and GC
│   ├── nvidia.nix              # NVIDIA driver, Prime offload, and Dynamic Boost
│   ├── obs.nix                 # OBS Studio with CUDA support
│   ├── sddm.nix                # SilentSDDM greeter setup
│   ├── user.nix                # User account, Home Manager link, and programs
│   ├── waydroid.nix            # Waydroid (nftables) and waydroid_script
│   └── waydroid-keymapper.nix  # waydroid-helper with Key Mapper, and the Azur Lane launcher
└── users/
    └── kjetteren/
        ├── clipboard/          # Clipboard history: cliphist + rofi picker (Super+V)
        ├── flatpak.nix         # Declarative Flatpak management (nix-flatpak)
        ├── home.nix            # Home Manager entry point and user services
        ├── hyprland.nix        # Hyprland config, keybinds, and caelestia integration
        ├── packages.nix        # User packages and the nix-seal script
        ├── shell.nix           # Zsh configuration and aliases
        ├── theme.nix           # GTK theme and cursor configuration
        ├── thunar.nix          # Thunar preferences
        ├── zed.nix             # Zed editor settings and language servers
        ├── caelestia-relock-on-start.patch
        ├── p10k.zsh            # Powerlevel10k theme configuration
        └── icon.png            # User profile picture
```

## 🚀 Installation

**1. Initialize Secure Boot**

Before applying the configuration on a new install, initialize `sbctl`:

```bash
sudo sbctl create-keys
```

**2. Apply Configuration**

```bash
git clone git@github.com:kjetteren/nixos-config.git /tmp/nixos-config
sudo cp -r /tmp/nixos-config/* /etc/nixos/
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

`nix-seal` is defined in `users/kjetteren/packages.nix` and re-enrolls the TPM2 + PIN slot against PCRs 0, 2, 7, and 12. It changes nothing if the TPM is in dictionary-attack lockout (it prints the command to clear it instead), and only wipes the old TPM2 slot once the new one is enrolled.

## 📱 Waydroid & Azur Lane

Waydroid runs with the nftables backend; `waydroid_script` and `waydroid-helper` are installed alongside it for setup.

`azur-lane` (in the app launcher as **Azur Lane (Key Mapper)**) starts Android inside waydroid-helper's fork of `cage`, waits for it to boot, opens the game over ADB, and runs waydroid-helper's Key Mapper on top with a saved layout. Closing the window stops the Waydroid session.

First-time setup:

1. Initialize Waydroid with `sudo waydroid init` and install Azur Lane inside Android. `sudo waydroid_script` can add extras such as GApps or an ARM translation layer.
2. Create a layout in waydroid-helper's Key Mapper and save it as `~/.config/waydroid-helper/layouts/azur-lane.json`, or point `AZUR_LANE_LAYOUT` at another file.
3. If Android asks to allow USB debugging on the first launch, tick **Always allow** and press **Allow**.

The window size, scale, and refresh rate come from the `cage` section of `~/.config/waydroid-helper/config.json` (default 1920×1080 at 60 Hz).

## 🧹 Maintenance

**Rebuild:**

```bash
nh os switch /etc/nixos
```

**Update and rebuild:**

```bash
upgrade
```

`upgrade` is a Zsh alias defined in `users/kjetteren/shell.nix`, and expands to:

```bash
nix flake update --flake /etc/nixos && nh os switch /etc/nixos
```

**Garbage collection:**

```bash
nh clean all
```

`programs.nh.clean` also runs automatically, keeping the last 3 generations and anything from the past 3 days.
