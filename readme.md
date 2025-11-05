<p align="center">
  <img src="images/logo-rer-color.png" alt="RER Logo" width="300">
</p>

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.3-brightgreen.svg)](https://spring.io/projects/spring-boot) [![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.java.net/) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-blue.svg)](https://postgis.net/) [![R2DBC](https://img.shields.io/badge/R2DBC-Reactive-purple.svg)](https://r2dbc.io/) [![Vue.js](https://img.shields.io/badge/Vue.js-3-green.svg)](https://vuejs.org/) [![Docker](https://img.shields.io/badge/Docker-24+-blue.svg)](https://www.docker.com/)

## 📑 Table of Contents

- [Welcome to RER](#welcome-to-RER)
- [About the Project](#about-the-project)
- [Project Organization](#project-organization)
- [System Configuration Overview](#system-configuration-overview)
- [Installation](#installation)
- [System Architecture](#system-architecture)
- [Monitoring and Logs](#monitoring-and-logs)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contribution](#contribution)
- [Support](#support)

---

## Welcome to RER!

The **RER** (Rural Environmental Registry — Digital Public Good) is a modern, comprehensive solution for managing rural environmental registrations, developed as a digital public good. This project provides a robust and scalable architecture for systems that register rural land properties with support for geospatial data.

The solution is a technological platform that modernizes and expands the capabilities of the Rural Environmental Registry (CAR) by transforming it into a Digital Public Good (DPG). This approach aims to meet Brazil's specific needs while enabling replication in international contexts, promoting the interoperability and flexibility required for adapting to different legal frameworks, cultural requirements, and local realities.

Based on open-source technologies, the solution will be modular, scalable, and interoperable, and will include:

- An administrative portal for configuration and management
- A portal for registration of properties and landowners
- Robust geospatial tools

The system is designed to provide a range of innovative features, particularly a highly efficient geospatial engine that enables real-time processing and analysis of spatial data. This engine facilitates visualization and decision-making in multiple areas, such as urban planning and environmental monitoring. It serves as the core module of the CAR DPG and will be implemented as an evolution of the geospatial engine currently used by SICAR.

The solution will support multiple languages, ensuring global accessibility and adaptability to local user needs, regardless of region. Additionally, the system will be structured using microservices, ensuring greater flexibility, scalability, and ease of maintenance, allowing each component to operate independently and be updated or replaced without impacting the overall system.

The use of building blocks — a standard concept in DPGs — allows for the creation of customized solutions and integration with other platforms, providing a modular and reusable approach. This also enables components to be replaced with other technologies better suited to each country’s reality. Finally, the DPG philosophy requires the system to be made available as open-source software, ensuring full transparency regarding implementation and allowing users and developers to collaborate, customize, and continuously improve its functionalities. This approach supports ongoing innovation and integration with the global developer community, which will be fostered and encouraged by the Brazilian government.

---

## About the Project

The RER is an integrated platform that combines modern technologies to provide a complete rural environmental registration system. It follows modular/microservices architecture principles and uses Docker containers to simplify deployment and maintenance.

**Key features:**

• 🗺️ Support for geospatial data with PostGIS
• 🧩 Reusable map library using Leaflet and drawing tools
• 🔐 Robust authentication system with Keycloak
• 🌐 Modern web interface built with Vue.js 3
• ⚡ High-performance REST API with Spring Boot
• 🚪 API Gateway for intelligent routing
• 🧮 Calculation engine for data processing
• 🐳 Full containerization with Docker

Learn more about the system by accessing our [demo environment](https://rer.dataprev.gov.br).

---

## Project Organization

RER is organized as a main project with multiple Git submodules, each responsible for a specific system functionality:

### Subprojects Structure

- [**`backend/`**](https://github.com/Rural-Environmental-Registry/backend) - Main backend built with Spring Boot and PostGIS support for managing property, person, and related attribute records. It provides a complete REST API with Swagger documentation.

- [**`frontend/`**](https://github.com/Rural-Environmental-Registry/frontend) - Modern web interface developed in Vue.js 3 with Vite, offering a responsive and intuitive user experience for rural environmental data registration and visualization.

- [**`map_component/`**](https://github.com/Rural-Environmental-Registry/map_component) - Interactive map library for Vue 3, based on Leaflet, providing the dpg-mapa component with support for multiple layers, drawing tools, and event handling.

- [**`authentication/`**](https://github.com/Rural-Environmental-Registry/authentication) - Authentication and authorization system based on Keycloak with PostgreSQL, including an administrative frontend and backend for user and permission management.

- [**`calc_engine/`**](https://github.com/Rural-Environmental-Registry/calc_engine) - Calculation engine for geospatial data processing and environmental analysis, developed in Java with support for complex geoprocessing operations.

- [**`Gateway/`**](https://github.com/Rural-Environmental-Registry/gateway) - API Gateway based on Spring Cloud Gateway for intelligent routing between different microservices, including load balancing and proxy configuration.

---

## System Configuration Overview

RER offers a centralized functionality for viewing all configurations applied to the different submodules of the project. This provides great transparency and facilitates debugging, allowing administrators and developers to quickly verify the values ​​of environment variables, compilation settings, and parameters defined in various files.

### Page Access

The view page can be accessed in the **`Authentication`** submodule interface.

1. **Access the URL:** The `Authentication` administration application is available at `http://localhost/<BASE_URL>/<AUTHENTICATION_FRONTEND_CONTEXT_PATH>`.

> The variables `<BASE_URL>` and `<AUTHENTICATION_FRONTEND_CONTEXT_PATH>` are defined in the environment's [configurations](config/Main/environment/.env.example).

2. **Log in** with the following default administrator credentials:

- **Username:** `admin-cardpg@gmail.com`

- **Password:** `NewStrongPassword123!`

After logging in, the settings table will be displayed.

### How it Works

The functionality is orchestrated by several key components:

1. **Display Interface (`Authentication/frontend/src/views/AdminSettings.vue`)**: A page in the `Authentication` frontend that retrieves and displays the settings in a searchable table.

2. **Frontend Data Collection (`frontend/scripts/generate-config.sh`)**: This script runs during the `frontend` build process and collects information from files such as `.env`, `package.json`, and map configurations, consolidating them into a `config.json` file that is served statically.

3. **Backend Endpoint (`backend/src/main/java/br/car/registration/controller/AdminController.java`)**: Exposes an endpoint (`/v1/admin/app-info`) that provides server-side configurations, such as application properties (`application.properties`), environment variables, and default system attributes.
4. **Configuration Parser (`Authentication/frontend/src/helpers/table.ts`)**: A helper in the `Authentication` frontend that interprets data received from frontend and backend endpoints, identifying the source of each configuration for display in the interface.

### How to Modify Configurations

Changes should be made directly to the source files of each submodule. The table on the administration page indicates the "component" (submodule) and the "source" (file or mechanism) of each configuration.

Below are some practical examples:

| Configuration | Source | Submodule | How to Change |
| :---------------------- | :-------------------------- | :-------------- | :---------------------------------------------------------------------------------------------------------- |
| `frontend_project_name` | `package.json` | `frontend` | Change the `name` field in the `frontend/package.json` file. |
| `backend_url` | `.env` | `frontend` | Modify the `VITE_CARDPG_URL` variable in the `frontend/.env` file. |
| `default_language` | `src/config/languages.json` | `frontend` | Adjust the `defaultlanguage` key in the `frontend/src/config/languages.json` file. |
| `application_name` | `application.properties` | `backend` | Change the `spring.application.name` property in `backend/src/main/resources/application.properties`. |
| `frontend_urls` | `docker-compose.yaml` | `backend` | Define the `FRONTEND_URLS` environment variable in the corresponding service. |
| `fields.person` | `database` (hardcoded) | `backend` | Modify the `getDefaultAttributes()` method in `AdminController.java`. |

This approach ensures that each submodule remains self-contained in its settings, while providing a unified view for system administration.

---

## Installation

### Prerequisites

Before getting started, make sure you have installed:

- **Docker** version 24+ ([installation](https://docs.docker.com/engine/install/))
- **Docker Compose** version 2.20 or higher ([installation](https://docs.docker.com/compose/install/linux/#install-using-the-repository))
- **gettext** (for environment variable substitution):
  ```bash
  sudo apt install gettext-base
  ```
- **Git** ([installation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- Operating System: Linux (recommended)

### Download the Project

1. **Clone the project with submodules:**

   ```bash
   git clone --recurse-submodules https://github.com/Rural-Environmental-Registry/core.git rer
   ```

2. **Enter the Project directory:**
   ```bash
   cd rer
   ```

### Configuration

1. **Add your user to the Docker group:**

   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Review the configurations:**

   - Check and adjust the environment variables in:
     `./config/Main/environment/.env.example`
   - Review the documentation of each submodule for specific configurations, if needed.

3. **Grant execution permission to the startup script:**

   ```bash
   chmod +x ./start.sh
   ```

   > Edit `start.sh` only if necessary.

### Running with Docker

1. **Run the startup script:**

   ```bash
   ./start.sh
   ```

   This script will:

   - Prepare all environment variables
   - Configure the files for each submodule
   - Build and run all Docker containers
   - Automatically start all services

2. **Check the service status:**
   ```bash
   docker compose ps
   ```

### Accessing the Services

After successful execution, the following services will be available (based on the environment variables defined in the [configurations](config/Main/environment/.env.example)):

- **Main Frontend:** http://localhost/<BASE_URL>
- **Backend API:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>
- **backend Swagger Documentation:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>/swagger-ui/index.html
- **API Documentation:** [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)
- **Keycloak Admin:** http://localhost/<BASE_URL>/<AUTHENTICATION_BASE_KEYCLOAK_BASE_URL>/admin
- **Administrative Frontend:** http://localhost/<BASE_URL>/<AUTHENTICATION_FRONTEND_CONTEXT_PATH>/admin-login

### Default Credentials

- **System Administrator:**

  - **Username:** `admin-cardpg@gmail.com`
  - **Password:** `NovaSenhaForte123!`

- **Keycloak Admin:**
  - **Username:** `admin`
  - **Password:** `admin`

---

## System Architecture

### Overview

```
                                       ┌───────────────────────────┐
                                       │           NGINX           │
                                       │          (Proxy)          │
                                       └─────────────┬─────────────┘
                                                     │
                                       ┌─────────────▼─────────────┐
                                       │         Gateway           │
                                       │   (Spring Cloud Gateway)  │
                                       └─────────────┬─────────────┘
                                                     │
        ┌────────────────────────────────────────────┼───────────────────────────────────┐
        │                                            │                                   │
        │                                            │                                   │
┌───────▼───────────┐                    ┌───────────▼─────────┐              ┌──────────▼───────────┐
│       Core        │                    │    Autentication    │              │   Calculation Engine │
│ (Portal Cadastr.) │                    │                     │              │                      │
└───────┬───────────┘                    └──────────┬──────────┘              └──────────┬───────────┘
        │                                           │                                    │
        │                           ┌───────────────┼──────────────┐                     │
 ┌──────▼────────┐          ┌───────▼───────┐              ┌───────▼────────┐   ┌────────▼────────┐
 │ frontend │          │ Auth-Frontend │              │ Admin-Frontend │   │   Backend       │
 │ (Vue.js + TS) │───┐      │ (Vue.js + TS) │              │ (Vue.js + TS)  │   │ (Spring Boot)   │
 └──────┬────────┘   │      └───────┬───────┘              └───────┬────────┘   └────────┬────────┘
        │            │              └──────────────┬───────────────┘                     │
        │    ┌───────▼───────┐                     │                                     │
        │    │ Map Component │                     │                                     │
        │    │   (Leaflet)   │                     │                                     │
        │    └───────────────┘                     │                                     │
        │                                          │                                     │
 ┌──────▼──────────┐                       ┌───────▼────────┐                  ┌─────────▼───────────┐
 │   Backend       │                       │   Keycloak     │                  │ Database      │
 │ (Spring Boot +  │                       │ (Auth Server)  │                  │ (PostgreSQL+PostGIS │
 │  JasperReports) │                       └───────┬────────┘                  │   Cálculos)         │
 └──────┬──────────┘                               │                           └─────────────────────┘
        │                                          │
 ┌──────▼──────────┐                     ┌─────────▼───────────┐
 │ Database        │                     │ Database            │
 │ PostgreSQL +    │                     │ PostgreSQL (Keycloak│
 │ PostGIS (Core)  │                     │ DB)                 │
 └─────────────────┘                     └─────────────────────┘
```

### Data Flow

1. **User** → **frontend** (web interface)
2. **frontend** → **gateway** (HTTP requests)
3. **gateway** → **microservices** (intelligent routing)
4. **authentication** ↔ **keycloak** (login/authorization)
5. **backend** ↔ **PostgreSQL** (registration data)
6. **calc_engine** → **calculations** (geoespacial processing)

---

## Monitoring and Logs

### Check Service Status

```bash
# General Status
docker compose ps

# Logs from all services
docker compose logs -f

# Logs from a specific service
docker compose logs -f core-backend
```

### Check Service Connectivity

```bash
# Verify if services are responding
curl -f http://localhost:8080 || echo "Gateway is not responding"
```

---

## Troubleshooting

### Common Issues

#### Ports in Use

```bash
# Check for ports in use
sudo netstat -tlnp | grep :8080
```

#### Docker Permission Issues

```bash
# Add user to the Docker group
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker if needed
sudo systemctl restart docker
```

#### Outdated Submodules

```bash
# Update all submodules
git submodule update --init --recursive

# Force update
git submodule foreach git pull origin main
```

#### Cleaning Up Containers

```bash
# Stop and remove all containers
docker compose down -v

# Remove unused images
docker system prune -a
```

---

## Important Notes

- **Required Ports:** 80/443 (NGINX Proxy), 8080 (Main Gateway), 5432 (Postgres backend)
- **Minimum Requirements:** 4GB RAM, 2 CPU cores, 10GB disk space
- **Supported Systems:** Linux (recommended), macOS, Windows com WSL2
- **Persistence:** Docker volumes for PostgreSQL data and configurations
- **Security:** Change default credentials in production environments
- **Submodules:** Check each submodule’s README for advanced or customized setup instructions

---

## License

This project is distributed under the [GPL-3.0](https://github.com/Rural-Environmental-Registry/core/blob/main/LICENSE).

---

## Contribution

Contributions are welcome! To contribute to the project:

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

By submitting a pull request or patch, you affirm that you are the author of the code and that you agree to license your contribution under the terms of the GNU General Public License v3.0 (or later) for this project. You also agree to assign the copyright of your contribution to the Ministry of Management and Innovation in Public Services (MGI), the owner of this project.

### Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming and harassment-free environment for all contributors. By participating, you are expected to uphold this code. Please report unacceptable behavior through the GitHub issue tracker.

---

## Support

For technical support or project-related questions:

- **Documentation:** Check the individual READMEs for each submodule
- **Issues:** Report problems via the GitHub issue tracker

---

## Responsibilities

For technical support or questions about the project, please, fill a issue.

Copyright (C) 2024 Ministry of Management and Innovation in Public Services (MGI), Government of Brazil.

This program was developed by Dataprev as part of a contract with the Ministry of Management and Innovation in Public Services (MGI).
