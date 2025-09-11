# ImmortalWrt Seed Configurations 

- Cudy TR3000 (Filogic) 
- Xiaomi CR6606 (MT7621)

Each `seed.config` is meant to be copied to a build tree and expanded via `make defconfig` to produce a full `.config`. You can then adjust options interactively with `make menuconfig` before compiling.

## Quick Start
From a fresh ImmortalWrt (or OpenWrt) source tree root:

```bash
# 1. Clone sources (example)
git clone https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt
./scripts/feeds update -a && ./scripts/feeds install -a

# 2. Place one seed config as .config (choose a profile)
mv /path/to/ImmortalWrt_config/tr3000/seed.config .config    # TR3000 feature-rich
# or
mv /path/to/ImmortalWrt_config/cr6606/seed.config .config    # CR6606 lean

# 3. Expand defaults
make defconfig

# 4. (Optional) Adjust interactively
make menuconfig

# 5. Build
make -j"$(nproc)" V=sc
```

Resulting firmware images will appear under `bin/targets/<target>/<subtarget>/`.

## License
This project is released under the MIT License. See the `LICENSE` file in the repository root for full text.