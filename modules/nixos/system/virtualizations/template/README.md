# Virtual machine templates

This directory stores reference libvirt domain configurations for the current workstation. These files document manually maintained virtual-machine details; they are not imported by the NixOS module resolver or applied during rebuilds.

## Win11

[`win11.xml`](./win11.xml) is a snapshot of the current Windows 11 gaming VM.

| Item | Configuration |
| --- | --- |
| Machine | Q35, KVM, UEFI Secure Boot, TPM 2.0 |
| CPU | `host-passthrough`, 16 vCPUs, 1 socket / 8 cores / 2 threads |
| Memory | 32 GiB |
| System disk | `/home/libvirt-images/win11.qcow2`, VirtIO, 512 GiB logical capacity |
| Network | libvirt `default` NAT network with a VirtIO adapter |
| GPU | NVIDIA RTX 4060 GPU and HDMI audio at `01:00.0` and `01:00.1` via VFIO |
| Display | Physical NVIDIA output only; the emulated video device is disabled |
| Keyboard and mouse | evdev forwarding; left Shift + right Shift toggles host/guest ownership |
| Audio | Output-only ICH9 HDA device forwarded to the host PipeWire session with a 20 ms target latency |

The keyboard is the only evdev device configured with `grab="all"`. Its `shift-shift` hotkey toggles the keyboard and every other evdev input that does not set `grab`, including the mouse.

The virtual HDA output appears in Windows as `Speakers (High Definition Audio Device)`. QEMU exposes it as the `win11-audio` PipeWire stream, so Linux and Windows can play through the same host output device at the same time. NVIDIA HDMI audio remains available as a separate low-latency Windows output.

Before reusing the XML, check the disk and firmware paths, PipeWire runtime directory, evdev paths, PCI addresses, UUID, and MAC address. Most of these values are specific to the current workstation.
