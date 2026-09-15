# ADR-0006: Public application images on GHCR

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

The RER is open source and meant to be reused by different governments. The
container images should be easy to pull without private registry credentials,
and the project already lives under the `Rural-Environmental-Registry` GitHub
organization.

## Decision

Publish the application images publicly on **GitHub Container Registry (GHCR)**
under `ghcr.io/rural-environmental-registry/*` (e.g. `rer-core-frontend`,
`rer-core-backend`, `rer-gateway`). Compose references them with a version
fallback: `${RER_*_IMAGE:-ghcr.io/rural-environmental-registry/...:${RER_VERSION}}`.

## Alternatives Considered

- **Private registry (e.g. vendor SWR):** *Pros:* control. *Cons:* requires
  pull secrets, hinders reuse, not aligned with OSS goals. Kept only as a
  fallback when nodes lack egress.
- **Build on each environment:** *Pros:* no registry. *Cons:* slow,
  non-reproducible, needs build toolchain in every environment. Rejected.

## Consequences

- **Positive:** anonymous pulls; no imagePullSecret needed when nodes have
  egress; simple reuse.
- **Negative / known issue:** a broken CI/publish can push an **empty or wrong**
  image. Observed: `rer-core-frontend:1.0.0-dev` served the nginx welcome page
  instead of the SPA, while the local build of the same Dockerfile is correct —
  i.e. a CI/publish defect, not a Dockerfile defect. See
  `docs/TROUBLESHOOTING.md` §6.
- **Mitigation:** the local baseline (`docs/LOCAL-BASELINE.md`) is the reference
  to validate an image before trusting the published tag.

## References

- `docker-compose.yml` (image references + `RER_VERSION`).
- `.github/workflows/docker-build.yaml`.
- `docs/TROUBLESHOOTING.md` §6.
