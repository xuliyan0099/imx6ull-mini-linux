#!/usr/bin/env bash
# 拉 Linux 7.3.6 到 src/linux，校验 sha256，套上板级 .config 与 DTS 并在 Makefile 注册。
#   bash tools/fetch.sh
# 环境变量：IM6_SRC / IM6_LX_URL / IM6_LX_FILE / IM6_FORCE=1
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=${IM6_SRC:-$ROOT/src}
LX_VER=7.3.6
LX_SHA=8183d475a76a0faffa92d6cd500af421f589dfd0300a0f1060bb875e11d45723
LX_URL=${IM6_LX_URL:-https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-$LX_VER.tar.xz}
: "${IM6_FORCE:=0}"

mkdir -p "$SRC"

if [ ! -f "$SRC/linux/Makefile" ] || [ "$IM6_FORCE" = 1 ]; then
  echo "== 下载 Linux $LX_VER =="
  rm -rf "$SRC/linux" "$SRC/linux-$LX_VER"
  TMP=$(mktemp -d)
  if [ -n "${IM6_LX_FILE:-}" ]; then
    cp "$IM6_LX_FILE" "$TMP/linux.tar.xz"
  else
    ok=0
    for u in "$LX_URL" "https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-$LX_VER.tar.xz"; do
      echo "   下载 $u"
      if curl -fL --retry 3 --connect-timeout 20 -o "$TMP/linux.tar.xz" "$u"; then ok=1; break; fi
    done
    [ "$ok" = 1 ] || { echo "!! 下载失败，可手动下载后用 IM6_LX_FILE 指定" >&2; exit 1; }
  fi
  echo "$LX_SHA  $TMP/linux.tar.xz" | sha256sum -c -
  tar -xJf "$TMP/linux.tar.xz" -C "$SRC"
  mv "$SRC/linux-$LX_VER" "$SRC/linux"
  rm -rf "$TMP"
else
  echo "== 复用已有 Linux 源码 =="
fi

cp "$ROOT/board/kernel.config" "$SRC/linux/.config"
cp "$ROOT/board/imx6ull-alientek-mini-4.3.dts" "$SRC/linux/arch/arm/boot/dts/nxp/imx/"
MK=$SRC/linux/arch/arm/boot/dts/nxp/imx/Makefile
if ! grep -q 'imx6ull-alientek-mini-4.3.dtb' "$MK"; then
  sed -i 's#^\timx6ull-14x14-evk.dtb \\#\timx6ull-14x14-evk.dtb \\\n\timx6ull-alientek-mini-4.3.dtb \\#' "$MK"
  echo "   设备树已在 Makefile 注册"
fi

echo "源码就绪：$SRC/linux"
