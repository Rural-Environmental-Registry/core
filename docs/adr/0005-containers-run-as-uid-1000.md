# ADR-0005: Containers run as non-root uid 1000

- **Date:** 2026-09-15
- **Status:** Accepted

## Context

The RER targets a Kubernetes cluster (HCSO) where a **Kyverno** policy enforces
`runAsUser: 1000` (non-root) on pods. Images must run correctly as a non-root
user in both K8s and local podman (rootless).

## Decision

Application images declare `USER 1000` and pre-create/chown their writable
directories to `1000:1000` at build time. Services run as the non-root user in
every environment.

## Alternatives Considered

- **Run as root:** *Pros:* no permission issues. *Cons:* violates the Kyverno
  policy; insecure. Rejected.
- **Init container / entrypoint chown at runtime:** fix ownership on start.
  *Pros:* handles volume ownership. *Cons:* requires privilege to chown, which
  the non-root user lacks — this is exactly the GeoServer failure below.

## Consequences

- **Positive:** compliant with the cluster security policy; least privilege.
- **Negative / known issue:** GeoServer's **official** `startup.sh` attempts a
  runtime `chown -R` on its data dir. As uid 1000 without privilege, this fails
  (`Operation not permitted`) and crash-loops the container. This affects both
  podman rootless (named volume ownership) and K8s. Fix options: set
  `GEOSERVER_UID/GID=1000` to match the volume owner, mount with `:U` (podman),
  or avoid runtime chown. Tracked as a pending item; see
  `docs/TROUBLESHOOTING.md` §3.

## References

- Dockerfiles with `USER 1000`.
- `config/Geoserver/docker/` (entrypoint / startup).
- `docs/TROUBLESHOOTING.md` §3.
