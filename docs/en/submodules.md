# RER-DPG Submodules Guide

Detailed reference for the Git submodules that compose the RER-DPG system.

---

## 📦 Overview

RER-DPG uses Git submodules to organize independent components. Each submodule is a separate repository with its own development lifecycle.

---

## 🔧 Main Submodules

### Core Backend
- **Repository:** `backend/`
- **Technology:** Spring Boot + PostgreSQL + PostGIS
- **Function:** Main REST API for registration management
- **Documentation:** [README](../../backend/README.md)

### Core Frontend
- **Repository:** `frontend/`
- **Technology:** Vue.js 3 + TypeScript + Vite
- **Function:** Main web interface
- **Documentation:** [README](../../frontend/README.md)

### Authentication
- **Repository:** `authentication/`
- **Technology:** Keycloak + Vue.js + PostgreSQL
- **Function:** SSO authentication and authorization system
- **Documentation:** [README](../../authentication/README.md)

### Calculation Engine
- **Repository:** `calc_engine/`
- **Technology:** Spring Boot + PostGIS
- **Function:** Geospatial calculation engine
- **Documentation:** [README](../../calc_engine/README.md)

### Gateway
- **Repository:** `gateway/`
- **Technology:** Spring Cloud Gateway
- **Function:** API Gateway for request routing
- **Documentation:** [README](../../gateway/README.md)

### Map Component
- **Repository:** `map_component/`
- **Technology:** Vue.js 3 + Leaflet + TypeScript
- **Function:** Reusable map component
- **Documentation:** [README](../../map_component/README.md)

---

## 🛠️ Working with Submodules

### Clone with Submodules

```bash
git clone --recurse-submodules https://github.com/your-user/rer-github.git
```

### Update Submodules

```bash
# Update all
git submodule update --init --recursive

# Update to latest version
git submodule update --remote --merge
```

### Make Changes in Submodule

```bash
# Enter submodule
cd backend/

# Create branch
git checkout -b feature/new-feature

# Make commits
git add .
git commit -m "Add new feature"

# Push to submodule repository
git push origin feature/new-feature

# Return to main project and update reference
cd ..
git add backend/
git commit -m "Update backend reference"
```

### Check Submodules Status

```bash
git submodule status
```

---

## 📚 Additional Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Project Structure](../../readme.en.md#project-organization)
- [System Architecture](../../readme.en.md#system-architecture)

---

**Back to:** [Main Documentation](../README.md)
