#!/bin/bash
# RER - Rural Environmental Registry
# One-command install for production/demo deployment
# Usage: curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/install.sh | sh
#    or: ./install.sh
#
# Prerequisites: Docker 24+ with Docker Compose v2
# No Java, Node, Maven, or source code required.

set -e

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[RER]${NC} $1"; }
warn() { echo -e "${YELLOW}[RER]${NC} $1"; }
error() { echo -e "${RED}[RER]${NC} $1"; exit 1; }

RER_VERSION="${RER_VERSION:-1.0.0}"
RER_DIR="${RER_DIR:-$HOME/rer}"
RER_PORT="${RER_PORT:-8080}"

# --- 1. Check prerequisites ---
info "Checking prerequisites..."

if ! command -v docker &>/dev/null; then
  error "Docker not found. Install: https://docs.docker.com/engine/install/"
fi

if ! docker compose version &>/dev/null; then
  error "Docker Compose v2 not found. Install: https://docs.docker.com/compose/install/"
fi

if ! command -v openssl &>/dev/null; then
  error "openssl not found. Install: apt-get install openssl"
fi

DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "0")
info "Docker $DOCKER_VERSION ✓"

# --- 2. Create directory ---
info "Setting up RER in $RER_DIR..."
mkdir -p "$RER_DIR"
cd "$RER_DIR"

# --- 3. Generate .env ---
if [ ! -f .env ]; then
  info "Generating .env with defaults..."
  cat > .env << EOF
# RER Configuration
RER_VERSION=${RER_VERSION}
RER_PORT=${RER_PORT}

# Database (auto-created)
POSTGRES_USER=rer_admin
POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
POSTGRES_DB=rer

# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)

# Core Backend
CORE_DB_URL=jdbc:postgresql://core-db:5432/rer
CORE_DB_USERNAME=rer_admin
CORE_DB_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)

# Calculation Engine
CALC_DB_URL=jdbc:postgresql://calc-db:5432/calc_engine
CALC_DB_USERNAME=calc_admin
CALC_DB_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)

# GeoServer
GEOSERVER_ADMIN_USER=admin
GEOSERVER_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 16)
EOF
  warn "Generated random passwords in .env — review before production use!"
else
  info ".env already exists, keeping current values."
fi

# --- 4. Generate docker-compose.yml ---
if [ -f docker-compose.yml ]; then
  cp docker-compose.yml docker-compose.yml.bak
  info "Backed up existing docker-compose.yml → docker-compose.yml.bak"
