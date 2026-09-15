# ADR-0003: Post-login token handoff via query parameter

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

Authentication is handled by a dedicated SPA (`authentication-frontend`, served
at `/auth`), separate from the main SPA (`core-frontend`, served at `/`). After
a successful login, the JWT obtained from Keycloak must reach the main SPA,
which lives at a different base path (a different SPA bundle/context).

## Decision

After login, the auth-frontend redirects the browser to the core-frontend's URL
with the token appended as a **query parameter**:

```
/?lang=<language>&token=<JWT>
```

This is controlled by `VITE_REDIRECT_PARAMS_TOKEN=true` (token) and
`VITE_REDIRECT_PARAMS_LANG=true` (language). The core-frontend reads `?token=`
on load and establishes the authenticated session. The redirect target is
`VITE_FRONTEND_USR_URL`.

## Alternatives Considered

- **Shared cookie / same-site session:** rely on a cookie readable by both SPAs.
  *Pros:* token not exposed in the URL. *Cons:* requires same registrable
  domain and careful cookie scoping; harder across the `/auth` vs `/` split and
  across environments. Not the chosen path.
- **postMessage / shared storage bridge:** *Pros:* no token in URL. *Cons:*
  more moving parts; both SPAs must be loaded simultaneously. Rejected for
  simplicity.

## Consequences

- **Positive:** simple, stateless handoff that works across separate SPA
  bundles and any host.
- **Negative:** the JWT appears in the URL (browser history, referrer, logs).
  Mitigations: short token lifetime, HTTPS in non-local environments, and the
  core-frontend should strip the token from the URL after reading it.
- **Pitfall (fixed):** the redirect used `new URL(VITE_FRONTEND_USR_URL)`. With
  a relative value (`/`) this throws `TypeError: Invalid URL`, silently breaking
  the redirect ("Error while logging in" despite a valid token). Fixed in
  `redirect.ts` to `new URL(target, window.location.origin)`, accepting relative
  or absolute values on any host. See `docs/TROUBLESHOOTING.md` §2.

## References

- `authentication/frontend/src/helpers/redirect.ts`.
- `authentication/frontend/src/views/UserLogin.vue`.
- `docs/ENV-REFERENCE.md` (VITE_FRONTEND_USR_URL, VITE_REDIRECT_PARAMS_*).
