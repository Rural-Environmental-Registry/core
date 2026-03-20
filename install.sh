#!/usr/bin/env bash
# =============================================================================
# RER - Rural Environmental Registry (Digital Public Good)
# Script de Instalação One-Liner
# =============================================================================
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/install.sh | bash
#
# Ou, para especificar diretório de instalação:
#   curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/install.sh | bash -s -- --dir /opt/rer
#
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
RER_VERSION="${RER_VERSION:-latest}"
RER_REPO="Rural-Environmental-Registry"
RER_BRANCH="${RER_BRANCH:-main}"
GITHUB_RAW="https://raw.githubusercontent.com/${RER_REPO}/core/${RER_BRANCH}"
GITHUB_RAW_CALC="https://raw.githubusercontent.com/${RER_REPO}/calc_engine/${RER_BRANCH}"
INSTALL_DIR="${HOME}/rer"
COMPOSE_PROJECT_NAME="rer"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Funções auxiliares
# ---------------------------------------------------------------------------
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[AVISO]${NC} $*"; }
error()   { echo -e "${RED}[ERRO]${NC} $*" >&2; }
fatal()   { error "$*"; exit 1; }

banner() {
    echo ""
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║                                                          ║"
    echo "  ║   🌿  RER - Rural Environmental Registry                ║"
    echo "  ║       Digital Public Good                                ║"
    echo "  ║                                                          ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# ---------------------------------------------------------------------------
# Parse argumentos
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --branch)
            RER_BRANCH="$2"
            GITHUB_RAW="https://raw.githubusercontent.com/${RER_REPO}/core/${RER_BRANCH}"
            GITHUB_RAW_CALC="https://raw.githubusercontent.com/${RER_REPO}/calc_engine/${RER_BRANCH}"
            shift 2
            ;;
        --help|-h)
            echo "Uso: install.sh [--dir /caminho] [--branch main]"
            echo ""
            echo "Opções:"
            echo "  --dir      Diretório de instalação (padrão: ~/rer)"
            echo "  --branch   Branch do GitHub (padrão: main)"
            echo "  --help     Mostra esta ajuda"
            exit 0
            ;;
        *)
            fatal "Argumento desconhecido: $1. Use --help para ver as opções."
            ;;
    esac
done

# ---------------------------------------------------------------------------
# 1. Verificar/Instalar Docker
# ---------------------------------------------------------------------------
check_docker() {
    info "Verificando Docker..."

    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
        success "Docker encontrado: v${DOCKER_VERSION}"
    else
        warn "Docker não encontrado. Instalando..."
        install_docker
    fi

    # Verificar Docker Compose v2
    if docker compose version &>/dev/null; then
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
        success "Docker Compose encontrado: v${COMPOSE_VERSION}"
    else
        fatal "Docker Compose v2 não encontrado. Instale Docker Desktop ou docker-compose-plugin."
    fi

    # Verificar se o daemon está rodando
    if ! docker info &>/dev/null; then
        warn "Docker daemon não está rodando. Tentando iniciar..."
        sudo systemctl start docker 2>/dev/null || fatal "Não foi possível iniciar o Docker. Execute: sudo systemctl start docker"
        sleep 3
        docker info &>/dev/null || fatal "Docker daemon não respondeu."
        success "Docker daemon iniciado."
    fi
}

install_docker() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                info "Instalando Docker via apt..."
                sudo apt-get update -qq
                sudo apt-get install -y -qq ca-certificates curl gnupg
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -qq
                sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            centos|rhel|fedora|rocky|alma*)
                info "Instalando Docker via yum/dnf..."
                sudo yum install -y yum-utils 2>/dev/null || sudo dnf install -y dnf-plugins-core
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || \
                    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || \
                    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            *)
                fatal "Distribuição '${ID}' não suportada para instalação automática. Instale Docker manualmente: https://docs.docker.com/engine/install/"
                ;;
        esac
    else
        fatal "Não foi possível detectar o sistema operacional. Instale Docker manualmente: https://docs.docker.com/engine/install/"
    fi

    # Iniciar e habilitar Docker
    sudo systemctl enable docker
    sudo systemctl start docker

    # Adicionar usuário ao grupo docker
    if ! groups | grep -q docker; then
        sudo usermod -aG docker "$USER"
        warn "Usuário adicionado ao grupo 'docker'. Pode ser necessário fazer logout/login."
    fi

    success "Docker instalado com sucesso."
}

