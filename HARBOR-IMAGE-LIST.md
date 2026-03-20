# RER — Lista de Imagens Docker para Replicação no Harbor

**Data**: 2026-03-20  
**Destino**: `registry-ctn.prevnet` → SWR (Huawei Cloud) → K8s (HCSO)  
**Cadeia**: GitHub Actions → ghcr.io → Harbor → SWR → K8s

---

## Imagens Customizadas (ghcr.io)

Estas imagens são buildadas pelo CI/CD (GitHub Actions) e publicadas no ghcr.io.  
Devem ser replicadas para o Harbor interno.

| # | Imagem (ghcr.io) | Tag | Repo Fonte | Tecnologia |
|---|-----------------|-----|-----------|------------|
| 1 | `ghcr.io/rural-environmental-registry/rer-gateway` | `latest` | [gateway](https://github.com/Rural-Environmental-Registry/gateway) | Spring Cloud Gateway |
| 2 | `ghcr.io/rural-environmental-registry/rer-core-frontend` | `latest` | [frontend](https://github.com/Rural-Environmental-Registry/frontend) | Vue.js 3 + Nginx |
| 3 | `ghcr.io/rural-environmental-registry/rer-core-backend` | `latest` | [backend](https://github.com/Rural-Environmental-Registry/backend) | Spring Boot 3 + Gradle |
| 4 | `ghcr.io/rural-environmental-registry/rer-auth-keycloak` | `latest` | [authentication](https://github.com/Rural-Environmental-Registry/authentication) | Keycloak customizado |
| 5 | `ghcr.io/rural-environmental-registry/rer-auth-frontend` | `latest` | [authentication](https://github.com/Rural-Environmental-Registry/authentication) | Vue.js 3 + Nginx |
| 6 | `ghcr.io/rural-environmental-registry/rer-calc-engine` | `latest` | [calc_engine](https://github.com/Rural-Environmental-Registry/calc_engine) | Spring Boot WebFlux + Maven |
| 7 | `ghcr.io/rural-environmental-registry/rer-auth-backend` | `latest` | [authentication](https://github.com/Rural-Environmental-Registry/authentication) | Spring Boot (CardPG) |

---

## Imagens Públicas (Docker Hub / OSGeo)

Estas imagens são públicas e devem ser replicadas para o Harbor para uso offline/interno.

| # | Imagem | Tag | Uso no RER |
|---|--------|-----|-----------|
| 8 | `postgis/postgis` | `latest` | Core Backend DB (PostgreSQL + PostGIS) |
| 9 | `postgres` | `15` | Authentication DB (Keycloak) |
| 10 | `postgres` | `17` | Calculation Engine DB |
| 11 | `postgis/postgis` | `17-3.5-alpine` | PostGIS Calculator DB |
| 12 | `docker.osgeo.org/geoserver` | `2.28.0` | Base do GeoServer (customizado via Dockerfile) |
| 13 | `nginx` | `alpine` | Reverse Proxy |
| 14 | `docker` | `27-cli` | GeoServer Init sidecar (executa populate_geoserver.sh) |

---

## Comandos para Pull/Push

### Pull de todas as imagens do ghcr.io

```bash
# Imagens customizadas
docker pull ghcr.io/rural-environmental-registry/rer-gateway:latest
docker pull ghcr.io/rural-environmental-registry/rer-core-frontend:latest
docker pull ghcr.io/rural-environmental-registry/rer-core-backend:latest
docker pull ghcr.io/rural-environmental-registry/rer-auth-keycloak:latest
docker pull ghcr.io/rural-environmental-registry/rer-auth-frontend:latest
docker pull ghcr.io/rural-environmental-registry/rer-calc-engine:latest
docker pull ghcr.io/rural-environmental-registry/rer-auth-backend:latest

# Imagens públicas
docker pull postgis/postgis:latest
docker pull postgres:15
docker pull postgres:17
docker pull postgis/postgis:17-3.5-alpine
docker pull docker.osgeo.org/geoserver:2.28.0
docker pull nginx:alpine
docker pull docker:27-cli
```

### Tag + Push para Harbor

```bash
HARBOR="registry-ctn.prevnet/rer"

# Imagens customizadas
for img in rer-gateway rer-core-frontend rer-core-backend rer-auth-keycloak rer-auth-frontend rer-calc-engine rer-auth-backend; do
  docker tag "ghcr.io/rural-environmental-registry/${img}:latest" "${HARBOR}/${img}:latest"
  docker push "${HARBOR}/${img}:latest"
done

# Imagens públicas (retag com nomes simplificados)
docker tag postgis/postgis:latest ${HARBOR}/postgis:latest
docker push ${HARBOR}/postgis:latest

docker tag postgres:15 ${HARBOR}/postgres:15
docker push ${HARBOR}/postgres:15

docker tag postgres:17 ${HARBOR}/postgres:17
docker push ${HARBOR}/postgres:17

docker tag postgis/postgis:17-3.5-alpine ${HARBOR}/postgis:17-3.5-alpine
docker push ${HARBOR}/postgis:17-3.5-alpine

docker tag docker.osgeo.org/geoserver:2.28.0 ${HARBOR}/geoserver:2.28.0
docker push ${HARBOR}/geoserver:2.28.0

docker tag nginx:alpine ${HARBOR}/nginx:alpine
docker push ${HARBOR}/nginx:alpine

docker tag docker:27-cli ${HARBOR}/docker:27-cli
docker push ${HARBOR}/docker:27-cli
```

---

## Mapeamento Harbor → SWR → K8s

| Harbor (`registry-ctn.prevnet/rer/`) | SWR (Huawei Cloud) | Usado por (K8s) |
|--------------------------------------|---------------------|-----------------|
| `rer-gateway:latest` | `swr.la-south-2.myhuaweicloud.com/rer/rer-gateway:latest` | Deployment `gateway` |
| `rer-core-frontend:latest` | `swr.../rer/rer-core-frontend:latest` | Deployment `core-frontend` |
| `rer-core-backend:latest` | `swr.../rer/rer-core-backend:latest` | Deployment `core-backend` |
| `rer-auth-keycloak:latest` | `swr.../rer/rer-auth-keycloak:latest` | StatefulSet `keycloak` |
| `rer-auth-frontend:latest` | `swr.../rer/rer-auth-frontend:latest` | Deployment `auth-frontend` |
| `rer-auth-backend:latest` | `swr.../rer/rer-auth-backend:latest` | Deployment `auth-backend` |
| `rer-calc-engine:latest` | `swr.../rer/rer-calc-engine:latest` | Deployment `calc-engine` |
| `postgis:latest` | `swr.../rer/postgis:latest` | StatefulSet `core-backend-db` |
| `postgres:15` | `swr.../rer/postgres:15` | StatefulSet `auth-db` |
| `postgres:17` | `swr.../rer/postgres:17` | StatefulSet `calculator-engine-db` |
| `postgis:17-3.5-alpine` | `swr.../rer/postgis:17-3.5-alpine` | StatefulSet `postgis-calculator-db` |
| `geoserver:2.28.0` | `swr.../rer/geoserver:2.28.0` | Deployment `geoserver` |
| `nginx:alpine` | `swr.../rer/nginx:alpine` | Deployment `main-proxy` |

> **Nota**: O `docker:27-cli` (geoserver-init) é usado apenas no deploy standalone (docker-compose). No K8s, o populate_geoserver.sh roda como initContainer.

---

## Total

- **7 imagens customizadas** (ghcr.io)
- **7 imagens públicas** (Docker Hub + OSGeo)
- **14 imagens no total** para replicação
