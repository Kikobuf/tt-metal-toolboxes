# Host Configuration

Tenstorrent boards are discrete PCIe accelerators with their own on-card DRAM —
there is no unified/shared-memory GTT tuning like Strix Halo or Intel iGPUs need.
Host setup is entirely about kernel driver, firmware, and (for multi-card
systems) eth topology.

## 1. Install the driver + firmware stack

Do this on the **host**, not inside the container. The container only needs
`/dev/tenstorrent` passed through.

```bash
curl -fsSL https://github.com/tenstorrent/tt-installer/releases/download/v2.1.0/install.sh -O
chmod +x install.sh
./install.sh --install-container-runtime=no
```

`--install-container-runtime=no` is used because these toolboxes assume you
already have `toolbox`/`distrobox`/`podman`/`docker` set up separately.

## 2. Pin explicit versions for Galaxy / Blackhole

```bash
./install.sh \
  --smi-version=v5.0.0 \
  --fw-version=19.8.1 \
  --kmd-version=2.8.0 \
  --install-container-runtime=no
```

Check the [Driver / Firmware Compatibility table](../README.md#driver--firmware-compatibility)
in the main README to match versions to the `tt-metal` release you plan to run.

## 3. CPU performance governor

For consistent inference throughput, set the host CPU governor to `performance`
(this can also be done inside the container if you have the right privileges,
but doing it on the host is more reliable):

```bash
sudo apt-get install cpufrequtils
sudo cpupower frequency-set -g performance
```

## 4. Multi-card systems (QuietBox / LoudBox / Galaxy)

Configure eth routing with TT-Topology before the container will correctly see
all chips:

```bash
# see https://github.com/tenstorrent/tt-topology for full usage
tt-topology -l
```

## 5. Virtual machines

If Tenstorrent hardware is passed through to a VM:

- Host kernel needs IOMMU enabled: `intel_iommu=on` or `amd_iommu=on`
- Hypervisor must expose a vIOMMU to the guest
- vIOMMU must support DMA remapping (Intel VT-d / AMD-Vi)

Missing vIOMMU support is the most common cause of "device passthrough works
on bare metal, fails in the VM" reports.

## 6. Verifying the setup

Once the host stack is installed, confirm the board is visible before ever
touching a container:

```bash
tt-smi
```

You should see board type, firmware version, and driver version. If this
fails on bare metal, no container configuration will fix it — the problem is
upstream of the toolbox entirely.