# ---------------------------------------------------------------------------
# 2. Preparar diretório de instalação
# ---------------------------------------------------------------------------
prepare_directory() {
    info "Preparando diretório de instalação: ${INSTALL_DIR}"

    mkdir -p "${INSTALL_DIR}"
    cd "${INSTALL_DIR}"

    # Criar estrutura de diretórios
    mkdir -p config/nginx
    mkdir -p config/Geoserver/docker
    mkdir -p data/db-init/calculator_engine
    mkdir -p data/db-init/postgis_calculator

    success "Diretório preparado: ${INSTALL_DIR}"
}

# ---------------------------------------------------------------------------
# 3. Baixar arquivos de configuração
# ---------------------------------------------------------------------------
download_configs() {
    info "Baixando arquivos de configuração do GitHub..."

    # docker-compose.yml
    info "  → docker-compose.yml"
    curl -fsSL "${GITHUB_RAW}/docker-compose.yml" -o docker-compose.yml

    # .env.example → .env
    info "  → .env.example"
    curl -fsSL "${GITHUB_RAW}/.env.example" -o .env.example

    if [[ ! -f .env ]]; then
        cp .env.example .env
        success "  Arquivo .env criado a partir do .env.example"
    else
        warn "  Arquivo .env já existe, mantendo configuração atual."
    fi

    # Nginx config
    info "  → config/nginx/nginx.conf"
    curl -fsSL "${GITHUB_RAW}/config/nginx/nginx.conf" -o config/nginx/nginx.conf

    # Geoserver Dockerfile e populate script
    info "  → config/Geoserver/docker/Dockerfile"
    curl -fsSL "${GITHUB_RAW}/config/Geoserver/docker/Dockerfile" -o config/Geoserver/docker/Dockerfile

    info "  → config/Geoserver/docker/populate_geoserver.sh"
    curl -fsSL "${GITHUB_RAW}/config/Geoserver/docker/populate_geoserver.sh" -o config/Geoserver/docker/populate_geoserver.sh
    chmod +x config/Geoserver/docker/populate_geoserver.sh

    success "Arquivos de configuração baixados."
}

# ---------------------------------------------------------------------------
# 4. Baixar SQL scripts de inicialização dos bancos
# ---------------------------------------------------------------------------
download_db_scripts() {
    info "Baixando scripts de inicialização dos bancos de dados..."

    local CALC_DB_PATH="src/main/resources/db_structure"

    # Calculator Engine DB (5 evolutions)
    for i in 0 1 2 3 4; do
        info "  → calculator_engine/evolution_${i}.sql"
        curl -fsSL "${GITHUB_RAW_CALC}/${CALC_DB_PATH}/calculator_engine/evolution_${i}.sql" \
            -o "data/db-init/calculator_engine/evolution_${i}.sql"
    done

    # PostGIS Calculator DB (3 evolutions)
    for i in 0 1 2; do
        info "  → postgis_calculator/evolution_${i}.sql"
        curl -fsSL "${GITHUB_RAW_CALC}/${CALC_DB_PATH}/postgis_calculator/evolution_${i}.sql" \
            -o "data/db-init/postgis_calculator/evolution_${i}.sql"
    done

    success "Scripts de inicialização dos bancos baixados."
}

