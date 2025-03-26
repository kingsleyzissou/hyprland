##########################################################
##### VPN config image
##########################################################
FROM ghcr.io/kingsleyzissou/internal-packages as vpn-configs
# execute a simple action so we can later copy the files
# from this container, we will need to be logged in with
# podman to be able to use this.
COPY README.md .

##########################################################
##### ddcci modules
##########################################################
FROM localhost/ddcci as ddcci
# no-op so we can use this as a builder image
RUN echo "no-op"

##########################################################
##### Hyprland base image
##########################################################
FROM quay.io/fedora/fedora-bootc:41

ARG KERNEL

RUN dnf5 -y update && dnf5 -y upgrade

##########################################################
##### Core
##########################################################
RUN dnf5 install -y \
  adwaita-qt6 \
  dnf5-plugins \
  flatpak \
  gtk3-devel \
  gtk4-devel \
  gtk-layer-shell-devel \
  gtk-murrine-engine \
  gobject-introspection-devel \
  greetd \
  iwd \
  kernel-${KERNEL} \
  krb5-workstation \
  libgtop2 \
  nautilus \
  pciutils \
  pinentry-gnome3 \
  plymouth \
  qt5-qtgraphicaleffects \
  qt5-qtquickcontrols2 \
  qt5-qtsvg \
  qt6-qtquickcontrols2 \
  qt6-qtsvg \
  rpm-build-libs \
  tuigreet

##########################################################
##### Firmware
##########################################################
RUN dnf5 install -y \
  alsa-firmware \
  alsa-sof-firmware \
  alsa-tools-firmware \
  intel-audio-firmware \
  intel-gpu-firmware \
  intel-igc \
  iwlwifi-dvm-firmware \
  iwlwifi-mvm-firmware \
  linux-firmware \
  realtek-firmware

##########################################################
##### Hyprland
##########################################################
RUN dnf5 -y copr enable solopasha/astal
RUN dnf5 -y copr enable solopasha/hyprland
RUN dnf5 -y install \
  appmenu-glib-translator \
  astal-devel \
  astal-gjs-devel \
  astal-gtk4-devel \
  astal-io-devel \
  astal-libs-devel \
  egl-wayland \
  grimblast \
  hypridle \
  hyprland-git \
  hyprland-git-debuginfo \
  hyprland-qt-support \
  hyprland-qtutils \
  hyprlock \
  hyprpaper \
  hyprpicker \
  hyprshot \
  hyprsunset \
  hyprwayland-scanner \
  ImageMagick \
  wf-recorder \
  wayland-protocols-devel \
  xdg-desktop-portal-hyprland
RUN dnf5 -y copr disable solopasha/astal
RUN dnf5 -y copr disable solopasha/hyprland

##########################################################
##### Connectivity
##########################################################
RUN dnf5 install -y \
  blueman \
  bluez \
  firewall-config \
  NetworkManager \
  NetworkManager-openvpn-gnome \
  network-manager-applet \
  tailscale
RUN dnf5 group install -y networkmanager-submodules

##########################################################
##### Display & Theming
##########################################################
RUN dnf5 -y copr enable heus-sueh/packages
RUN dnf5 install -y \
  brightnessctl \
  ddccontrol \
  ddccontrol-gtk \
  ddcutil \
  kanshi \
  matugen \
  terminus-fonts-console
RUN dnf5 -y copr disable heus-sueh/packages

##########################################################
##### Audio
##########################################################
RUN dnf5 install -y \
  alsa-plugins-oss \
  alsa-topology \
  alsa-utils \
  alsa-tools \
  inxi \
  pavucontrol \
  pamixer \
  pulseaudio-utils \
  mediainfo

