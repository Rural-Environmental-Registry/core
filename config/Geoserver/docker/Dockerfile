FROM docker.osgeo.org/geoserver:2.28.0

# Instalar dependências necessárias
USER root
RUN apt-get update --allow-insecure-repositories --allow-unauthenticated && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Fix permissions for non-root execution (Kyverno injects runAsUser:1000)
# The base image startup.sh needs write access to these paths:
RUN mkdir -p /opt/additional_libs /opt/geoserver_data /opt/geoserver/data_dir && \
    chown -R 1000:1000 /usr/local/tomcat/conf /opt/additional_libs /opt/geoserver_data /opt/geoserver/data_dir

# Copiar scripts
COPY populate_geoserver.sh /opt/populate_geoserver.sh
RUN chmod +x /opt/populate_geoserver.sh

# Apontar data dir para o path do PVC mount
ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir

USER 1000
