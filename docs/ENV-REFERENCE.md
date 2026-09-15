# RER — Environment Variable Reference

> All RER variables: runtime (`.env`), frontend build-args (`VITE_*`), and what
> each one means. Derived from `.env.example`, the frontends' `.env.production`
> files, and the Dockerfiles' `ARG`/`ENV`. Last updated: 2026-09-15.

---

## Runtime — `.env` (compose)

### General / URL
| Var | Local default | Description |
|-----|---------------|-------------|
| `HTTP_HTTPS` | `http` | Scheme. Local `http`; K8s/prod `https`. |
| `HOSTNAME_DNS` | `localhost` | Public host. K8s: `rerdev.dataprev.gov.br`. |
| `BASE_URL` | *(empty)* | App sub-path (if served in a subdirectory). |
| `APP_URL` | `${HTTP_HTTPS}://${HOSTNAME_DNS}${BASE_URL}` | Composed app URL. |
| `RER_HTTP_PORT` | `80` | Host port for `main-proxy`. |
| `RER_VERSION` | `1.0.0` | GHCR image tag (compose fallback). |
| `FRONTEND_URLS` | `${scheme}://${host},http://localhost:5173` | Allowed origins (CORS/redirect). |

### Core backend (car_db)
| Var | Default | Description |
|-----|---------|-------------|
| `CORE_BACKEND_DB_NAME` | `car_db` | Database name. |
| `CORE_BACKEND_DB_USER` | `car_user` | User. |
| `CORE_BACKEND_DB_PASSWORD` | *(secret)* | Password. |
| `CORE_BACKEND_API_HASH_PREFIX` | `BR` | Receipt hash prefix. |
| `CORE_BACKEND_API_RECEIPT_LOGO_PATH` | `images/govbr.svg` | Receipt logo. |
| `CORE_BACKEND_API_WATERMARK_IMAGE_PATH` | `images/unofficial.svg` | Watermark. |
| `CORE_BACKEND_API_GENERAL_INFORMATION_RECEIPT_PATH` | `reports/GENERAL_INFORMATION.txt` | Receipt text. |
| `CORE_BACKEND_API_REPORT_PARAMS_RECEIPT_JSON` | `reports/report_params.json` | Report params. |
| `CORE_BACKEND_API_DEFAULT_LOCATION_ZONE` | `Europe/London` | ⚠️ Default timezone — for pt-BR review to `America/Sao_Paulo`. |

### Auth / Keycloak (keycloak db)
| Var | Default | Description |
|-----|---------|-------------|
| `AUTH_DB_NAME` | `keycloak` | Keycloak database. |
| `AUTH_DB_USER` | `keycloak` | User. |
| `AUTH_DB_PASSWORD` | *(secret)* | Password. |
| `KEYCLOAK_ADMIN_USER` | `admin` | Keycloak admin (master realm). |
| `KEYCLOAK_ADMIN_PASSWORD` | *(secret, `admin` local)* | Admin password. |

### Calc engine (2 databases)
| Var | Default | Description |
|-----|---------|-------------|
| `CALC_ENGINE_DB_NAME` | `calculator_engine` | Metadata database. |
| `CALC_ENGINE_DB_USER` | `calculator_engine` | User. |
| `CALC_ENGINE_DB_PASSWORD` | *(secret)* | Password. |
| `CALC_POSTGIS_DB_NAME` | `postgis_calculator` | PostGIS database (geometries). |
| `CALC_POSTGIS_DB_USER` | `postgis_calculator` | User. |
| `CALC_POSTGIS_DB_PASSWORD` | *(secret)* | Password. |

### GeoServer
| Var | Default | Description |
|-----|---------|-------------|
| `GEOSERVER_ADMIN_USER` | `admin` | Admin. |
| `GEOSERVER_ADMIN_PASSWORD` | *(secret, `geoserver` local)* | Password. |
| `GEOSERVER_WORKSPACE_NAME` | `rer` | Workspace. |
| `GEOSERVER_DATASTORE_NAME` | `db` | Datastore. |

