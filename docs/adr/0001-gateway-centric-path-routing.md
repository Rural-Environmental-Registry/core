# ADR-0001: Gateway-centric routing by path convention

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

The RER is composed of ~8 services (two frontends, several backends, Keycloak,
GeoServer, a calculation engine). These services must be reachable from the
browser under a single origin, and must be able to evolve independently. When
the codebase was indexed (codebase-memory, 2026-09-15), cross-repo intelligence
found **0 direct service-to-service calls** in application code — services do
not know each other's URLs.

## Decision

All traffic is routed through a single **Spring Cloud Gateway** that dispatches
by **path prefix**:

| Path | Service |
|------|---------|
| `/keycloak/**` | Keycloak |
| `/auth-backend/**` | authentication-backend |
| `/auth/**` | authentication-frontend |
| `/cardpgbackend/**` | core-backend |
| `/calculation-engine/**` | calculation-engine |
| `/geoserver/**` | geoserver |
| `/**` | core-frontend (fallback) |

Frontends and clients call **relative paths** (`/keycloak`, `/cardpgbackend`,
etc.). Coupling is by **path convention**, not by hardcoded service URLs.

## Alternatives Considered

- **Direct service-to-service URLs (service discovery):** each frontend/backend
  knows the others' hostnames. *Pros:* fewer hops. *Cons:* hardcoded topology,
  CORS complexity across origins, brittle across environments. Rejected.
- **Per-service ingress (no gateway):** each service exposed independently.
  *Pros:* simpler per-service. *Cons:* no single origin, cross-origin auth,
  duplicated TLS/routing config. Rejected.

## Consequences

- **Positive:** single origin (no CORS between modules); services swappable
  without client changes; the same relative paths work locally and on K8s.
- **Positive:** the gateway is the single place to reason about routing.
- **Negative:** the gateway is a single point of failure and a required hop.
- **Neutral:** the gateway host resolution is externalized to env vars (see
  ADR-0004), which is what makes local × K8s naming differences transparent.

## References

- `config/Gateway/application/application.yml` (route definitions).
- `docs/SERVICE-MAP.md` (path → service table).
- codebase-memory finding: 0 cross-service edges (2026-09-15).
