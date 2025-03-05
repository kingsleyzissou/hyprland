FROM quay.io/fedora/fedora-bootc:41

##########################################################
##### Core #####
##########################################################
RUN dnf5 install -y \
  adwaita-qt6 \
  dnf5-plugins \
  gtk-murrine-engine \
  flatpak \
  pinentry-gnome3 \
  krb5-workstation \
  qt5-qtgraphicaleffects \
  qt5-qtquickcontrols2 \
  qt5-qtsvg \
  qt6-qtquickcontrols2 \
  qt6-qtsvg \
  rpm-build-libs \
  sddm \
  sddm-themes

##########################################################
##### Hyprland
##########################################################
RUN dnf5 -y copr enable solopasha/astal
RUN dnf5 -y copr enable solopasha/hyprland
RUN dnf5 -y install \
  astal \
  astal-io \
  grimblast \
  hypridle \
  hyprland \
  hyprland-qt-support \
  hyprland-qtutils \
  hyprlock \
  hyprpaper \
  hyprpicker \
  hyprshot \
  hyprsunset \
  ImageMagick \
  wf-recorder \
  xdg-desktop-portal \
  xdg-desktop-portal \
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
  matugen
RUN dnf5 -y copr disable heus-sueh/packages

##########################################################
##### Audio
##########################################################
RUN dnf5 install -y \
  pavucontrol \
  mediainfo

##########################################################
##### Utilities
##########################################################
RUN dnf5 config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
RUN dnf5 -y copr enable alternateved/cliphist
RUN dnf5 -y copr enable maximizerr/SwayAura
RUN dnf5 install -y \
  alsa-firmware \
  cliphist \
  git \
  google-noto-emoji-fonts \
  google-noto-sans-fonts \
  google-roboto-fonts \
  heif-pixbuf-loader \
  imv \
  jetbrains-mono-fonts \
  libheif \
  openssl \
  swappy \
  system-config-printer \
  udiskie \
  vulkan-validation-layers \
  vulkan-tools
RUN dnf5 config-manager setopt gh-cli.enabled=0
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
###### Applications
###########################################################
COPY files/repos /tmp/repos
RUN dnf5 -y config-manager addrepo --from-repofile /tmp/repos/1password.repo
RUN dnf5 install -y \
  1password \
  1password-cli
RUN dnf5 config-manager setopt 1password.enabled=0

###########################################################
###### Flathub
###########################################################
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

##########################################################
##### Red Hat
##########################################################
RUN dnf5 -y copr enable copr.devel.redhat.com/@endpoint-systems-sysadmins/unsupported-fedora-packages
RUN dnf5 install -y \
redhat-internal-cert-install \
redhat-internal-NetworkManager-openvpn-profiles \
redhat-internal-print-server-selector
RUN dnf5 -y copr disable copr.devel.redhat.com/@endpoint-systems-sysadmins/unsupported-fedora-packages

##########################################################
##### Clean
##########################################################
RUN dnf5 clean all

##########################################################
##### Files
##########################################################
COPY files/system/etc /etc
COPY files/system/usr /usr

##########################################################
##### Secrets
##########################################################
RUN mkdir -p /etc/secrets
RUN --mount=type=secret,id=container_auth \
 jq -n --arg authkey $(cat /run/secrets/container_auth) \
   '{auths: { "ghcr.io": { auth: $authkey }}}' > /etc/ostree/auth.json

##########################################################
##### Services
##########################################################
RUN systemctl enable podman.socket
RUN systemctl enable sddm.service

LABEL summary="Hyprland for bootable containers"
LABEL description="The combination of a Fedora boot container and Hyprland compositor"