### Image overrides (local baseline)
To use locally built images instead of GHCR, compose uses
`${RER_*_IMAGE:-ghcr.io/...}`. Set in `.env`:
`RER_CORE_FRONTEND_IMAGE`, `RER_AUTH_FRONTEND_IMAGE`, `RER_AUTH_KEYCLOAK_IMAGE`,
`RER_CORE_BACKEND_IMAGE`, `RER_AUTH_BACKEND_IMAGE`, `RER_CALC_ENGINE_IMAGE`,
`RER_GATEWAY_IMAGE` → `localhost/<img>:local`.

---

## Frontend build-args (`VITE_*`)

> `VITE_*` is **build-time** (baked into the bundle), not runtime. Changing it
> requires a frontend **rebuild**, not just a restart. Passed as `--build-arg`.

### auth-frontend (`authentication/frontend`)
Build: `--build-arg BASE_PATH=/auth --build-arg VITE_BASE_URL=/auth/`

| Var | Value (`.env.production`) | Description |
|-----|---------------------------|-------------|
| `VITE_BASE_URL` | `/auth/` | Auth SPA base path. |
| `VITE_KEYCLOAK_API_URL` | `/keycloak` | Keycloak route (via gateway). |
| `VITE_BACKEND_API_URL` | `/auth-backend` | auth-backend route. |
| `VITE_BACKEND_CONFIG_URL` | `/auth-backend` | auth-backend config. |
| `VITE_FRONTEND_CONFIG_URL` | `/auth` | This front's config. |
| `VITE_FRONTEND_USR_URL` | `/` | ⚠️ **Post-login redirect target** (core-frontend). See note below. |
| `VITE_GOV_CLIENT_ID` | *(empty)* | gov.br client (SSO). |
| `VITE_GOV_URL` | *(empty)* | gov.br URL (SSO). |
| `VITE_REDIRECT_PARAMS_LANG` | `true` | Appends `?lang=` on redirect. |
| `VITE_REDIRECT_PARAMS_TOKEN` | `true` | Appends `?token=` on redirect. |

> ⚠️ **`VITE_FRONTEND_USR_URL` — fixed pitfall:** the code did
> `new URL(VITE_FRONTEND_USR_URL)`. With a relative value (`/`), `new URL('/')`
> throws `TypeError: Invalid URL` and silently breaks the post-login redirect
> ("Error while logging in" despite the token). Fixed in `redirect.ts` to
> `new URL(target, window.location.origin)` — now accepts relative (`/`) or
> absolute (`http://host/`) on any environment without hardcoding.

### core-frontend (`frontend`)
Build: `--build-arg VITE_BASE_URL=/`

| Var | Value (`.env.production`) | Description |
|-----|---------------------------|-------------|
| `VITE_BASE_URL` | `/` | Main SPA base path. |
| `VITE_GEOSERVER_URL` | `/geoserver` | GeoServer route. |
| `VITE_AUTH_MODULE_URL` | `/auth` | Auth module route. |
| `VITE_CALCULATION_ENGINE_BASE_URL` | `/calculation-engine` | Calc engine route. |
| `VITE_DPG_URL` | `/cardpgbackend/v1` | core-backend route (API v1). |
| `APP_VERSION` (ARG) | `0.0.0` | Version shown in the footer. |

---

## Local × K8s rule of thumb

- **Runtime (`.env`):** set `HTTP_HTTPS=https`, `HOSTNAME_DNS=rerdev...`,
  passwords via sealed-secrets on K8s.
- **Build-args (`VITE_*`):** since they are relative (`/auth`, `/keycloak`,
  etc.) and go through the gateway, they **work the same locally and on K8s** —
  as long as the gateway routes the paths correctly (see `SERVICE-MAP.md`). The
  historical exception was `VITE_FRONTEND_USR_URL`, already fixed in the code.
