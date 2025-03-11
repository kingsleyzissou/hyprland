.PHONY : container
container:
	sudo podman build \
		--secret id=container_auth,src=/home/kingsley/.gat,type=file \
		--tag ghcr.io/kingsleyzissou/hyprland .

.PHONY : image
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
		ghcr.io/kingsleyzissou/hyprland && sudo chown kingsley: -R ./output

.PHONY : vm/qcow2
vm/qcow2:
	qemu-system-x86_64 -smp 8 \
		-m 16G \
		-enable-kvm \
		-hda $(image) \
		-device virtio-net-pci,netdev=n0,mac=FE:0B:6E:22:3D:00 \
		-netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:80 \
		-serial mon:stdio

.PHONY : vm/iso
QCOW2 = /scratch/VMs/test.qcow2
vm/iso:
	rm -f $(QCOW2)
	qemu-img create $(QCOW2) 25G
	qemu-system-x86_64 -smp 8 \
		-m 16G \
		-enable-kvm \
		-boot d -cdrom $(iso) \
		-hda $(QCOW2) \
		-device virtio-net-pci,netdev=n0,mac=FE:0B:6E:22:3D:00 \
		-netdev user,id=n0,net=10.0.2.0/24,hostfwd=tcp::2222-:22,hostfwd=tcp::8000-:80 \
		-serial mon:stdio
