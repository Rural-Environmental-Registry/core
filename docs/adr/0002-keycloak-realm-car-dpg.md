# ADR-0002: Keycloak as identity provider with realm `car-dpg`

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

The RER needs authentication and authorization for rural declarants, managers,
and administrators, with roles, and a path toward government SSO (gov.br). It is
an open-source system meant to be reused by different governments, so the IdP
must be self-hostable and standards-based (OIDC).

## Decision

Use **Keycloak** as the identity provider, with a dedicated realm **`car-dpg`**
and a confidential client **`car-dpg-app`** (direct access grants enabled). The
realm is reachable through the gateway at `/keycloak/**`. Tokens are OIDC JWTs
(access/refresh/id) carrying the user's roles (`realm-admin`, `manage-property`,
`view-property`, etc.).

## Alternatives Considered

- **Custom auth in the backend:** *Pros:* no extra service. *Cons:* reinventing
  OIDC, no federation/SSO, security burden. Rejected.
- **Managed cloud IdP (Auth0/Cognito):** *Pros:* less ops. *Cons:* not
  self-hostable, vendor lock-in, unfit for a reusable OSS gov system. Rejected.

## Consequences

- **Positive:** standard OIDC, roles, and a clear path to gov.br federation;
  self-hostable; realm export/import makes environments reproducible.
- **Negative:** an extra stateful service (Keycloak + its database) to operate.
- **Operational note:** the realm must be **imported** in every environment. If
  `/keycloak/realms/car-dpg/...` returns 404 on a cluster while working locally,
  the realm import did not run there — not an image problem. See
  `docs/TROUBLESHOOTING.md` §7.

## References

- `authentication/` (Keycloak image + realm).
- `docs/ARCHITECTURE.md` (authentication flow).
- ADR-0003 (token handoff to the main SPA).
