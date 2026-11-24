# imx6ull-mini-linux

正点原子 **i.MX6ULL Mini** 的 **Linux 7.3.6**（stable，2026-11-23）移植。

仓库只放板级配置与脚本：`.config` 是从旧固件 IKCFG 段反推出的真实配置，DTS 从旧 dtb 反编译校正后
按上游风格重写。产物 `zImage` + `imx6ull-alientek-mini-4.3.dtb`，DTB 与旧固件逐字节一致。

## 快速开始

```bash
sudo apt install build-essential bison flex bc libssl-dev gcc-arm-linux-gnueabihf
git clone https://github.com/xuliyan0099/imx6ull-mini-linux.git
cd imx6ull-mini-linux
bash tools/build.sh          # 首次自动下载 linux-7.3.6.tar.xz 并校验 sha256
```

产物：`out/zImage`（10,103,928 B）、`out/imx6ull-alientek-mini-4.3.dtb`（34,692 B，sha256 `1a41ee56…f95f9a`）。

## 板级要点（`board/`）

`imx6ull-alientek-mini-4.3.dts` 与上游 `imx6ull-14x14-evk` 的差异：

| 项 | 设置 |
| --- | --- |
| LCD | ATK-4.3 RGBLCD 800×480，pixclk 31.5 MHz，`mxsfb` + `pwm-backlight` + `GPIO1_IO08` 背光 |
| 触摸 | GT911 @ I2C1 `0x5d`，`reset-gpios`/`int-gpios` 按 Mini 排针 |
| 网络 | FEC `eth0`，KSZ8081 PHY，RMII |
| 存储 | `usdhc1` → SD，`usdhc2` → eMMC（8 bit） |
| 串口 | `uart1` = `ttymxc0` 115200 作为 console |

`kernel.config` 关键开关：`CONFIG_SOC_IMX6UL=y`、`DRM_MXS/DRM_MXSFB/DRM_FBDEV_EMULATION=y`、
`TOUCHSCREEN_GOODIX=y`、`INPUT_EVDEV=y`、`FEC=y`、`MMC_SDHCI_ESDHC_IMX=y`、
`BLK_DEV_INITRD=y`、`RD_GZIP=y`。

> 注意：DTS 的 Makefile 注册用的是 `CONFIG_SOC_IMX6UL`（不是 `SOC_IMX6ULL`），find-replace 时别改成后者。

## 验证

- QEMU（统一虚拟开发板）：`Linux version 7.3.6`、`imx6ull-mini: rootfs ready`、`ttymxc0` 出 shell。
- 真板：与 U-Boot 的 BOOTCOMMAND 对应，`/boot/zImage` + `/boot/imx6ull-alientek-mini-4.3.dtb`。
- DTB sha256 与旧固件一致，说明设备树还原无误。

## 环境变量

| 变量 | 默认 | 用途 |
| --- | --- | --- |
| `IM6_SRC` | `./src` | 源码目录 |
| `IM6_LX_URL` / `IM6_LX_FILE` | kernel.org / — | 镜像地址 / 本地 tar.xz |
| `IM6_CROSS` | `arm-linux-gnueabihf-` | 交叉前缀 |
| `IM6_JOBS` | `nproc` | 并行度 |

许可：板级配置与 DTS 按 MIT；内核本体 GPL-2.0。
