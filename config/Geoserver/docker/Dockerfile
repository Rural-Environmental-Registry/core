FROM docker.osgeo.org/geoserver:2.28.0

# Instalar dependências necessárias
USER root
RUN apt-get update --allow-insecure-repositories --allow-unauthenticated && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de dados com permissões corretas
RUN mkdir -p /var/geoserver/datadir && \
    chown -R root:root /var/geoserver/datadir && \
    chmod -R 777 /var/geoserver/datadir

# Copiar scripts
COPY populate_geoserver.sh /opt/populate_geoserver.sh
RUN chmod +x /opt/populate_geoserver.sh

# Definir variável de ambiente para o data directory
ENV GEOSERVER_DATA_DIR=/var/geoserver/datadir