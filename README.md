# Hyprland Bootable Container

This is a very opinionated implementation of hyprland using a Fedora bootable container.
After building the container image, a resulting ISO can be built using [bootc-image-builder](https://github.com/osbuild/bootc-image-builder).

Necessary packages & firmware are added to the container and are layered into the resulting
bootc image. The packages that are installed are the minimum needed to run my personal [dotfiles](https://github.com/kingsleyzissou/.dotfiles). Any other packages needed can be installed with `distrobox` or `flatpak`.