##########################################################
##### Utilities
##########################################################
RUN dnf5 -y copr enable alternateved/cliphist
RUN dnf5 -y copr enable maximizerr/SwayAura
RUN dnf5 install -y \
  adobe-source-code-pro-fonts \
  cliphist \
  gdb \
  git \
  gh \
  google-noto-emoji-fonts \
  google-noto-sans-fonts \
  google-roboto-fonts \
  heif-pixbuf-loader \
  imv \
  jetbrains-mono-fonts \
  libheif \
  man \
  mpv \
  openssl \
  swappy \
  system-config-printer \
  tldr \
  udiskie \
  vulkan-validation-layers \
  vulkan-tools \
  wev
RUN dnf5 -y copr disable alternateved/cliphist
RUN dnf5 -y copr disable maximizerr/SwayAura

##########################################################
##### Terminal
##########################################################
RUN dnf5 -y copr enable atim/starship
RUN dnf5 -y copr enable atim/lazygit
RUN dnf5 -y copr enable pgdev/ghostty
RUN dnf5 install -y \
  bat \
  cava \
  distrobox \
  fastfetch \
  fzf \
  ghostty \
  git-delta \
  jq \
  lazygit \
  luarocks \
  pass \
  pass-otp \
  neovim \
  ripgrep \
  stow \
  starship \
  tldr \
  tmux \
  zoxide \
  zsh
RUN dnf5 -y copr disable atim/starship
RUN dnf5 -y copr disable atim/lazygit
RUN dnf5 -y copr disable pgdev/ghostty

###########################################################
###### Tools
###########################################################
RUN dnf5 -y copr enable playtron/gaming
RUN dnf5 install -y \
  dhcpcd \
  lshw \
  nmap \
  rsync \
  strace \
  tzupdate \
  wget
RUN dnf5 -y copr disable playtron/gaming

###########################################################
###### Applications
###########################################################
COPY files/repos /tmp/repos
RUN dnf5 -y config-manager addrepo --from-repofile /tmp/repos/1password.repo
RUN dnf5 install -y \
  1password \
  1password-cli
RUN dnf5 config-manager setopt 1password.enabled=0

##########################################################
##### Red Hat
##########################################################
COPY --from=vpn-configs /rpms /var/tmp/rpms/.
RUN dnf5 install -y \
  /var/tmp/rpms/redhat-internal-cert-install.rpm \
  /var/tmp/rpms/redhat-internal-NetworkManager-openvpn-profiles.rpm

##########################################################
##### Clean
##########################################################
RUN dnf5 clean all

###########################################################
###### Flathub
###########################################################
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

##########################################################
##### Extra modules
##########################################################
# https://projectatomic.io/blog/2018/06/building-kernel-modules-with-podman/
COPY --from=ddcci /usr/lib/modules/${KERNEL}/extra/ddcci.ko /usr/lib/modules/${KERNEL}/extra/ddcci.ko
COPY --from=ddcci /usr/lib/modules/${KERNEL}/extra/ddcci-backlight.ko /usr/lib/modules/${KERNEL}/extra/ddcci-backlight.ko
COPY --from=ddcci /usr/local/include/linux/ddcci.h /usr/local/include/linux/ddcci.h
RUN depmod ${KERNEL}

##########################################################
##### Files
##########################################################
COPY files/system/etc /etc
COPY files/system/usr /usr

##########################################################
##### Secrets
##########################################################
RUN mkdir -p /etc/secrets
RUN --mount=type=secret,id=container_auth cp /run/secrets/container_auth /usr/lib/container-auth.json
RUN chmod 0600 /usr/lib/container-auth.json
RUN ln -sr /usr/lib/container-auth.json /etc/ostree/auth.json

##########################################################
##### Services
##########################################################
RUN systemctl enable NetworkManager.service
RUN systemctl enable greetd.service
RUN systemctl enable podman.socket
RUN systemctl enable tailscaled.service

##########################################################
##### Mask
##########################################################
RUN systemctl mask rpm-ostree-countme.timer
RUN systemctl mask rpm-ostree-countme.service

LABEL summary="Hyprland for bootable containers"
LABEL description="The combination of a Fedora boot container and Hyprland compositor"
