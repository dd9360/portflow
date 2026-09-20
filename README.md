# PortFlow (`pf`)

Linux 服务端口限速工具。`pf` 打开中文数字菜单：选 `1`，输入端口（如 `50000`），再输入限速（如 `15`），即把该端口上传和下载各自限制到 **15 Mbit/s**，完成后自动返回主菜单。支持删除规则和查看端口流量统计。不包含端口转发。适用于 Linux 服务器上的本机服务端口。

## 安装（大陆机器无需访问 GitHub）

能访问 GitHub 的 Linux 服务器可直接一键安装：

```bash
curl -fsSL https://raw.githubusercontent.com/dd9360/portflow/main/quick-install.sh | sudo bash
```

执行前可先打开脚本核对内容。该命令需要服务器能连接 `raw.githubusercontent.com`。如已将项目文件托管到自己信任的镜像，可设置 `PF_BASE_URL` 为镜像目录地址后运行 `quick-install.sh`；下面的离线安装完全不需要 GitHub。

在能访问本项目的电脑上下载仓库 ZIP，解压后把整个 `portflow` 目录用 SCP、SFTP 等传到服务器。服务器执行：

```bash
cd portflow
sudo bash install.sh
sudo pf
```

安装包自包含；安装与之后的增删改、开机恢复均不请求 GitHub。依赖 Linux `iproute2` 的 `tc` 和 `ip`；请在服务器上预先安装。也可以在有 GitHub 访问能力的 Linux 上克隆后运行相同命令。更新时重新传输目录并运行 `sudo bash install.sh`。

## 用法

```bash
sudo pf                       # 交互菜单
sudo pf add 443 15            # 443 TCP+UDP 上传/下载各 15 Mbps
sudo pf add 8443 10 20 tcp    # 8443 TCP 上传 10、下载 20 Mbps
sudo pf del 443               # 删除端口规则
sudo pf list                  # 查看保存的规则
sudo pf traffic               # 查看端口上传、下载流量累计
sudo pf interface eth0        # 手动选网卡（默认使用 IPv4 默认路由网卡）
sudo pf apply                 # 重载规则
```

速率单位为 **Mbit/s (Mbps)**，15 Mbps 约等于 1.875 MB/s。上传指服务器发出的流量（源端口），下载指服务器收到的流量（目的端口）。单个端口每个方向的 TCP、UDP、IPv4、IPv6 共用一个限速桶。规则位于 `/etc/portflow/rules.tsv`，仅 root 可写。systemd 系统上安装程序启用开机恢复服务。

流量统计读取 `tc` 的每端口上传、下载计数器，显示 MiB 累计值。它从最近一次规则应用开始计数，添加或删除端口、重载规则以及服务器重启都会清零；它不是历史账单。

## 注意

- 使用 Linux `tc` 的 `clsact` 和 `police`，超出速率的包会被丢弃；TCP 会通过拥塞控制降低速率，UDP 可能丢包。突发缓冲为 256 KiB，因此短时测速可能超过设定值。
- 在公网接口匹配**本机服务端口**，对转发、NAT、容器映射端口或多网卡流量，须按实际进入/离开的网卡与端口核对；不支持多个网卡同时限速。
- 脚本仅管理 `tc` ingress/egress 优先级 42424（IPv4）和 42425（IPv6）。若网卡已有使用这些优先级的过滤器，请勿安装；`clsact` 本身不会被卸载。已有的其他限速策略仍可能影响最终速度。
- 修改网卡或应用规则期间可能有极短暂的不限速窗口。先在非关键端口验证，再用于生产流量。

项目采用 MIT 许可证。
