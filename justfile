registry := "ghcr.io/kingsleyzissou"
qcow2 := "/scratch/VMs/test.qcow2"

# Build the base container image
base:
    sudo podman build \
        --platform linux/amd64 \
        --tag {{ registry }}/hyprland-base:latest \
        --file Containerfile.base .

# Build the desktop container image
desktop:
    sudo podman build \
        --platform linux/amd64 \
        --secret id=container_auth,src=/etc/ostree/auth.json,type=file \
        --tag {{ registry }}/hyprland-desktop:latest \
        --file Containerfile.desktop .

# Build the dev container image
dev:
    sudo podman build \
        --platform linux/amd64 \
        --tag {{ registry }}/hyprland:latest \
        --file Containerfile.dev .

# Build all images
container: base desktop dev

# Build an anaconda ISO image
image:
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v ./config.toml:/config.toml \
        -v ./output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        localhost/bib \
        --type anaconda-iso \
        --target-arch x86_64 \
        --config /config.toml \
        --rootfs xfs \
        {{ registry }}/hyprland && sudo chown kingsley: -R ./output

# Boot a qcow2 image in QEMU
vm-qcow2 image:
    qemu-system-x86_64 -smp 8 \
        -m 16G \
        -enable-kvm \
        -hda {{ image }} \
        -device virtio-net-pci,netdev=n0,mac=FE:0B:6E:22:3D:00 \
        -netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:80 \
        -serial mon:stdio

# Boot an ISO in QEMU
vm-iso iso:
    rm -f {{ qcow2 }}
    qemu-img create {{ qcow2 }} 25G
    qemu-system-x86_64 -smp 8 \
        -m 16G \
        -enable-kvm \
        -boot d -cdrom {{ iso }} \
        -hda {{ qcow2 }} \
        -device virtio-net-pci,netdev=n0,mac=FE:0B:6E:22:3D:00 \
        -netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:80 \
        -serial mon:stdio
