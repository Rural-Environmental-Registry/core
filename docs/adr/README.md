# Architecture Decision Records (ADR)

This directory records the significant architecture decisions for the RER
(Rural Environmental Registry / CAR-DPG). Each ADR captures the *context*, the
*decision*, and its *consequences* — the *why*, not just the *what*.

ADRs are immutable once accepted. If circumstances change, a new ADR supersedes
the old one (the old one's status is updated to `Superseded by ADR-NNNN`).

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [0001](./0001-gateway-centric-path-routing.md) | Gateway-centric routing by path convention | Accepted |
| [0002](./0002-keycloak-realm-car-dpg.md) | Keycloak as IdP with realm `car-dpg` | Accepted |
| [0003](./0003-token-handoff-via-query-param.md) | Post-login token handoff via query parameter | Accepted |
| [0004](./0004-service-name-env-overrides.md) | Service names resolved via gateway env vars | Accepted |
| [0005](./0005-containers-run-as-uid-1000.md) | Containers run as non-root uid 1000 | Accepted |
| [0006](./0006-ghcr-public-images.md) | Public application images on GHCR | Accepted |

## Convention

- File name: `{NNNN}-{slug}.md` (zero-padded 4-digit number).
- Language: **English** (open-source, international project).
- Template: `~/git/conhecimentos-de-ia/templates/adr-template.md`.
