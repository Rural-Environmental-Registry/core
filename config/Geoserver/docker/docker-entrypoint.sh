#!/bin/bash
# Ajusta permissões do data dir (volume pode ter sido criado como root) e inicia o GeoServer como UID 1000.
set -e

GEOSERVER_UID="${GEOSERVER_UID:-1000}"
GEOSERVER_GID="${GEOSERVER_GID:-1000}"
DATA_DIR="${GEOSERVER_DATA_DIR:-/var/geoserver/datadir}"

mkdir -p "$DATA_DIR"
chown -R "${GEOSERVER_UID}:${GEOSERVER_GID}" "$DATA_DIR"

exec runuser -u ubuntu -- /opt/startup.sh "$@"
