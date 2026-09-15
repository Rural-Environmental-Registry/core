# RER — Troubleshooting

> Symptom → cause → fix catalog, derived from real problems encountered while
> operating the RER locally (podman) and on the HCSO cluster. Last updated:
> 2026-09-15.

---

## Local (podman/compose)

### 1. Login returns 401 from Keycloak
- **Symptom:** on login, the console shows `401` on
  `POST /keycloak/realms/car-dpg/protocol/openid-connect/token` and
  "Session expired / Authentication error".
- **Cause:** the user exists in the `car-dpg` realm but has **no password set**
  (or a different password than expected). The `INSTALL-LOCAL.md` warns that the
  `admin-cardpg` password must be reset via Keycloak admin.
- **Fix:** reset it via the Keycloak admin API.
  ```bash
  # admin token (master realm), admin/admin by default
  TOKEN=$(curl -s -X POST "http://localhost/keycloak/realms/master/protocol/openid-connect/token" \
    -d client_id=admin-cli -d username=admin -d password=admin -d grant_type=password \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])")
  # find the user id
  curl -s -H "Authorization: Bearer $TOKEN" \
    "http://localhost/keycloak/admin/realms/car-dpg/users?max=20"
  # reset (204 = ok)
  curl -X PUT -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    "http://localhost/keycloak/admin/realms/car-dpg/users/<USER_ID>/reset-password" \
    -d '{"type":"password","value":"Admin@123","temporary":false}'
  ```

### 2. "Error while logging in" even though the token was issued (FIXED bug)
- **Symptom:** login authenticates (JWT appears in the console: `Token: {...}`
  and `Usuário autenticado: {...}`), but the screen shows "Error while logging
  in" and **does not redirect** to the portal.
- **Cause:** `authentication/frontend/src/helpers/redirect.ts` called
  `new URL(import.meta.env.VITE_FRONTEND_USR_URL)` with the var set to a
  **relative** value (`/`). `new URL('/')` throws `TypeError: Invalid URL`
  because it requires an absolute URL or a base. The exception was caught by the
  login's `catch` and surfaced the generic error, even with the token in hand.
- **Fix:**
  ```ts
  const target = import.meta.env.VITE_FRONTEND_USR_URL as string
  let url = new URL(target, window.location.origin) // accepts relative OR absolute
  ```
  Works on any host (local, HCSO, prod) with no hardcoding.

### 3. GeoServer crash-loop (`Exited 1`) — PENDING
- **Symptom:** `rer-geoserver` restarts with
  `chown: /var/geoserver/datadir: Operation not permitted` (many lines).
- **Cause:** the container runs as uid 1000 (non-root, via `USER 1000` in the
  Dockerfile). The **official** `startup.sh` from the
  `docker.osgeo.org/geoserver` image tries `chown -R` on the data dir mounted as
  a named volume → without privilege it fails, and `set -e` kills the process.
- **Fix (proposed, not applied):** still open. Options: (a) set
  `GEOSERVER_UID=1000`/`GEOSERVER_GID=1000` in compose to match the volume
  owner; (b) mount the volume with `:U` (podman rootless auto-chown); (c) avoid
  a named volume on the data dir in dev. **Not critical** — geoserver is outside
  the auth/E2E flow. Relevant for K8s (Kyverno enforces uid 1000).

### 4. Non-blocking warnings
- `HEALTHCHECK is not supported for OCI image format and will be ignored`
  (podman) — the compose `condition: service_healthy` clauses may not gate
  startup order like Docker does. If a service starts before its DB, restart it.
- core-frontend build: `grep: .../map_component/src/handlers/constants.ts: No
  such file` — a file went missing after a `map_component` pull; the build
  completes anyway. Runtime impact to be verified (pending).

---

## Cluster (HCSO — cce-rer-np)

### 5. ClusterIP unreachable cross-node (PLATFORM blocker)
- **Symptom:** a request to a ClusterIP works when the destination pod is on the
  **same node** (200) but fails (000, no SYN-ACK) when the destination is on a
  **remote node**. Direct pod-to-pod cross-node works.
- **Cause:** kube-proxy (mode `iptables`) does not perform the ClusterIP→PodIP
  DNAT on a remote node in the `cce-rer-np` cluster. It is not MTU (the failure
  is on the SYN, not on a large packet). A soft node reboot does not fix it (not
  a transient state).
- **Fix:** not fixable via UI/kubectl — it is the node's data plane (CCE).
  Escalate to the vendor (Huawei via Ana/Scovini), as was done with the previous
  DNS blocker. **Platform-dependent.**

### 6. `rer-core-frontend:1.0.0-dev` image serves "Welcome to nginx"
- **Symptom:** at `https://rerdev.dataprev.gov.br` the infra responds but the
  frontend shows the nginx welcome page, not the SPA.
- **Likely cause:** an issue in the GHCR image **CI/publish** (build did not run
  / published an empty tag). The local baseline **proves the Dockerfile is
  correct** (locally it serves the "RER DPG" SPA). So the defect is not the
  Dockerfile.
- **Fix:** investigate the GHCR build/publish workflow; compare the local
  `rer-core-frontend:local` image (works) with the GHCR one.

### 7. Realm `car-dpg` returns 404 on the cluster (to be verified)
- **Expected symptom:** if `/keycloak/realms/car-dpg/...` returns 404 on the
  cluster (while locally it returns 200).
- **Likely cause:** the **realm import** did not run on the cluster's Keycloak
  (the realm exists locally because the baseline imports it). Not an image
  problem.
- **Fix:** ensure the realm import runs in the Keycloak deployment on K8s.
