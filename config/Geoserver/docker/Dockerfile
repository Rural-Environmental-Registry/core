FROM docker.osgeo.org/geoserver:2.28.0

# Instalar dependências necessárias
USER root
RUN apt-get update --allow-insecure-repositories --allow-unauthenticated && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Fix permissões para rodar como non-root (Kyverno injeta runAsUser:1000)
# O startup.sh da imagem base precisa escrever nestes paths:
RUN mkdir -p /opt/additional_libs /opt/geoserver_data && \
    chmod -R 777 /usr/local/tomcat/conf /opt/additional_libs /opt/geoserver_data && \
    # O PVC será montado aqui pelo K8s (fsGroup:2000 cuida das permissões do PVC)
    mkdir -p /opt/geoserver/data_dir && \
    chmod 777 /opt/geoserver/data_dir

# Copiar scripts
COPY populate_geoserver.sh /opt/populate_geoserver.sh
RUN chmod +x /opt/populate_geoserver.sh

# Apontar data dir para o path do PVC mount
ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir

USER 1000