fi
info "Generating docker-compose.yml..."
cat > docker-compose.yml << 'COMPOSE'
services:
  # --- Databases ---
  core-db:
    image: postgis/postgis:17-3.5-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-rer}
      POSTGRES_USER: ${CORE_DB_USERNAME}
      POSTGRES_PASSWORD: ${CORE_DB_PASSWORD}
    volumes:
      - core-db-data:/var/lib/postgresql/data
    networks: [rer-net]
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${CORE_DB_USERNAME}"]
      interval: 5s
      timeout: 3s
      retries: 10

  keycloak-db:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: ${KC_DB_USERNAME}
      POSTGRES_PASSWORD: ${KC_DB_PASSWORD}
    volumes:
      - keycloak-db-data:/var/lib/postgresql/data
    networks: [rer-net]
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${KC_DB_USERNAME}"]
      interval: 5s
      timeout: 3s
      retries: 10

  calc-db:
    image: postgis/postgis:17-3.5-alpine
    environment:
      POSTGRES_DB: calc_engine
      POSTGRES_USER: ${CALC_DB_USERNAME}
      POSTGRES_PASSWORD: ${CALC_DB_PASSWORD}
    volumes:
      - calc-db-data:/var/lib/postgresql/data
    networks: [rer-net]
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${CALC_DB_USERNAME}"]
      interval: 5s
      timeout: 3s
      retries: 10

  # --- Services ---
  gateway:
    image: ghcr.io/rural-environmental-registry/rer-gateway:${RER_VERSION}
    depends_on:
      core-db: { condition: service_healthy }
    networks: [rer-net]
    restart: unless-stopped

  core-frontend:
    image: ghcr.io/rural-environmental-registry/rer-core-frontend:${RER_VERSION}
    networks: [rer-net]
    restart: unless-stopped

  core-backend:
    image: ghcr.io/rural-environmental-registry/rer-core-backend:${RER_VERSION}
    environment:
      SPRING_DATASOURCE_URL: ${CORE_DB_URL}
      SPRING_DATASOURCE_USERNAME: ${CORE_DB_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${CORE_DB_PASSWORD}
    depends_on:
      core-db: { condition: service_healthy }
    networks: [rer-net]
    restart: unless-stopped

  auth-keycloak:
    image: ghcr.io/rural-environmental-registry/rer-auth-keycloak:${RER_VERSION}
    environment:
      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
      KC_DB_URL: ${KC_DB_URL}
      KC_DB_USERNAME: ${KC_DB_USERNAME}
      KC_DB_PASSWORD: ${KC_DB_PASSWORD}
      KC_HOSTNAME_STRICT: "false"
      KC_PROXY: edge
    depends_on:
      keycloak-db: { condition: service_healthy }
    networks: [rer-net]
    restart: unless-stopped

  auth-frontend:
    image: ghcr.io/rural-environmental-registry/rer-auth-frontend:${RER_VERSION}
    networks: [rer-net]
    restart: unless-stopped

  auth-backend:
    image: ghcr.io/rural-environmental-registry/rer-auth-backend:${RER_VERSION}
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://keycloak-db:5432/keycloak
      SPRING_DATASOURCE_USERNAME: ${KC_DB_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${KC_DB_PASSWORD}
    depends_on:
      keycloak-db: { condition: service_healthy }
    networks: [rer-net]
    restart: unless-stopped

  calc-engine:
    image: ghcr.io/rural-environmental-registry/rer-calc-engine:${RER_VERSION}
    environment:
      SPRING_DATASOURCE_URL: ${CALC_DB_URL}
      SPRING_DATASOURCE_USERNAME: ${CALC_DB_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${CALC_DB_PASSWORD}
    depends_on:
      calc-db: { condition: service_healthy }
    networks: [rer-net]
    restart: unless-stopped

  geoserver:
    image: ghcr.io/rural-environmental-registry/rer-geoserver:${RER_VERSION}
    environment:
      GEOSERVER_ADMIN_USER: ${GEOSERVER_ADMIN_USER}
      GEOSERVER_ADMIN_PASSWORD: ${GEOSERVER_ADMIN_PASSWORD}
    volumes:
      - geoserver-data:/opt/geoserver/data_dir
    networks: [rer-net]
    restart: unless-stopped

  # --- Reverse Proxy ---
  proxy:
    image: nginx:alpine
    ports:
      - "${RER_PORT:-8080}:8080"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - gateway
      - core-frontend
      - auth-frontend
      - auth-keycloak
    networks: [rer-net]
    restart: unless-stopped

volumes:
  core-db-data:
  keycloak-db-data:
  calc-db-data:
  geoserver-data:

networks:
  rer-net:
    driver: bridge
COMPOSE

# --- 5. Generate nginx.conf ---
if [ -f nginx.conf ]; then
  cp nginx.conf nginx.conf.bak
fi
cat > nginx.conf << 'NGINX'
worker_processes auto;
pid /tmp/nginx.pid;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 8080;

        location / {
            proxy_pass http://core-frontend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /api/ {
            proxy_pass http://gateway:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /keycloak/ {
            proxy_pass http://auth-keycloak:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /auth/ {
            proxy_pass http://auth-frontend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /geoserver/ {
            proxy_pass http://geoserver:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
NGINX

# --- 6. Pull and start ---
info "Pulling images (version: $RER_VERSION)..."
docker compose pull

info "Starting RER..."
docker compose up -d

# --- 7. Wait for health ---
info "Waiting for services to start..."
sleep 10

HEALTHY=$(docker compose ps --filter "status=running" --quiet 2>/dev/null | wc -l || echo "0")
TOTAL=$(docker compose ps --quiet 2>/dev/null | wc -l || echo "0")

echo ""
info "============================================"
info "  RER - Rural Environmental Registry"
info "============================================"
info ""
info "  URL:      http://localhost:${RER_PORT}"
info "  Version:  ${RER_VERSION}"
info "  Status:   ${HEALTHY}/${TOTAL} services running"
info ""
info "  Credentials in: $RER_DIR/.env"
info ""
info "  Commands:"
info "    Stop:    cd $RER_DIR && docker compose down"
info "    Start:   cd $RER_DIR && docker compose up -d"
info "    Logs:    cd $RER_DIR && docker compose logs -f"
info "    Update:  RER_VERSION=x.y.z ./install.sh"
info ""
info "============================================"
