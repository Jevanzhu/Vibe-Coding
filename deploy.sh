#!/bin/bash
# ============================================
# Vibe Coding DevBox 部署脚本
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Vibe Coding DevBox 部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# 检查 Docker Compose (V2 作为 docker 插件)
if ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 插件未安装${NC}"
    echo "请先安装 Docker Compose V2: https://docs.docker.com/compose/install/"
    exit 1
fi

# 检查 .env 文件
if [ ! -f .env ]; then
    echo -e "${YELLOW}警告: .env 文件不存在${NC}"
    echo "正在从 .env.example 创建..."
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件配置 API Keys，然后重新运行脚本${NC}"
    exit 1
fi

# 创建必要目录
echo -e "${GREEN}[1/5] 创建项目目录...${NC}"
mkdir -p projects logs

# 拉取最新镜像（可选）
echo -e "${GREEN}[2/5] 构建镜像...${NC}"
docker compose build --no-cache

# 启动服务
echo -e "${GREEN}[3/5] 启动服务...${NC}"
docker compose up -d

# 等待服务启动
echo -e "${GREEN}[4/5] 等待服务就绪...${NC}"
sleep 5

# 检查健康状态
echo -e "${GREEN}[5/5] 检查服务状态...${NC}"
if docker compose ps | grep -q "running"; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  部署成功!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "服务访问地址:"
    echo "  • SSH:           ssh -p 2222 Dev@<服务器IP> (密码: vibecoding)"
    echo ""
    echo "AI 编程助手:"
    echo "  • Claude Code:   docker exec -it vibe-coding-devbox claude"
    echo "  • OpenCode:      docker exec -it vibe-coding-devbox opencode"
    echo ""
    echo "常用命令:"
    echo "  • 查看日志:      docker compose logs -f"
    echo "  • 进入容器:      docker compose exec devbox bash"
    echo "  • 停止服务:      docker compose down"
    echo "  • 重启服务:      docker compose restart"
    echo ""
    echo -e "${YELLOW}注意: 生产环境请务必修改默认密码!${NC}"
    echo -e "${YELLOW}      编辑 Dockerfile 修改 Dev 的密码${NC}"
else
    echo -e "${RED}服务启动失败，请检查日志: docker-compose logs${NC}"
    exit 1
fi
