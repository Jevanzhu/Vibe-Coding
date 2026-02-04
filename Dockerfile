# 使用 Debian 12 (Bookworm) 作为基础镜像
FROM debian:bookworm-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV NODE_VERSION=20.x
ENV SHELL=/bin/bash

# 工作目录
WORKDIR /workspace

# Step 1: 先安装基础工具（使用默认源）
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl

# Step 2: 更换为腾讯云软件源（使用 HTTP）
RUN rm -f /etc/apt/sources.list.d/debian.sources
RUN echo "deb http://mirrors.cloud.tencent.com/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list
RUN echo "deb http://mirrors.cloud.tencent.com/debian/ bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.cloud.tencent.com/debian/ bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.cloud.tencent.com/debian-security/ bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# Step 3: 更新软件源
RUN apt-get update

# Step 4: 安装基础工具
RUN apt-get install -y --no-install-recommends curl wget git

# Step 5: 安装编辑器工具
RUN apt-get install -y --no-install-recommends vim nano htop tree

# Step 6: 安装系统工具
RUN apt-get install -y --no-install-recommends gnupg lsb-release

# Step 7: 安装 SSH 服务
RUN apt-get install -y --no-install-recommends openssh-server

# Step 8: 安装网络工具
RUN apt-get install -y --no-install-recommends net-tools iputils-ping dnsutils

# Step 9: 安装构建工具
RUN apt-get install -y --no-install-recommends build-essential cmake make gcc g++

# Step 10: 安装编译工具
RUN apt-get install -y --no-install-recommends automake autoconf libtool pkg-config

# Step 11: 安装 Python
RUN apt-get install -y --no-install-recommends python3 python3-pip python3-venv python3-dev

# Step 12: 安装 Python 依赖库
RUN apt-get install -y --no-install-recommends libffi-dev libssl-dev zlib1g-dev libbz2-dev

# Step 13: 安装更多 Python 依赖
RUN apt-get install -y --no-install-recommends libreadline-dev libsqlite3-dev libncurses-dev

# Step 14: 安装其他工具
RUN apt-get install -y --no-install-recommends xz-utils tk-dev libxml2-dev libxmlsec1-dev

# Step 15: 清理
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Step 16: 配置 SSH
RUN mkdir /var/run/sshd
RUN echo 'root:vibecoding' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Step 17: 安装 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 18: 配置 pip 腾讯云镜像
RUN mkdir -p /root/.config/pip
RUN echo "[global]" > /root/.config/pip/pip.conf
RUN echo "index-url = http://mirrors.cloud.tencent.com/pypi/simple/" >> /root/.config/pip/pip.conf
RUN echo "trusted-host = mirrors.cloud.tencent.com" >> /root/.config/pip/pip.conf

# Step 19: 升级 pip
RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages

# Step 20: 安装 pm2
RUN npm install -g pm2

# Step 21: 创建 Dev 用户
RUN useradd -m -s /bin/bash Dev
RUN usermod -aG sudo Dev
RUN echo "Dev:vibecoding" | chpasswd
RUN echo "Dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Step 22: 创建工作目录
RUN mkdir -p /workspace && chown -R Dev:Dev /workspace

# Step 23: 切换到 Dev 用户安装 Claude Code
USER Dev
RUN curl -fsSL https://claude.ai/install.sh | bash

# Step 24: 安装 OpenCode
RUN curl -fsSL https://opencode.ai/install | bash

# Step 25: 创建配置目录
RUN mkdir -p ~/.config/claude ~/.config/opencode ~/.config/pip
RUN echo "[global]" > ~/.config/pip/pip.conf
RUN echo "index-url = http://mirrors.cloud.tencent.com/pypi/simple/" >> ~/.config/pip/pip.conf
RUN echo "trusted-host = mirrors.cloud.tencent.com" >> ~/.config/pip/pip.conf

# Step 26: 设置工作目录
WORKDIR /workspace

# Step 27: 切回 root 创建软链接
USER root
RUN ln -sf /home/Dev/.local/bin/claude /usr/local/bin/claude
RUN ln -sf /home/Dev/.opencode/bin/opencode /usr/local/bin/opencode

# Step 28: 暴露端口
EXPOSE 22 3000 5000 8000 8080

# Step 29: 启动 SSH
CMD ["/usr/sbin/sshd", "-D"]
