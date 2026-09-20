#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo '请使用 sudo bash install.sh' >&2; exit 1; }
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
[[ -f $DIR/pf ]] || { echo '安装包缺少 pf 文件。' >&2; exit 1; }
command -v tc >/dev/null && command -v ip >/dev/null || { echo '请先安装 iproute2（Ubuntu/Debian: apt install iproute2；RHEL: dnf install iproute）。' >&2; exit 1; }
install -m 755 "$DIR/pf" /usr/local/bin/pf
if command -v systemctl >/dev/null; then
  install -m 644 "$DIR/portflow.service" /etc/systemd/system/portflow.service
  systemctl daemon-reload
  systemctl enable portflow.service
fi
/usr/local/bin/pf apply
echo '安装完成。运行 sudo pf 打开菜单；sudo pf add 443 15 可直接配置。'
