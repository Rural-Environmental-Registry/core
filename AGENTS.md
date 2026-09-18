# Core

## Stack
- Docker Compose (orchestration)
- nginx (reverse proxy)
- GeoServer (map services)
- Shell scripts (install.sh, setup.sh, start.sh)

## Comandos
```bash
# Install
./install.sh
# Start
./start.sh
# Setup environment
./setup.sh
```

## Estrutura
```
docker-compose.yml  # service orchestration
config/             # service configurations
install.sh          # installation script
setup.sh            # environment setup
start.sh            # startup script
docs/               # documentation
```

## Convenções
- Shell: POSIX-compatible scripts
- Commits: conventional commits (feat/fix/chore)
- Branches: develop → release/dev → release/qa → release/prd → main
