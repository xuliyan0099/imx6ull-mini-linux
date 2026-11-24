#!/usr/bin/env bash
# 编译内核，产物 out/zImage 与 out/imx6ull-alientek-mini-4.3.dtb。
#   bash tools/build.sh
# 环境变量：IM6_SRC / IM6_CROSS / IM6_JOBS
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${IM6_SRC:-$ROOT/src}
CROSS=${IM6_CROSS:-arm-linux-gnueabihf-}
JOBS=${IM6_JOBS:-$(nproc)}
OUT=$ROOT/out

command -v "${CROSS}gcc" >/dev/null || { echo "缺少 ${CROSS}gcc" >&2; exit 1; }
[ -f "$SRC/linux/Makefile" ] || bash "$ROOT/tools/fetch.sh"

mkdir -p "$OUT"
make -C "$SRC/linux" ARCH=arm CROSS_COMPILE="$CROSS" olddefconfig
make -C "$SRC/linux" ARCH=arm CROSS_COMPILE="$CROSS" -j"$JOBS" zImage dtbs

cp "$SRC/linux/arch/arm/boot/zImage" "$OUT/zImage"
cp "$SRC/linux/arch/arm/boot/dts/nxp/imx/imx6ull-alientek-mini-4.3.dtb" "$OUT/"

echo
ls -l "$OUT"
sha256sum "$OUT"/*
