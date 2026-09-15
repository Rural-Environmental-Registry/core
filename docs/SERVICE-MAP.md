# RER — Service Map (local × Kubernetes)

> Factual reference for the RER's 14 services, gateway routing, and the naming
> divergence between the local environment (podman/compose) and the Kubernetes
> cluster (HCSO). Derived from `docker-compose.yml` and
> `config/Gateway/application/application.yml`. Validated on the E2E baseline of
> 2026-09-15 (podman).

## Request chain

```
internet
  → main-proxy (nginx :80)                 [config/nginx/nginx.conf]
    → gateway (Spring Cloud Gateway :8080)  [config/Gateway/application/application.yml]
      → core-frontend      /**            (fallback, main SPA)
      → authentication-frontend /auth/**
      → keycloak           /keycloak/**
      → authentication-backend /auth-backend/**
      → core-backend       /cardpgbackend/**
      → calculation-engine /calculation-engine/**
      → geoserver          /geoserver/**
```

On Kubernetes the chain is: `ELB → nginx-ingress (TLS termination) → gateway →
services`. The gateway is the same; what changes is what sits in front of it
(local nginx proxy vs. nginx-ingress in the cluster).

## Gateway routing (path → service → port)

Order matters: `/**` (core-frontend) is the fallback and comes last.

| # | Path (predicate)         | Route id (gateway)      | Override env var                            | Default (local)              | Port  |
|---|--------------------------|-------------------------|---------------------------------------------|------------------------------|-------|
| 1 | `/keycloak/**`           | keycloak                | `AUTHENTICATION_BASE_KEYCLOAK_SERVICE_NAME` | `authentication`             | 8080  |
| 2 | `/auth-backend/**`       | authentication-backend  | `AUTHENTICATION_BACKEND_SERVICE_NAME`       | `authentication-backend`     | 8081  |
| 3 | `/auth/**`               | authentication-frontend | `AUTHENTICATION_FRONTEND_SERVICE_NAME`      | `authentication-frontend`    | 8080  |
| 4 | `/cardpgbackend/**`      | core-backend            | `CORE_BACKEND_API_SERVICE_NAME`             | `core-backend`               | 8080  |
| 5 | `/calculation-engine/**` | calculation-engine      | `CALCULATION_ENGINE_API_SERVICE_NAME`       | `geo-calculation-engine-app` | 8080  |
| 6 | `/geoserver/**`          | geoserver               | `GEOSERVER_SERVICE_NAME`                    | `geoserver`                  | 8080  |
| 7 | `/**`                    | core-frontend           | `CORE_FRONTEND_SERVICE_NAME`                | `core-frontend`              | 8080  |

> The gateway resolves each route's host via an env var — this is what allows
> the names to differ between local and K8s **without code changes**. If a name
> does not match, the gateway cannot resolve the host and the route fails
> (503/timeout).

## Local × Kubernetes matrix

| Role                | Service (compose)              | container_name (local) | Name in K8s (deployment/svc) | Differs? |
|---------------------|--------------------------------|------------------------|------------------------------|----------|
| Edge proxy          | `main-proxy`                   | `rer-proxy`            | (replaced by nginx-ingress)  | ✅ yes   |
| API Gateway         | `gateway`                      | `rer-gateway`          | `gateway`                    | no       |
| Main frontend       | `core-frontend`                | `rer-core-frontend`    | `core-frontend`              | no       |
| Main backend        | `core-backend`                 | `rer-core-backend`     | `core-backend`               | no       |
| Auth frontend       | `authentication-frontend`      | `rer-auth-frontend`    | `auth-frontend`              | ⚠️ yes   |
| Keycloak            | `authentication`               | `rer-authentication`   | `auth-keycloak`              | ⚠️ yes   |
| Auth backend        | `authentication-backend`       | `rer-auth-backend`     | `auth-backend`               | ⚠️ yes   |
| Calc engine         | `geo-calculation-engine-app`   | `rer-calc-engine`      | `calc-engine`                | ⚠️ yes   |
| GeoServer           | `geoserver`                    | `rer-geoserver`        | `geoserver`                  | no       |
| GeoServer init      | `geoserver-init`               | `rer-geoserver-init`   | (job/init)                   | —        |
| core-backend DB     | `core-backend-db`              | `rer-core-backend-db`  | (external RDS)               | ✅ yes   |
| auth DB             | `authentication-db`            | `rer-authentication-db`| (external RDS)               | ✅ yes   |
| calc DB (metadata)  | `calculator-engine-db`         | `rer-calculator-engine-db` | (external RDS)           | ✅ yes   |
| calc DB (postgis)   | `postgis-calculator-db`        | `rer-postgis-calculator-db`| (external RDS)           | ✅ yes   |

⚠️ **The 4 flagged services are the classic source of "works locally, breaks in
the cluster".** In K8s, the gateway's service-name env vars must point to the
short names (`auth-frontend`, `auth-keycloak`, `auth-backend`, `calc-engine`),
not to the long compose names. This was adjusted in the cluster gateway on
2026-09-14.

## Internal ports

- Almost everything listens on **8080** internally (nginx frontends, keycloak,
  backends, calc, geoserver).
- **Exception:** `authentication-backend` listens on **8081**.
- Databases: PostgreSQL/PostGIS on 5432 (internal to the compose networks).

## Networks (compose)

`gateway_network`, `core-backend-network`, `authentication_network`,
`geo_calc_network` — segment the traffic. The gateway joins the networks it
needs to reach each backend. On K8s this becomes ClusterIP communication (where
the kube-proxy cross-node blocker manifests).
