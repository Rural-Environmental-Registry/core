#!/bin/bash
# This script is used to start the Docker Compose environment for the Car DPG project.
# It includes the core frontend and backend services.
# Usage: ./start.sh --<stage>

set -e

echo "Loading environment variables and preparing directories..."

#Main
export MAIN_PATH=.
export MAIN_CONFIG_PATH=./config/Main
export MAIN_PROXY_SERVICE_NAME=main-proxy
export MAIN_PROXY_CONTAINER_NAME=main-proxy
export DOLLAR='$'
# # Uncomment the following lines if you want to disable Docker BuildKit and CLI build
# export DOCKER_BUILDKIT=0
# export COMPOSE_DOCKER_CLI_BUILD=0

# Copy .env.example to .envs
cp $MAIN_CONFIG_PATH/environment/.env.example $MAIN_PATH/.env
# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found. Please create one based on .env.example."
    exit 1
fi

# Prepare Core_Frontend directory
envsubst < $CORE_FRONTEND_CONFIG_PATH/environment/.env | envsubst | envsubst | envsubst > $CORE_FRONTEND_PATH/.env
envsubst < $CORE_FRONTEND_CONFIG_PATH/docker/Dockerfile | envsubst | envsubst > $CORE_FRONTEND_PATH/Dockerfile
envsubst  < $CORE_FRONTEND_CONFIG_PATH/docker/docker-compose.yaml | envsubst | envsubst > $CORE_FRONTEND_PATH/docker-compose.yaml
envsubst  < $CORE_FRONTEND_CONFIG_PATH/nginx/nginx.conf.template > $CORE_FRONTEND_PATH/nginx.conf
cp -r $CORE_FRONTEND_CONFIG_PATH/script/map-dependency.cjs $CORE_FRONTEND_PATH/scripts/map-dependency.cjs
cp -r ./Map-Component $CORE_FRONTEND_PATH

# Prepare Core_Backend directory
envsubst < $CORE_BACKEND_CONFIG_PATH/environment/.env.example | envsubst | envsubst | envsubst > $CORE_BACKEND_PATH/.env
cp -r $CORE_BACKEND_CONFIG_PATH/custom/images $CORE_BACKEND_PATH/src/main/resources
cp -r $CORE_BACKEND_CONFIG_PATH/custom/reports $CORE_BACKEND_PATH/src/main/resources
envsubst  < $CORE_BACKEND_CONFIG_PATH/docker/Dockerfile | envsubst | envsubst > $CORE_BACKEND_PATH/Dockerfile
envsubst  < $CORE_BACKEND_CONFIG_PATH/docker/docker-compose.yml | envsubst | envsubst > $CORE_BACKEND_PATH/docker-compose.yml
envsubst  < $CORE_BACKEND_CONFIG_PATH/application/application.properties | envsubst | envsubst > $CORE_BACKEND_PATH/src/main/resources/application.properties
envsubst  < $CORE_BACKEND_CONFIG_PATH/gradle/build.gradle > $CORE_BACKEND_PATH/build.gradle
envsubst  < $CORE_BACKEND_CONFIG_PATH/gradle/settings.gradle > $CORE_BACKEND_PATH/settings.gradle

# Prepare Authentication directory
cp ./.env $AUTHENTICATION_PATH/.env
envsubst < $AUTHENTICATION_CONFIG_PATH/frontend/environment/.env | envsubst | envsubst | envsubst > $AUTHENTICATION_PATH/frontend/.env
envsubst < $AUTHENTICATION_CONFIG_PATH/frontend/environment/.env | envsubst | envsubst | envsubst > $AUTHENTICATION_PATH/frontend/.env.production
envsubst < $AUTHENTICATION_CONFIG_PATH/frontend/docker/Dockerfile > $AUTHENTICATION_PATH/frontend/Dockerfile
envsubst  < $AUTHENTICATION_CONFIG_PATH/frontend/nginx/nginx.conf.template > $AUTHENTICATION_PATH/frontend/nginx.conf
envsubst < $AUTHENTICATION_CONFIG_PATH/backend/docker/Dockerfile > $AUTHENTICATION_PATH/cardpg/Dockerfile
envsubst < $AUTHENTICATION_CONFIG_PATH/backend/application/application.yml | envsubst | envsubst | envsubst > $AUTHENTICATION_PATH/cardpg/src/main/resources/application.yml
envsubst  < $AUTHENTICATION_CONFIG_PATH/docker/docker-compose.yml | envsubst | envsubst | envsubst > $AUTHENTICATION_PATH/docker-compose.yml
envsubst  < $AUTHENTICATION_CONFIG_PATH/docker/Dockerfile > $AUTHENTICATION_PATH/Dockerfile

