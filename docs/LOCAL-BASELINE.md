# RER — Local Baseline (reproducible reference)

> How to bring up the RER locally with podman using images built from the
> current source, and the "expected correct state". Serves as an **irrefutable
> reference** to compare against the HCSO cluster. Validated E2E on 2026-09-15.

## Why this baseline exists

Running the full stack locally proved that **the image composition is correct**
— the images do become working services and the auth flow works end to end.
Therefore problems observed on the cluster (e.g. cross-node ClusterIP, "Welcome
to nginx" frontend, realm 404) are **platform/CI** issues, not packaging. This
document is the reference for that comparison.

## Prerequisites

- Podman + podman-compose (validated with podman 5.8.6).
- Updated repos under `~/git/rer/` (core, frontend, backend, authentication,
  gateway, calc_engine, map_component).
- Access to `ghcr.io` (image fallback) — optional if you build everything.

## Step 1 — Update the repos

```bash
cd ~/git/rer
for d in core frontend backend authentication gateway calc_engine map_component; do
  (cd "$d" && git fetch --quiet && git merge --ff-only 2>/dev/null && \
    echo "$d: $(git branch --show-current)")
done
```

## Step 2 — Build the 7 application images (`:local`)

```bash
cd ~/git/rer
podman build --build-arg VITE_BASE_URL=/ -t rer-core-frontend:local ./frontend
podman build --build-arg BASE_PATH=/auth --build-arg VITE_BASE_URL=/auth/ \
  -t rer-auth-frontend:local ./authentication/frontend
podman build -t rer-auth-keycloak:local ./authentication
podman build -t rer-core-backend:local ./backend
podman build -t rer-auth-backend:local ./authentication/cardpg
podman build -t rer-calc-engine:local ./calc_engine
podman build -t rer-gateway:local ./gateway
```

> GeoServer is built on the fly by compose (`build:` context in
> `config/Geoserver/docker`).

## Step 3 — Image overrides in `.env`

Add to `~/git/rer/core/.env` (compose uses `${RER_*_IMAGE:-ghcr...}`):

```dotenv
# === LOCAL IMAGES (baseline override) ===
RER_CORE_FRONTEND_IMAGE=localhost/rer-core-frontend:local
RER_AUTH_FRONTEND_IMAGE=localhost/rer-auth-frontend:local
RER_AUTH_KEYCLOAK_IMAGE=localhost/rer-auth-keycloak:local
RER_CORE_BACKEND_IMAGE=localhost/rer-core-backend:local
RER_AUTH_BACKEND_IMAGE=localhost/rer-auth-backend:local
RER_CALC_ENGINE_IMAGE=localhost/rer-calc-engine:local
RER_GATEWAY_IMAGE=localhost/rer-gateway:local
```

## Step 4 — Bring up the stack

```bash
cd ~/git/rer/core
podman compose up -d
podman ps -a --format "{{.Names}}\t{{.Status}}" | grep rer | sort
```

Expected: 14 containers. The 4 databases become `healthy`; apps `Up`.
`rer-geoserver` may crash-loop (known issue — see `TROUBLESHOOTING.md` §3); it
**does not block the auth flow**.

## Step 5 — Reset the app user password (once)

`admin-cardpg` ships without a password. See `TROUBLESHOOTING.md` §1. Summary:
```bash
# realm car-dpg, user admin-cardpg -> password Admin@123
```

## Expected correct state (the reference)

### Endpoints (all should return 200)
| Endpoint | Service | Expected |
|----------|---------|----------|
| `GET /` | core-frontend | 200 (redirects to `/auth/login` if no token) |
| `GET /auth/login` | auth-frontend | 200, title "RER User Login" |
| `GET /keycloak/realms/car-dpg/.well-known/openid-configuration` | keycloak | 200 (realm exists) |
| `GET /cardpgbackend/actuator/health` | core-backend | 200 |
| `GET /calculation-engine/actuator/health` | calc-engine | 200 |

### E2E flow (proven)
1. `GET /` → redirects to `/auth/login`.
2. Login `admin-cardpg@gmail.com` / `Admin@123` → Keycloak issues the JWT
   (`Token: {...}`, `Usuário autenticado: {...}` in the console).
3. auth-frontend redirects to `/?lang=<x>&token=<JWT>`.
4. core-frontend reads `?token=` → enters **authenticated** into the portal
   (title "RER DPG", with "Register property", "Properties", "Profile").

## Credentials (local)
| Where | User | Password |
|-------|------|----------|
| App (Keycloak realm car-dpg) | `admin-cardpg@gmail.com` | `Admin@123` (after reset) |
| Keycloak admin (master realm) | `admin` | `admin` |
| GeoServer | `admin` | `geoserver` |

## Quick check
```bash
bash ~/git/rer/core/docs/scripts/verify-baseline.sh
```
