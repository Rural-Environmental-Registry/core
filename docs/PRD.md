# PRD — RER (Rural Environmental Registry / CAR-DPG)

> **Nature of this document:** the RER is an **existing, running system**, not a
> new feature. This PRD is **descriptive** — it documents what the system IS
> today, derived from the actual source code (codebase-memory index of 5 repos,
> 2026-09-15), the E2E-validated local baseline, and the user manuals
> (`CAR DPG - User Manual`, PT-BR/EN). It is the basis for the ADRs and the
> scaffold. Where something is future intent (not implemented), it is marked
> **[FUTURE]**.

---

## 1. Problem

The Rural Environmental Registry requires rural property owners and holders to
register the boundaries and environmental characteristics of their land
(permanent preservation areas, legal reserve, consolidated use). The manual
process is slow, error-prone, and hard to audit. The RER (CAR-DPG) digitizes
this registration: it lets users draw the property on a map, automatically
compute the environmental areas, validate the data, and issue an official
receipt — as free software, reusable by different governments.

## 2. Personas

- **Primary — Rural owner/holder (declarant):** registers their land, draws the
  boundaries on the map, provides property rights and documents, tracks status,
  and obtains the receipt. Low digital literacy assumed — gov.br Design System
  UX, multilingual (PT-BR/EN/ES).
- **Secondary — Environmental manager/analyst:** browses registered properties,
  filters by municipality/state, reviews the computed areas.
- **Admin — System administrator:** user and configuration management (via
  `AdminController` + Keycloak).

## 3. Features (extracted from the code)

### F1 — Authentication and user account
Email/password login via Keycloak (realm `car-dpg`, client `car-dpg-app`), with
a **gov.br login** option [partial], account registration, and recovery. JWT
propagated across modules. Source: `authentication/` (auth-frontend + Keycloak +
auth-backend), `UserController`.

### F2 — Rural property registration (core)
Create, edit, and query a property, with **map image upload** and location
data. Source: `PropertyController` — `addProperty`, `updateProperty`,
`getProperty`, `getProperties` (filter + pagination), `getPropertyImage`.

### F3 — Geospatial drawing on the map
Draw/edit the property boundaries over map layers (Leaflet), with context layers
served by GeoServer (workspace `rer`). Source: `frontend/src/config/map/*`
(MapHandler, layers), `map_component`.

### F4 — Automatic environmental area calculation
Compute areas (APP, legal reserve, consolidated use, etc.) from the declared
geometry. Source: `calc_engine` (geospatial engine + PostGIS),
`CalculationController` in the backend, route `/calculation-engine/**`.

### F5 — Registration validation
Validate fields and property rights before submission. Source: `frontend` —
`ValidationHelper`, `Property.validation`, `PropertyRights`.

### F6 — Receipt issuance (PDF)
Generate an official PDF receipt, with the gov.br logo and an "unofficial"
watermark in non-production environments. Source: `PropertyController.getReceipt`,
config `CORE_BACKEND_API_RECEIPT_LOGO_PATH` / `WATERMARK_IMAGE_PATH`.

### F7 — Administration
User and configuration management. Source: `AdminController`, Keycloak admin.

## 4. Acceptance Criteria (EARS)

- **Ubiquitous:** The system shall authenticate every access to protected areas
  via a JWT issued by the `car-dpg` realm.
- **Event-driven:** When the declarant submits the property registration, the
  system shall validate the required fields and persist the property with the
  associated map image.
- **Event-driven:** When the declarant requests the receipt, the system shall
  generate a PDF with the property data and the computed areas.
- **State-driven:** While the user is authenticated, the system shall display
  the portal ("RER DPG") with the options Register property / Properties /
  Profile.
- **Unwanted:** If authentication fails (401 from Keycloak), then the system
  shall redirect to `/auth/login` and show an error message.
- **Unwanted:** If the requested property does not exist, then the system shall
  return 404 ("Property not found").
- **Optional:** Where a language is selected (PT-BR/EN/ES), the system shall
  render the interface and the redirect (`?lang=`) in that language.

## 5. Constraints / Non-functional requirements

- **Gateway-centric architecture:** all traffic goes through the Spring Cloud
  Gateway; modules couple by **path convention** (`/auth`, `/keycloak`,
  `/cardpgbackend`, `/calculation-engine`, `/geoserver`), not by hardcoded
  service URLs. (See ADR — indexing finding: 0 direct cross-service calls.)
- **Accessibility / i18n:** gov.br Design System, multilingual.
- **Open source:** reusable; images published to GHCR
  (`ghcr.io/rural-environmental-registry/*`).
- **Deployment:** local via podman/compose (14 containers) and Kubernetes
  (HCSO), with divergent service names adjusted via env vars in the gateway
  (see `SERVICE-MAP.md`).
- **Security:** containers run as uid 1000 (Kyverno on K8s); secrets via
  environment variables / sealed-secrets.

## 6. Out of scope (of this documentation)

- Re-engineering of features — this PRD documents the current state.
- Full gov.br SSO integration (the button exists, `VITE_GOV_*` config empty — **[FUTURE]**).
- Data migration from legacy CAR systems.

## 7. References

- Code: repos `~/git/rer/{gateway,backend,authentication,frontend,calc_engine}`
  (indexed in codebase-memory).
- `ARCHITECTURE.md`, `SERVICE-MAP.md`, `ENV-REFERENCE.md`, `LOCAL-BASELINE.md`,
  `TROUBLESHOOTING.md`.
- `CAR DPG - User Manual - Rural Property Registration Module` (PT-BR/EN).
- E2E baseline validated 2026-09-15.
