# RER-DPG – Rural Property Registration System

## Welcome to CAR-DPG!

The RER-DPG (Rural Environmental Registry – Digital Public Good) is a comprehensive and modern solution for managing rural environmental registrations, developed as a digital public good. This project provides a robust and scalable architecture for rural property registration systems with support for geospatial data.

---

## About the Project

The CAR-DPG is an integrated platform that combines modern technologies to provide a complete rural environmental registration system. It follows modular/microservices architecture principles and uses Docker containers to simplify deployment and maintenance.

**Key features:**

• 🗺️ Support for geospatial data with PostGIS
• 🧩 Reusable map library using Leaflet and drawing tools
• 🔐 Robust authentication system with Keycloak
• 🌐 Modern web interface built with Vue.js 3
• ⚡ High-performance REST API with Spring Boot
• 🚪 API Gateway for intelligent routing
• 🧮 Calculation engine for data processing
• 🐳 Full containerization with Docker


---

## Project Organization

RER-DPG is organized as a main project with multiple Git submodules, each responsible for a specific system functionality:

### Subprojects Structure

- [**`Core-Backend/`**](https://inovacao.dataprev.gov.br/git/car-dpg/car-dpg-backend) - Main backend built with Spring Boot and PostGIS support for managing property, person, and related attribute records. It provides a complete REST API with Swagger documentation.

- [**`Core-Frontend/`**](https://inovacao.dataprev.gov.br/git/car-dpg/vuejs-car-dpg-frontend) - Modern web interface developed in Vue.js 3 with Vite, offering a responsive and intuitive user experience for rural environmental data registration and visualization.

- [**`Map-Component/`**](https://inovacao.dataprev.gov.br/git/car-dpg/map-component) - Interactive map library for Vue 3, based on Leaflet, providing the dpg-mapa component with support for multiple layers, drawing tools, and event handling.

- [**`Authentication/`**](https://inovacao.dataprev.gov.br/git/car-dpg/admin-panel) - Authentication and authorization system based on Keycloak with PostgreSQL, including an administrative frontend and backend for user and permission management.

- [**`Calculation-Engine/`**](https://inovacao.dataprev.gov.br/git/car-dpg/calculation-engine) - Calculation engine for geospatial data processing and environmental analysis, developed in Java with support for complex geoprocessing operations.

- [**`Gateway/`**](https://inovacao.dataprev.gov.br/git/car-dpg/spring-cloud-gateway) - API Gateway based on Spring Cloud Gateway for intelligent routing between different microservices, including load balancing and proxy configuration.


---

## Installation

### Prerequisites

Before getting started, make sure you have installed:

- **Docker** version 24+ ([instalação](https://docs.docker.com/engine/install/))
- **Docker Compose** version 2.20 or higher([installation](https://docs.docker.com/compose/install/linux/#install-using-the-repository))
- **Git** ([installation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- Access to Dataprev’s GitLab repository (username and password)
- Operating System: Linux (recommended)

### Download the Project

1. **Clone the project with submodules:**

   ```bash
   git clone --recurse-submodules https://inovacao.dataprev.gov.br/git/car-dpg/main.git Main
   ```

   > **Note:** You will be prompted to provide your GitLab username and password for the main project and each submodule.

2. **Enter the Project directory:**
   ```bash
   cd Main
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
- **Core-Backend Swagger Documentation:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>/swagger-ui/index.html
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
 │ Core-Frontend │          │ Auth-Frontend │              │ Admin-Frontend │   │   Backend       │
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

1. **User** → **Core-Frontend** (web interface)
2. **Frontend** → **Gateway** (HTTP requests)
3. **Gateway** → **Microservices** (intelligent routing)
4. **Authentication** ↔ **Keycloak** (login/authorization)
5. **Core-Backend** ↔ **PostgreSQL** (registration data)
6. **Calculation-Engine** → **Calculations** (geoespacial processing)

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

- **Required Ports:** 80/443 (NGINX Proxy), 8080 (Main Gateway), 5432 (Postgres Core-Backend)
- **Minimum Requirements:** 4GB RAM, 2 CPU cores, 10GB disk space
- **Supported Systems:** Linux (recommended), macOS, Windows com WSL2
- **Persistence:** Docker volumes for PostgreSQL data and configurations
- **Security:** Change default credentials in production environments
- **Submodules:** Check each submodule’s README for advanced or customized setup instructions

---

## License

This project is distributed under the [MIT License](https://opensource.org/license/mit).

### What does this mean in practice?

- ✅ **Free to use for public, private, or commercial purposes
- ✅ **Allows adaptation and integration into other solutions
- ✅ **Encourages collaboration and reuse as a digital public good
- ⚠️ Software is provided “as is”, without any warranty
- ⚠️ There is no obligation to publish improvements, but contributing back to the community is strongly encouraged

---

## Contribution

Contributions are welcome! To contribute to the project:

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## Support

For technical support or project-related questions:

- **Development Team:** Contact through Dataprev’s GitLab
- **Documentation:** Check the individual READMEs for each submodule
- **Issues:** Report problems via the GitLab issue tracker

---

**Developed by the Dataprev Superintendence of Artificial Intelligence and Innovation**

