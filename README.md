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

## Enabled Packages & Functions Comparison

This table compares the features enabled by both seed configurations.

| CR6606 | TR3000 | Feature | Purpose | Notes |
| --- | --- | --- | --- | --- |
| ✅ | ✅ | LuCI Web UI + themes | Web management with themes (Bootstrap/Argon/Material + Chinese UI) | |
| ✅ | ✅ | Web server (LuCI) | Serves LuCI over HTTP with uHTTPd | |
| ✅ | ✅ | Wireless | Wi-Fi 6 support with MT7915E driver, regulatory database (wireless-regdb), and WPA2/3 (wpad-openssl) | |
| ✅ | ✅ | QoS (nftables) | Simple bandwidth/QoS rules with nft-qos + Chinese UI | |
| ✅ | ✅ | Diagnostics | Basic troubleshooting tools (iperf3, tcpdump, htop) | |
| ✅ | ✅ | Web terminal | Shell access in browser (ttyd) + Chinese UI | |
| ✅ | ✅ | Local discovery | mDNS/Bonjour and name resolution (Avahi, nss-mdns) | |
| ✅ | ✅ | UPnP IGD | Auto port forwarding (miniupnpd-nftables) + Chinese UI | |
| ✅ | ✅ | DoH via Cloudflared | DNS over HTTPS tunnel with LuCI UI + Chinese UI | |
| ✅ | ✅ | HTTPS DNS Proxy | Lightweight DoH client with LuCI UI + Chinese UI | |
| ✅ | ✅ | SmartDNS | Fast DNS with filtering and cache + Chinese UI | |
| ✅ | ✅ | Adblock | DNS-based ad/malware blocking + Chinese UI | |
| ✅ | ✅ | DNS/DHCP backend | Full-featured dnsmasq (DNSSEC, DHCPv6, TFTP, auth) | |
| ✅ | ✅ | TLS/crypto | OpenSSL TLS backend (curl/wget-ssl) with system OpenSSL config | |
| ✅ | ✅ | IPv6 support | DHCPv6 and IPv6 DHCP services (odhcp6c, odhcpd) | |
| ✅ | ✅ | Firewall | nftables-based firewall4 | |
| ✅ | ✅ | CA certificates | Root certificate bundle for TLS validation | |
| ✅ | ✅ | DNS tools | BIND client tools (host, dig) with DoH support | |
| ✅ | ✅ | Online Users | Show online client list + Chinese UI | |
| ✅ | ✅ | Package Manager UI | Manage packages in LuCI + Chinese UI | |
| ✅ | ✅ | Temperature monitoring | System temperature status in LuCI | TR3000: CPU + Wi‑Fi; CR6606: Wi‑Fi only |
| ✅ | ✅ | Push notifications | Push notification service (luci-app-pushbot) | |
| ✅ | ✅ | Network tools | socat with LuCI interface + Chinese UI | |
| ✅ | ✅ | Advanced networking | Extensive networking tools (curl, wget, arping, etc.) | |
| ✅ | ✅ | Editor (vim) | Full-featured CLI editor | |
| ❌ | ✅ | File sharing | Samba4 server with Avahi, NetBIOS, VFS, and WSDD2 + Chinese UI | |
| ❌ | ✅ | USB printing | Print server (p910nd JetDirect) with LuCI UI + Chinese UI | |
| ❌ | ✅ | Disk management | LuCI disk manager with Btrfs, NTFS3 support + Chinese UI | CR6606 lacks USB ports |
| ❌ | ✅ | Storage & filesystems | Full filesystem support (ext4, Btrfs, exFAT, NTFS3) | CR6606 lacks USB ports |
| ❌ | ✅ | USB networking | Extensive USB-to-Ethernet adapter support | CR6606 lacks USB ports |
| ❌ | ✅ | USB tools | USB utilities and device identification | CR6606 lacks USB ports |
| ❌ | ✅ | File manager | Web file manager in LuCI + Chinese UI | CR6606 lacks USB ports |



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
