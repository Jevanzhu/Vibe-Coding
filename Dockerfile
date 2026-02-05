# Vibe Coding DevBox - 国外源默认版
# 基于 Debian 13 (Trixie) 构建
FROM debian:trixie-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NODE_VERSION=20.x \
    SHELL=/bin/bash

# 设置工作目录
WORKDIR /workspace

# Step 1: 安装系统依赖
# 包含：SSH服务、Python、Node.js、构建工具等
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # 基础工具
        ca-certificates curl wget git \
        vim nano htop tree \
        gnupg lsb-release sudo \
        # SSH服务
        openssh-server \
        # 网络工具
        net-tools iputils-ping dnsutils \
        # 编译工具链
        build-essential cmake make gcc g++ \
        automake autoconf libtool pkg-config \
        # Python环境
        python3 python3-pip python3-venv python3-dev \
        libffi-dev libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev libncurses-dev \
        # 其他依赖
        xz-utils tk-dev libxml2-dev libxmlsec1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Step 2: 配置 SSH服务
# 允许root登录和密码认证（生产环境建议改为密钥认证）
RUN mkdir -p /var/run/sshd && \
    echo 'root:vibecoding' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Step 3: 安装 Node.js (v20 LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Step 4: 升级 pip 并安装 pm2
RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages && \
    npm install -g pm2

# Step 5: 创建 Dev 用户
# 配置sudo免密，创建工作目录
RUN useradd -m -s /bin/bash Dev && \
    usermod -aG sudo Dev && \
    echo 'Dev:vibecoding' | chpasswd && \
    echo 'Dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /workspace && \
    chown -R Dev:Dev /workspace

# Step 6: 安装 AI 编程助手 (Claude Code + OpenCode)
USER Dev
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    curl -fsSL https://opencode.ai/install | bash && \
    mkdir -p ~/.config/claude ~/.config/opencode

# Step 7: 最终配置
# 创建全局命令软链接
WORKDIR /workspace
USER root
RUN ln -sf /home/Dev/.local/bin/claude /usr/local/bin/claude && \
    ln -sf /home/Dev/.opencode/bin/opencode /usr/local/bin/opencode

# Step 8: 切换到国内镜像源（方便在国内使用）
# 使用 Debian 13 推荐的 deb822 格式配置腾讯云镜像
RUN rm -f /etc/apt/sources.list && \
    mkdir -p /etc/apt/sources.list.d && \
    echo 'Types: deb' > /etc/apt/sources.list.d/tencent.sources && \
    echo 'URIs: http://mirrors.cloud.tencent.com/debian/' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Suites: trixie trixie-updates trixie-backports' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/tencent.sources && \
    echo '' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Types: deb' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'URIs: http://mirrors.cloud.tencent.com/debian-security/' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Suites: trixie-security' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/tencent.sources && \
    echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/tencent.sources && \
    rm -f /etc/apt/sources.list.d/debian.sources

# 配置 pip 国内镜像（root 用户）
RUN mkdir -p /root/.config/pip && \
    echo '[global]' > /root/.config/pip/pip.conf && \
    echo 'index-url = http://mirrors.cloud.tencent.com/pypi/simple/' >> /root/.config/pip/pip.conf && \
    echo 'trusted-host = mirrors.cloud.tencent.com' >> /root/.config/pip/pip.conf

# 配置 pip 国内镜像（Dev 用户）
RUN mkdir -p /home/Dev/.config/pip && \
    echo '[global]' > /home/Dev/.config/pip/pip.conf && \
    echo 'index-url = http://mirrors.cloud.tencent.com/pypi/simple/' >> /home/Dev/.config/pip/pip.conf && \
    echo 'trusted-host = mirrors.cloud.tencent.com' >> /home/Dev/.config/pip/pip.conf && \
    chown -R Dev:Dev /home/Dev/.config/pip

# 暴露端口
EXPOSE 22 3000 5000 8000 8080

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]
