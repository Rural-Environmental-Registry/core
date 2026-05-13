<p align="center">
  <img src="images/logo-rer-color.png" alt="RER Logo" width="300">
</p>

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.3-brightgreen.svg)](https://spring.io/projects/spring-boot) [![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.java.net/) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-blue.svg)](https://postgis.net/) [![Vue.js](https://img.shields.io/badge/Vue.js-3-green.svg)](https://vuejs.org/) [![Docker](https://img.shields.io/badge/Docker-24+-blue.svg)](https://www.docker.com/) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📑 Table of Contents

- [Welcome to RER](#welcome-to-rer)
- [Quick Start](#quick-start)
- [Manual Installation](#manual-installation)
- [Project Architecture](#project-architecture)
- [Repositories](#repositories)
- [Accessing the Services](#accessing-the-services)
- [Configuration](#configuration)
- [Monitoring and Logs](#monitoring-and-logs)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contribution](#contribution)
- [Support](#support)

---

## Welcome to RER!

The **RER** (Rural Environmental Registry — Digital Public Good) is a modern, comprehensive solution for managing rural environmental registrations. Built as a digital public good, it provides a robust and scalable platform for registering rural land properties with full geospatial support.

The solution modernizes and expands the capabilities of the Rural Environmental Registry (CAR) by transforming it into a Digital Public Good (DPG), meeting Brazil's specific needs while enabling replication in international contexts.

**Key features:**

- 🗺️ Geospatial data support with PostGIS and GeoServer
- 🧩 Interactive map component with Leaflet
- 🔐 Authentication and authorization with Keycloak
- 🌐 Modern web interface built with Vue.js 3
- ⚡ High-performance REST API with Spring Boot
- 🚪 API Gateway for intelligent routing
- 🧮 Calculation engine for environmental data processing
- 🐳 Full containerization with Docker

---

## Quick Start

Install RER on a clean Linux server with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/install.sh | bash
```

This will:
1. Check and install Docker if needed
2. Download all configuration files
3. Pull all Docker images
4. Start the complete stack
5. Display access URLs and default credentials

### Custom installation directory

```bash
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/install.sh | bash -s -- --dir /opt/rer
```

### Requirements

- **OS:** Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+, RHEL 8+)
- **RAM:** 8GB minimum (16GB recommended)
- **Disk:** 20GB free space
- **CPU:** 4 cores minimum
- **Network:** Internet access to download Docker images

---

## Manual Installation

If you prefer to install manually:

### 1. Install Docker

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Download configuration files

```bash
mkdir -p ~/rer && cd ~/rer

# Download docker-compose and environment
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/docker-compose.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/.env.example -o .env

# Download nginx config
mkdir -p config/nginx
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/config/nginx/nginx.conf -o config/nginx/nginx.conf

# Download GeoServer config
mkdir -p config/Geoserver/docker
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/config/Geoserver/docker/Dockerfile -o config/Geoserver/docker/Dockerfile
curl -fsSL https://raw.githubusercontent.com/Rural-Environmental-Registry/core/main/config/Geoserver/docker/populate_geoserver.sh -o config/Geoserver/docker/populate_geoserver.sh
chmod +x config/Geoserver/docker/populate_geoserver.sh
```

### 3. Download database initialization scripts

```bash
# Calculation Engine DB (5 evolutions)
mkdir -p data/db-init/calculator_engine
for i in 0 1 2 3 4; do
  curl -fsSL "https://raw.githubusercontent.com/Rural-Environmental-Registry/calc_engine/main/src/main/resources/db_structure/calculator_engine/evolution_${i}.sql" \
    -o "data/db-init/calculator_engine/evolution_${i}.sql"
done

# PostGIS Calculator DB (3 evolutions)
mkdir -p data/db-init/postgis_calculator
for i in 0 1 2; do
  curl -fsSL "https://raw.githubusercontent.com/Rural-Environmental-Registry/calc_engine/main/src/main/resources/db_structure/postgis_calculator/evolution_${i}.sql" \
    -o "data/db-init/postgis_calculator/evolution_${i}.sql"
done
```

### 4. Configure environment

```bash
# Copy the example and edit as needed
cp .env.example .env

# Edit the .env file — at minimum, change:
#   - HOSTNAME_DNS (your server hostname or IP)
#   - Database passwords (CORE_BACKEND_DB_PASSWORD, AUTH_DB_PASSWORD, etc.)
#   - KEYCLOAK_ADMIN_PASSWORD
nano .env
```

### 5. Start the stack

```bash
# Build the custom GeoServer image
docker compose build geoserver

# Start all services
docker compose up -d
```

### 6. Verify

```bash
# Check all services are running
docker compose ps

# Watch logs
docker compose logs -f
```

---

## Project Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        NGINX Reverse Proxy (:80)                │
│                    /geoserver → GeoServer                       │
│                    /*         → Gateway                         │
└──────────────┬──────────────────────────────┬───────────────────┘
               │                              │
    ┌──────────▼──────────┐       ┌───────────▼──────────┐
    │   Spring Cloud      │       │     GeoServer        │
    │   Gateway (:8080)   │       │     (:8080)          │
    └──┬───┬───┬───┬──────┘       └──────────────────────┘
       │   │   │   │
  ┌────▼┐ ┌▼──┐│  ┌▼────────────────────┐
  │Core ││Core││  │  Authentication      │
  │Front││Back││  │  ┌────────┐┌───────┐ │
  │end  ││end ││  │  │Keycloak││CardPG │ │
  └─────┘└──┬─┘│  │  └───┬────┘└───┬───┘ │
            │  │  │      │         │      │
         ┌──▼──┐ │  ┌───▼─────────▼──┐   │
         │Core │ │  │  Auth DB        │   │
         │DB   │ │  │  (PostgreSQL)   │   │
         │(Post│ │  └─────────────────┘   │
         │GIS) │ │                        │
         └─────┘ │  ┌──────────┐┌───────┐ │
                  │  │Auth      ││Auth   │ │
                  │  │Frontend  ││Backend│ │
                  │  └──────────┘└───────┘ │
                  └────────────────────────┘
                  │
       ┌──────────▼──────────────────────┐
       │   Calculation Engine            │
       │   (Spring Boot WebFlux)         │
       │                                 │
       │  ┌──────────┐  ┌────────────┐   │
       │  │Engine DB │  │PostGIS     │   │
       │  │(Postgres)│  │Calculator  │   │
       │  └──────────┘  └────────────┘   │
       └─────────────────────────────────┘
```

### Services

| Service | Technology | Port | Description |
|---------|-----------|------|-------------|
| main-proxy | Nginx | 80 | Reverse proxy, routes traffic |
| gateway | Spring Cloud Gateway | 8080 | API routing, CORS, auth relay |
| core-frontend | Vue.js 3 + Nginx | 80 | Main web application |
| core-backend | Spring Boot 3 | 8080 | REST API, Flyway migrations |
| core-backend-db | PostGIS | 5432 | Main database with spatial support |
| authentication | Keycloak | 8080 | SSO, OAuth2, realm management |
| authentication-frontend | Vue.js 3 + Nginx | 80 | Admin portal |
| authentication-backend | Spring Boot | 8081 | Admin API (CardPG) |
| authentication-db | PostgreSQL 15 | 5432 | Keycloak database |
| geo-calculation-engine-app | Spring Boot WebFlux | 8080 | Environmental calculations |
| calculator-engine-db | PostgreSQL 17 | 5432 | Calculation engine config DB |
| postgis-calculator-db | PostGIS 17 | 5432 | Spatial calculation DB |
| geoserver | GeoServer 2.28 | 8080 | OGC map server (WMS/WFS) |

### Networks

| Network | Services |
|---------|----------|
| gateway_network | proxy, gateway, frontends, backends, keycloak, geoserver |
| core-backend-network | core-backend, core-backend-db, geoserver |
| authentication_network | keycloak, auth-frontend, auth-backend, auth-db |
| geo_calc_network | calc-engine, calculator-engine-db, postgis-calculator-db, geoserver |

---

## Repositories

| Repository | Description | Docker Image |
|-----------|-------------|--------------|
| [core](https://github.com/Rural-Environmental-Registry/core) | Deploy orchestrator (this repo) | — |
| [gateway](https://github.com/Rural-Environmental-Registry/gateway) | Spring Cloud Gateway | `rer-gateway` |
| [frontend](https://github.com/Rural-Environmental-Registry/frontend) | Vue.js 3 SPA | `rer-core-frontend` |
| [backend](https://github.com/Rural-Environmental-Registry/backend) | Spring Boot REST API | `rer-core-backend` |
| [authentication](https://github.com/Rural-Environmental-Registry/authentication) | Keycloak + Admin Portal | `rer-auth-keycloak`, `rer-auth-frontend`, `rer-auth-backend` |
| [calc_engine](https://github.com/Rural-Environmental-Registry/calc_engine) | Calculation Engine | `rer-calc-engine` |
| [map_component](https://github.com/Rural-Environmental-Registry/map_component) | Leaflet map library (npm) | — (npm package) |

---

## Accessing the Services

After starting the stack, access the following URLs (assuming default `localhost` configuration):

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| Main Application | http://localhost | admin-cardpg@gmail.com / NovaSenhaForte123! |
| Keycloak Admin | http://localhost/keycloak/admin | admin / admin |
| GeoServer | http://localhost/geoserver/ | admin / geoserver |

> ⚠️ **Change all default passwords before deploying to production.**

---

## Configuration

All configuration is managed through the `.env` file. Key settings:

| Variable | Description | Default |
|----------|-------------|---------|
| `HOSTNAME_DNS` | Server hostname | `localhost` |
| `RER_HTTP_PORT` | HTTP port | `80` |
| `HTTP_HTTPS` | Protocol | `http` |
| `BASE_URL` | URL subpath (optional) | _(empty)_ |
| `CORE_BACKEND_DB_PASSWORD` | Core database password | `car_pass` |
| `AUTH_DB_PASSWORD` | Keycloak database password | `senhaSegura` |
| `KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password | `admin` |
| `GEOSERVER_ADMIN_PASSWORD` | GeoServer admin password | `geoserver` |

For a complete list of variables, see [`.env.example`](.env.example).

---

## Monitoring and Logs

```bash
# Status of all services
docker compose ps

# Follow all logs
docker compose logs -f

# Follow a specific service
docker compose logs -f core-backend

# Check resource usage
docker stats
```

### Health Checks

All database services include health checks. Check their status:

```bash
docker inspect --format='{{.State.Health.Status}}' rer-core-backend-db
docker inspect --format='{{.State.Health.Status}}' rer-authentication-db
docker inspect --format='{{.State.Health.Status}}' rer-calculator-engine-db
docker inspect --format='{{.State.Health.Status}}' rer-postgis-calculator-db
```

---

## Troubleshooting

### Services not starting

```bash
# Check which services failed
docker compose ps --filter "status=exited"

# View logs for the failed service
docker compose logs <service-name>
```

### Database connection errors

```bash
# Verify database is healthy
docker compose exec core-backend-db pg_isready -U car_user -d car_db

# Check environment variables
docker compose config | grep DB_
```

### GeoServer not loading layers

The `geoserver-init` sidecar runs once after GeoServer starts. Check its logs:

```bash
docker compose logs geoserver-init
```

If it failed, re-run manually:

```bash
docker exec rer-geoserver bash -c '/opt/populate_geoserver.sh'
```

### Port conflicts

If port 80 is already in use:

```bash
# Change the port in .env
echo "RER_HTTP_PORT=8080" >> .env

# Restart
docker compose down && docker compose up -d
```

### Reset everything

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Start fresh
docker compose up -d
```

---

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.

RER is a **Digital Public Good** (DPG), developed to be freely used, modified, and distributed by governments and organizations worldwide.

---

## Contribution

Contributions are welcome! Please follow these steps:

1. Fork the relevant repository
2. Create a feature branch from `develop`
3. Make your changes
4. Submit a Pull Request to `develop`

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `develop` | Active development |
| `staging` | QA / Homologation |
| `demo` | Pre-production |
| `main` | Production releases |

---

## Support

- 📧 Email: [support contact]
- 🐛 Issues: [GitHub Issues](https://github.com/Rural-Environmental-Registry/core/issues)
- 📖 Documentation: [Wiki](https://github.com/Rural-Environmental-Registry/core/wiki)
