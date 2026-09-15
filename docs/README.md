# RER — Architecture & Operations Documentation

Reference documentation for the RER (Rural Environmental Registry / CAR-DPG),
derived from the actual source code and from the locally validated end-to-end
baseline. This is the foundation for the PRD, ADRs and scaffold work.

## Index

| Document | Contents |
|----------|----------|
| [PRD.md](./PRD.md) | Product requirements (descriptive of the current state): problem, personas, features, EARS acceptance criteria. |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Overview: services, request chain, authentication flow. |
| [SERVICE-MAP.md](./SERVICE-MAP.md) | Local × Kubernetes matrix, gateway routing (path → service). |
| [ENV-REFERENCE.md](./ENV-REFERENCE.md) | All variables (runtime + `VITE_*` build-args). |
| [LOCAL-BASELINE.md](./LOCAL-BASELINE.md) | Reproducible step-by-step + expected correct state. |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Real issues (local and cluster): symptom → cause → fix. |
| [adr/](./adr/) | Architecture Decision Records (why decisions were made). |
| `scripts/verify-baseline.sh` | Checks the baseline endpoints (✅/❌). |

### Pre-existing documentation (in the repo)

| Document | Contents |
|----------|----------|
| [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) | Car Registration API documentation. |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Guide for contributing to the RER-DPG documentation. |
| `CAR DPG - User Manual ... PT-BR.pdf` | User manual (property registration module), Portuguese. |
| `CAR DPG - User Manual ... EN.pdf` | User manual, English. |

## Current status (2026-09-15)

- **Local baseline (podman):** validated end-to-end — the full authentication
  flow works.
- **Bug fixed:** post-login redirect (`redirect.ts`).
- **HCSO cluster (cce-rer-np):** blocked by networking (kube-proxy cross-node) —
  a platform-level issue, to be escalated to the vendor.
- **Pending:** local geoserver crash (non-critical), empty GHCR core-frontend
  image (CI), realm import on the cluster.

## Convention

Living documentation: **if the fact changes, the doc changes in the same
commit.** All documentation and commit messages for RER are written in English
(open-source, international project).
