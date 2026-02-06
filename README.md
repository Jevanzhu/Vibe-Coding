# Vibe Coding DevBox - 服务器远程开发环境

专为服务器部署设计的开发容器，支持 SSH 远程连接和 AI 编程助手。

## 已安装组件

| 组件 | 用途 |
|------|------|
| **Debian 13** | 基础系统 |
| **SSH Server** | 远程命令行访问 |
| **Python 3.x** | 编程语言（Debian 13 最新版） |
| **Node.js 24** | JavaScript/TypeScript 运行时（LTS） |
| **Claude Code** | Anthropic AI 编程助手 |
| **OpenCode** | 开源多模型 AI 助手 |
| **PM2** | Node.js 进程管理 |

## 快速部署

### 方式 1: 使用预构建镜像（推荐）

```bash
# 拉取镜像
docker pull ghcr.io/YOUR_USERNAME/vibe-coding:latest

# 运行
docker run -d \
  -p 2222:22 \
  -v ./projects:/workspace/projects \
  --name vibe-coding \
  ghcr.io/YOUR_USERNAME/vibe-coding:latest
```

### 方式 2: 本地构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/vibe-coding.git
cd vibe-coding

# 构建并启动
docker compose up -d --build
```

## 访问方式

```bash
ssh -p 2222 Dev@<服务器IP>
密码: vibecoding
```

## AI 助手官方安装方式

| 工具 | 官方安装命令 |
|------|-------------|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh \| bash` |
| **OpenCode** | `curl -fsSL https://opencode.ai/install \| bash` |

## 远程开发工作流

### SSH + 本地 VS Code（推荐）

```bash
# 在本地 VS Code 安装 "Remote - SSH" 插件
# 然后连接:
ssh -p 2222 Dev@你的服务器IP
```

### SSH 命令行

```bash
ssh -p 2222 Dev@你的服务器IP
# 然后在容器中:
claude    # 启动 Claude Code
opencode  # 启动 OpenCode
```

## 配置 API Keys

进入容器后手动设置（推荐，更安全）：

```bash
# 连接容器
ssh -p 2222 Dev@你的服务器IP

# 设置 API Key（临时，当前会话有效）
export ANTHROPIC_API_KEY=sk-xxx
claude

# 或持久化到 ~/.bashrc
echo 'export ANTHROPIC_API_KEY=sk-xxx' >> ~/.bashrc
source ~/.bashrc
```

## 常用命令

```bash
# 查看容器日志
docker compose logs -f

# 停止容器
docker compose down

# 完全重建
docker compose down -v
docker compose up -d --build

# 重启容器
docker compose restart
```

## 自动化构建

本项目使用 GitHub Actions 自动构建镜像：

- **触发条件**: 推送 tag (v*) 或推送到 main 分支
- **镜像仓库**: GitHub Container Registry (ghcr.io)
- **支持架构**: linux/amd64, linux/arm64

### 手动触发构建

进入仓库 Actions 页面 → 选择 "Build and Push Docker Image" → Run workflow

## 端口分配

| 端口 | 用途 |
|------|------|
| 2222 | SSH 访问 |
| 3000 | React/Vue 开发服务器 |
| 5000-5010 | Flask/FastAPI 应用 |
| 8000-8010 | Django/其他服务 |
| 8080 | 通用 HTTP |

## 安全建议

1. **修改默认密码**（必须）
   ```bash
   docker compose exec devbox bash
   passwd Dev
   ```

2. 生产环境使用密钥认证替代密码

## 文件结构

```
.
├── .github/workflows/      # GitHub Actions 配置
├── Dockerfile              # 镜像定义（构建用国外源，运行切换国内源）
├── docker-compose.yml      # 服务编排
└── projects/               # 项目代码目录
```

## 镜像源策略

| 阶段 | APT 源 | PyPI 源 | 说明 |
|------|--------|---------|------|
| **构建时** | Debian 官方 | 官方 | 构建稳定，软件包最新 |
| **运行时** | 腾讯云 | 腾讯云 | 国内访问快，安装依赖快 |

## 参考

- [Claude Code 文档](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)
- [OpenCode GitHub](https://github.com/sst/opencode)