#Prepare Calculation Engine directory
envsubst  < $CALCULATION_ENGINE_CONFIG_PATH/docker/docker-compose.yml | envsubst | envsubst | envsubst > $CALCULATION_ENGINE_PATH/docker-compose.yml
envsubst < $CALCULATION_ENGINE_CONFIG_PATH/docker/Dockerfile > $CALCULATION_ENGINE_PATH/Dockerfile
envsubst  < $CALCULATION_ENGINE_CONFIG_PATH/application/application.properties | envsubst | envsubst > $CALCULATION_ENGINE_PATH/src/main/resources/application.properties
envsubst  < $CALCULATION_ENGINE_CONFIG_PATH/maven/pom.xml > $CALCULATION_ENGINE_PATH/pom.xml

# Prepare Main directory
if [ -z "$BASE_URL" ]; then
    envsubst < $MAIN_CONFIG_PATH/nginx/nginx.conf.template | sed "s#^.*X-Forwarded-Prefix.*\$##g" > $MAIN_PATH/nginx.conf
else
    envsubst < $MAIN_CONFIG_PATH/nginx/nginx.conf.template > $MAIN_PATH/nginx.conf
fi
envsubst  < $MAIN_CONFIG_PATH/docker/docker-compose.yaml | envsubst | envsubst | envsubst > $MAIN_PATH/docker-compose.yaml
cp $MAIN_CONFIG_PATH/docker/Dockerfile.proxy $MAIN_PATH/Dockerfile.proxy

#Prepare Gateway directory
envsubst < $GATEWAY_CONFIG_PATH/docker/Dockerfile > $GATEWAY_PATH/Dockerfile
envsubst < $GATEWAY_CONFIG_PATH/docker/docker-compose.yml | envsubst | envsubst > $GATEWAY_PATH/docker-compose.yml
envsubst  < $GATEWAY_CONFIG_PATH/maven/pom.xml > $GATEWAY_PATH/pom.xml
mkdir -p $GATEWAY_PATH/src/main/resources
envsubst < $GATEWAY_CONFIG_PATH/application/application.yml > $GATEWAY_PATH/src/main/resources/application.yml

#Prepare Geoserver directory
mkdir -p $GEOSERVER_PATH
envsubst < $GEOSERVER_CONFIG_PATH/docker/docker-compose.yml | envsubst | envsubst > $GEOSERVER_PATH/docker-compose.yml

# Proxy configuration
if [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ]; then
    echo "PROXY_HOST or PROXY_PORT is not set, skipping proxy configuration."
    echo "<settings></settings>" > $CALCULATION_ENGINE_PATH/settings.xml
    echo "<settings></settings>" > $AUTHENTICATION_PATH/cardpg/settings.xml
    echo "<settings></settings>" > $GATEWAY_PATH/settings.xml
else
    envsubst < $CALCULATION_ENGINE_CONFIG_PATH/application/settings.xml > $CALCULATION_ENGINE_PATH/settings.xml
    envsubst < $AUTHENTICATION_CONFIG_PATH/backend/application/settings.xml > $AUTHENTICATION_PATH/cardpg/settings.xml
    envsubst < $GATEWAY_CONFIG_PATH/application/settings.xml > $GATEWAY_PATH/settings.xml
fi

echo "Environment variables loaded and directories prepared successfully."

echo "Starting Docker Compose environment for RER DPG project..."
#Build and run the Docker Compose environment
# # Uncomment the following lines to build without cache and show progress
docker compose build --progress=plain --no-cache
docker compose up --force-recreate -d --remove-orphans
echo "Docker Compose environment started successfully."