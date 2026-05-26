#!/bin/bash
# Ajusta permissões do data dir (volume pode ter sido criado como root).
# O startup.sh oficial aplica RUN_UNPRIVILEGED e sobe o Tomcat com setpriv.
set -e

GEOSERVER_UID="${RUN_WITH_USER_UID:-${GEOSERVER_UID:-999}}"
GEOSERVER_GID="${RUN_WITH_USER_GID:-${GEOSERVER_GID:-999}}"
DATA_DIR="${GEOSERVER_DATA_DIR:-/var/geoserver/datadir}"

mkdir -p "$DATA_DIR"
if [ "$(stat -c '%u:%g' "$DATA_DIR")" != "${GEOSERVER_UID}:${GEOSERVER_GID}" ]; then
    chown -R "${GEOSERVER_UID}:${GEOSERVER_GID}" "$DATA_DIR"
fi

exec /opt/startup.sh "$@"
