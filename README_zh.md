# ImmortalWrt 固件构建器

[![ImmortalWrt Builder](https://github.com/coachpo/immortalwrt-firmware-builder/actions/workflows/builder.yml/badge.svg?branch=main)](https://github.com/coachpo/immortalwrt-firmware-builder/actions/workflows/builder.yml)
[![Latest Release](https://img.shields.io/github/v/release/coachpo/immortalwrt-firmware-builder?sort=semver&style=flat-square&label=Release&logo=github)](https://github.com/coachpo/immortalwrt-firmware-builder/releases/latest)
[![Downloads (latest)](https://img.shields.io/github/downloads/coachpo/immortalwrt-firmware-builder/latest/total?style=flat-square&label=Downloads&logo=github)](https://github.com/coachpo/immortalwrt-firmware-builder/releases/latest)

[English](README.md) | 简体中文

用于从固定版本构建并（可选）发布 Cudy TR3000 和小米 CR6606 的 ImmortalWrt 固件的种子配置与 GitHub Actions 工作流。

- Cudy TR3000 (Filogic)
- Xiaomi CR6606 (MT7621)

每个 `seed.config` 都用于复制到源码树根目录，通过 `make defconfig` 展开为完整的 `.config`。在编译前，你也可以通过 `make menuconfig` 进行交互式调整。

## 快速开始
在全新的 ImmortalWrt（或 OpenWrt）源码树根目录执行：

```bash
# 1. 克隆源码（示例）
git clone https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt
./scripts/feeds update -a && ./scripts/feeds install -a

# 2. 选择一个机型将种子配置放为 .config
mv /path/to/immortalwrt-firmware-builder/tr3000/seed.config .config    # TR3000 功能更全面
# 或
mv /path/to/immortalwrt-firmware-builder/cr6606/seed.config .config    # CR6606 轻量

# 3. 展开默认配置
make defconfig

# 4.（可选）交互式调整
make menuconfig

# 5. 编译
make -j"$(nproc)" V=sc
```

编译完成后的固件镜像会生成在 `bin/targets/<target>/<subtarget>/` 目录下。

## 启用的包与功能对比

下表对比了两个种子配置启用的功能。

| CR6606 | TR3000 | 功能 | 用途 | 备注 |
| --- | --- | --- | --- | --- |
| ✅ | ✅ | LuCI Web UI + 主题 | 通过主题（Bootstrap/Argon + 中文界面）进行 Web 管理 | |
| ✅ | ✅ | Web 服务器（LuCI） | 使用 uHTTPd 提供 LuCI 服务 | |
| ✅ | ✅ | 无线 | Wi‑Fi 6 支持（MT7915E 驱动、regdb）与 WPA2/3（wpad-openssl） | |
| ✅ | ✅ | QoS（基于 nftables） | 使用 nft-qos 的简单带宽/QoS 管理（+ 中文界面） | |
| ✅ | ✅ | 诊断 | 基础排障工具（iperf3、tcpdump、htop） | |
| ✅ | ✅ | Web 终端 | 浏览器内 Shell（ttyd，含中文界面） | |
| ✅ | ✅ | 本地发现 | mDNS/Bonjour 与名称解析（Avahi、nss-mdns） | |
| ✅ | ✅ | UPnP IGD | 自动端口转发（miniupnpd-nftables + 中文界面） | |
| ✅ | ✅ | 通过 Cloudflared 的 DoH | DNS over HTTPS 隧道，含 LuCI UI（中文） | |
| ✅ | ✅ | HTTPS DNS Proxy | 轻量级 DoH 客户端，含 LuCI UI（中文） | |
| ✅ | ✅ | 广告拦截 | 基于 DNS 的广告/恶意域名拦截（中文界面） | |
| ✅ | ✅ | DNS/DHCP 后端 | 功能完整的 dnsmasq（DNSSEC、DHCPv6、TFTP、权威） | |
| ✅ | ✅ | TLS/加密 | OpenSSL TLS 后端（curl/wget-ssl），系统级 OpenSSL 配置 | |
| ✅ | ✅ | IPv6 支持 | DHCPv6 与 IPv6 DHCP 服务（odhcp6c、odhcpd） | |
| ✅ | ✅ | 防火墙 | 基于 nftables 的 firewall4 | |
| ✅ | ✅ | CA 证书 | 根证书集合用于 TLS 校验 | |
| ✅ | ✅ | 软件包管理器 UI | 在 LuCI 中管理软件包（中文界面） | |
| ✅ | ✅ | 网络工具 | socat 及其 LuCI 界面（中文） | |
| ✅ | ✅ | 高级网络工具 | 丰富的网络工具（curl、wget、arping 等） | |
| ✅ | ✅ | 编辑器（vim） | 功能完善的命令行编辑器 | |
| ✅ | ❌ | TurboAcc | NAT、流卸载和SFE的硬件加速 | TR3000 无需此解决方案 |
| ❌ | ✅ | 文件共享 | Samba4 服务器（含 Avahi、NetBIOS、VFS、WSDD2 + 中文界面） | CR6606 无 USB 接口 |
| ❌ | ✅ | USB 打印 | 打印服务器（p910nd JetDirect）及 LuCI UI（中文） | CR6606 无 USB 接口 |
| ❌ | ✅ | 磁盘管理 | LuCI 磁盘管理（Btrfs、NTFS3 支持 + 中文界面） | CR6606 无 USB 接口 |
| ❌ | ✅ | 存储与文件系统 | 完整的文件系统支持（ext4、Btrfs、exFAT、NTFS3） | CR6606 无 USB 接口 |
| ❌ | ✅ | USB 网络 | 广泛的 USB 转以太网适配器支持 | CR6606 无 USB 接口 |
| ❌ | ✅ | USB 工具 | USB 工具与设备识别 | CR6606 无 USB 接口 |
| ❌ | ✅ | 文件管理器 | LuCI Web 文件管理器（中文界面） | CR6606 无 USB 接口 |


## 许可证

本项目使用 MIT 许可证 - 详情见 [LICENSE](LICENSE) 文件。


