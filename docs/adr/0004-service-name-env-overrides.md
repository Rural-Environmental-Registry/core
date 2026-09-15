# ADR-0004: Service names resolved via gateway environment variables

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

The RER runs in multiple environments with **different service names**. Locally
(compose) the auth frontend is `authentication-frontend` and the calc engine is
`geo-calculation-engine-app`; on Kubernetes they are `auth-frontend` and
`calc-engine`. The gateway must reach each backend by name in both cases without
code changes.

## Decision

Each gateway route resolves its target host from an **environment variable**
with a sensible local default, e.g.:

```
uri: http://${CALCULATION_ENGINE_API_SERVICE_NAME:geo-calculation-engine-app}:8080
```

Deployments set these env vars to the correct names per environment
(`AUTHENTICATION_FRONTEND_SERVICE_NAME`, `AUTHENTICATION_BASE_KEYCLOAK_SERVICE_NAME`,
`CALCULATION_ENGINE_API_SERVICE_NAME`, etc.).

## Alternatives Considered

- **Same names everywhere:** rename K8s services to match compose (or vice
  versa). *Pros:* no env indirection. *Cons:* couples naming conventions across
  very different platforms; K8s prefers short names. Rejected.
- **Separate gateway config per environment:** maintain distinct
  `application.yml` files. *Pros:* explicit. *Cons:* config drift, duplication.
  Rejected in favor of a single config parameterized by env vars.

## Consequences

- **Positive:** one gateway image/config for all environments; naming
  differences are transparent.
- **Negative:** a misconfigured env var causes the gateway to fail to resolve
  the host (503/timeout) — a classic "works locally, breaks in the cluster"
  cause. This was hit and fixed on the cluster on 2026-09-14.
- **Mitigation:** the local × K8s name mapping is documented in
  `docs/SERVICE-MAP.md`.

## References

- `config/Gateway/application/application.yml`.
- `docker-compose.yml` (gateway `environment:` block).
- `docs/SERVICE-MAP.md`.
