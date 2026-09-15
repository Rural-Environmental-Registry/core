# RER — Architecture (overview)

> High-level view of the RER. Routing details in `SERVICE-MAP.md`, variables in
> `ENV-REFERENCE.md`. Last updated: 2026-09-15.
> **Note:** this document was refined after indexing the repos with
> codebase-memory (routes and controllers extracted from the actual code).

## What the RER is

A Rural Environmental Registry system (CAR-DPG), open source, composed of ~8
application services + databases, orchestrated behind a gateway. Frontends in
Vue/Vite (gov.br Design System), backends in Spring Boot, authentication via
Keycloak, geospatial component via GeoServer + a calculation engine.

## Request chain

```
                          ┌───────────────────────────────────────────┐
   internet ──▶ main-proxy │ gateway (Spring Cloud Gateway)            │
   (:80 local  (nginx)     │                                           │
    or ELB+                │  /keycloak/**          → keycloak         │
    nginx-ingress          │  /auth-backend/**      → auth-backend     │
    on K8s)                │  /auth/**              → auth-frontend    │
                           │  /cardpgbackend/**     → core-backend     │
                           │  /calculation-engine/**→ calc-engine      │
                           │  /geoserver/**         → geoserver        │
                           │  /**                   → core-frontend    │
                           └───────────────────────────────────────────┘
```

## Services (roles)

- **main-proxy** (nginx) — local edge; on K8s it is replaced by nginx-ingress.
- **gateway** (Spring Cloud Gateway) — routes by path; hosts resolved via env
  var (allows names to differ local × K8s without code changes).
- **core-frontend** (Vue/Vite) — main SPA ("RER DPG"), user portal.
- **core-backend** (Spring Boot) — registration API (`/cardpgbackend`), `car_db`.
- **authentication-frontend** (Vue/Vite) — login SPA (`/auth`).
- **authentication (keycloak)** — IdP, realm `car-dpg`, client `car-dpg-app`.
- **authentication-backend** (Spring Boot) — auth support (`/auth-backend`), port 8081.
- **calc-engine** (geo-calculation-engine) — geospatial calculations; 2 databases
  (metadata + PostGIS).
- **geoserver** — OGC services (WMS/WFS), workspace `rer`.
- **Databases** — 4 PostgreSQL/PostGIS locally; on K8s they are external RDS.

## Authentication flow (proven E2E)

```
1. Browser → GET /                      (core-frontend, no token)
2.          → redirect /auth/login       (auth-frontend)
3. Login (email/password)
   → POST /keycloak/realms/car-dpg/protocol/openid-connect/token
   → Keycloak issues JWT (access/refresh/id token)
4. auth-frontend validates the user and builds the redirect:
   → /?lang=<x>&token=<JWT>              (helpers/redirect.ts)
5. core-frontend reads ?token= → authenticated (portal "RER DPG")
```

Details:
- Keycloak client used by login: `car-dpg-app` (directAccessGrants).
- The token travels from auth-frontend to core-frontend **via query param**
  (`?token=`), controlled by `VITE_REDIRECT_PARAMS_TOKEN=true`.
- `VITE_FRONTEND_USR_URL` defines the redirect target (see the pitfall in
  `ENV-REFERENCE.md` / `TROUBLESHOOTING.md` §2).

## Backend controllers (from the code)

- **PropertyController** — property registration core: `addProperty` (with map
  image upload), `updateProperty`, `getProperty`, `getProperties` (filter +
  pagination), `getPropertyImage`, `getReceipt` (PDF).
- **CalculationController** — environmental area calculations.
- **UserController** — user management.
- **AdminController** — administration.
- **GlobalExceptionHandler** — centralized error handling.

## Local × Kubernetes (summary)

- **Same:** gateway, core-frontend, core-backend, geoserver.
- **Name differs:** auth-frontend, keycloak, auth-backend, calc-engine
  (adjusted via gateway env vars). See the matrix in `SERVICE-MAP.md`.
- **Topology differs:** local uses nginx-proxy + containerized DBs; K8s uses
  ELB + nginx-ingress (TLS) + external RDS.
- **Cluster blocker:** kube-proxy does not perform ClusterIP DNAT cross-node
  (`TROUBLESHOOTING.md` §5).

## Architectural finding (from indexing)

Cross-repo intelligence detected **0 direct service-to-service calls**. This is
not a gap — it reflects the architecture: the RER is **gateway-centric**, and
the frontends call relative paths (`/keycloak`, `/cardpgbackend`) that go
through the gateway. Coupling is **by path convention**, not by service URLs in
the code. (Candidate for an ADR.)

## References

- `SERVICE-MAP.md` — routing and local×K8s matrix.
- `ENV-REFERENCE.md` — variables.
- `LOCAL-BASELINE.md` — how to reproduce and the expected state.
- `TROUBLESHOOTING.md` — known issues.