# ---------------------------------------------------------------------------
# 5. Puxar imagens Docker
# ---------------------------------------------------------------------------
pull_images() {
    info "Baixando imagens Docker (isso pode levar alguns minutos)..."

    local IMAGES=(
        "ghcr.io/rural-environmental-registry/rer-gateway:latest"
        "ghcr.io/rural-environmental-registry/rer-core-frontend:latest"
        "ghcr.io/rural-environmental-registry/rer-core-backend:latest"
        "ghcr.io/rural-environmental-registry/rer-auth-keycloak:latest"
        "ghcr.io/rural-environmental-registry/rer-auth-frontend:latest"
        "ghcr.io/rural-environmental-registry/rer-auth-backend:latest"
        "ghcr.io/rural-environmental-registry/rer-calc-engine:latest"
        "postgis/postgis:latest"
        "postgres:17"
        "postgres:15"
        "postgis/postgis:17-3.5-alpine"
        "docker.osgeo.org/geoserver:2.28.0"
        "nginx:alpine"
        "docker:27-cli"
    )

    local total=${#IMAGES[@]}
    local count=0

    for img in "${IMAGES[@]}"; do
        count=$((count + 1))
        info "  [${count}/${total}] ${img}"
        docker pull "${img}" --quiet || warn "Falha ao baixar ${img} — continuando..."
    done

    success "Imagens Docker baixadas."
}

# ---------------------------------------------------------------------------
# 6. Iniciar o stack
# ---------------------------------------------------------------------------
start_stack() {
    info "Iniciando o RER..."

    cd "${INSTALL_DIR}"

    # Build do Geoserver (imagem customizada)
    info "Construindo imagem do GeoServer..."
    docker compose build geoserver --quiet 2>/dev/null || docker compose build geoserver

    # Subir tudo
    info "Iniciando todos os serviços..."
    docker compose up -d --remove-orphans

    success "Serviços iniciados."
}

# ---------------------------------------------------------------------------
# 7. Health checks
# ---------------------------------------------------------------------------
wait_for_services() {
    info "Aguardando serviços ficarem prontos..."

    local MAX_WAIT=180  # 3 minutos
    local INTERVAL=10
    local elapsed=0

    # Aguardar o gateway responder
    while [[ $elapsed -lt $MAX_WAIT ]]; do
        if docker compose ps --format json 2>/dev/null | grep -q '"running"' || \
           docker compose ps 2>/dev/null | grep -q "Up"; then

            # Verificar se o gateway está respondendo
            if curl -sf http://localhost:${RER_HTTP_PORT:-80}/ -o /dev/null 2>/dev/null; then
                success "Serviços prontos!"
                return 0
            fi
        fi

        echo -ne "\r  ⏳ Aguardando... (${elapsed}s/${MAX_WAIT}s)"
        sleep $INTERVAL
        elapsed=$((elapsed + INTERVAL))
    done

    echo ""
    warn "Timeout aguardando serviços. Verifique com: docker compose ps"
    warn "Alguns serviços podem ainda estar inicializando."
}

# ---------------------------------------------------------------------------
# 8. Exibir informações finais
# ---------------------------------------------------------------------------
show_info() {
    local PORT="${RER_HTTP_PORT:-80}"
    local HOST="${HOSTNAME_DNS:-localhost}"
    local BASE="${BASE_URL:-}"

    echo ""
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║                                                          ║"
    echo "  ║   ✅  RER instalado com sucesso!                        ║"
    echo "  ║                                                          ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "  📁 Diretório de instalação: ${INSTALL_DIR}"
    echo ""
    echo "  🌐 URLs de acesso:"
    echo "     Portal:     http://${HOST}:${PORT}${BASE}"
    echo "     Keycloak:   http://${HOST}:${PORT}${BASE}/keycloak/admin"
    echo "     GeoServer:  http://${HOST}:${PORT}${BASE}/geoserver/"
    echo ""
    echo "  🔑 Credenciais padrão:"
    echo "     Sistema:    admin-cardpg@gmail.com / NovaSenhaForte123!"
    echo "     Keycloak:   admin / admin"
    echo "     GeoServer:  admin / geoserver"
    echo ""
    echo "  📋 Comandos úteis:"
    echo "     cd ${INSTALL_DIR}"
    echo "     docker compose ps          # Status dos serviços"
    echo "     docker compose logs -f     # Logs em tempo real"
    echo "     docker compose down        # Parar tudo"
    echo "     docker compose up -d       # Reiniciar"
    echo ""
    echo "  📖 Documentação: https://github.com/Rural-Environmental-Registry/core"
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    banner
    check_docker
    prepare_directory
    download_configs
    download_db_scripts
    pull_images
    start_stack
    wait_for_services
    show_info
}

main "$@"
