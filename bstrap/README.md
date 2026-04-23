# bstrap

Bootstrap script for setting up a new linux machine. Downloads `bstrap` toolchain and config.

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/Obbaron/.gbin/main/bstrap/setup.sh | sh
```

Or with wget:

```sh
wget -qO- https://raw.githubusercontent.com/Obbaron/.gbin/main/bstrap/setup.sh | sh
```

## What it does

- Creates `~/.local/bin/bstrap/` and installs the `bstrap` executable and its library scripts
- Downloads `bstrap.yaml` to `~/.config/` (or `$XDG_CONFIG_HOME` if set)
- Deletes itself after a successful install

## File structure

After install, the following files will be present:

```
~/.local/bin/bstrap/
├── bstrap
└── lib/
    ├── helpers.sh
    ├── 01_packages.sh
    ├── 02_directories.sh
    ├── 03_permissions.sh
    ├── 04_services.sh
    ├── 05_dotfiles.sh
    └── 06_fonts.sh

~/.config/
└── bstrap.yaml
```
