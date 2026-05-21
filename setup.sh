#!/bin/bash
# =============================================================================
# RER - Rural Environmental Registry
# Developer Setup Script
# =============================================================================
# Clones all RER repositories and prepares the local development environment.
# Run this once after cloning the core repository.
#
# Usage:
#   ./setup.sh              # Clone repos + setup environment
#   ./setup.sh --pull       # Update existing repos (git pull)
#   ./setup.sh --status     # Show status of all repos
#
# After setup, use:
#   ./start.sh              # Build from source and run with Docker Compose
#   ./install.sh            # Run with pre-built images (no build required)
# =============================================================================

set -e

# --- Configuration -----------------------------------------------------------

GITHUB_ORG="https://github.com/Rural-Environmental-Registry"
BRANCH="${RER_BRANCH:-develop}"

# Mapping: GitHub repo name -> local directory name (expected by start.sh)
declare -A REPOS=(
    ["frontend"]="frontend"
    ["backend"]="backend"
    ["authentication"]="authentication"
    ["calc_engine"]="calc_engine"
    ["gateway"]="gateway"
    ["map_component"]="map_component"
)

# --- Colors ------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Prerequisites -----------------------------------------------------------

check_prerequisites() {
    info "Checking prerequisites..."
    local missing=0

    if ! command -v git &>/dev/null; then
        error "git not found. Install: https://git-scm.com/"
        missing=1
    fi

    if ! command -v docker &>/dev/null; then
        error "docker not found. Install: https://docs.docker.com/get-docker/"
        missing=1
    fi

    if ! docker compose version &>/dev/null; then
        error "docker compose v2 not found. Update Docker or install compose plugin."
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        error "Missing prerequisites. Install them and re-run."
        exit 1
    fi

    ok "All prerequisites met (git, docker, docker compose)"
}

# --- Clone / Pull ------------------------------------------------------------

clone_repos() {
    info "Cloning repositories (branch: $BRANCH)..."

    for repo in "${!REPOS[@]}"; do
        local dir="${REPOS[$repo]}"
        if [ -d "$dir" ]; then
            warn "$dir already exists, skipping (use --pull to update)"
        else
            info "Cloning $repo -> $dir"
            git clone --branch "$BRANCH" "$GITHUB_ORG/$repo.git" "$dir" 2>/dev/null || \
            git clone "$GITHUB_ORG/$repo.git" "$dir"
            ok "$dir cloned"
        fi
    done
}

pull_repos() {
    info "Updating repositories..."

    for repo in "${!REPOS[@]}"; do
        local dir="${REPOS[$repo]}"
        if [ -d "$dir/.git" ]; then
            info "Pulling $dir..."
            (cd "$dir" && git pull --ff-only 2>/dev/null && ok "$dir updated") || \
                warn "$dir: pull failed (check for local changes)"
        else
            warn "$dir not found, cloning..."
            git clone --branch "$BRANCH" "$GITHUB_ORG/$repo.git" "$dir" 2>/dev/null || \
            git clone "$GITHUB_ORG/$repo.git" "$dir"
            ok "$dir cloned"
        fi
    done
}

status_repos() {
    info "Repository status:"
    echo ""
    printf "%-22s %-12s %-10s %s\n" "DIRECTORY" "BRANCH" "STATUS" "BEHIND"
    printf "%-22s %-12s %-10s %s\n" "---------" "------" "------" "------"

    for repo in "${!REPOS[@]}"; do
        local dir="${REPOS[$repo]}"
        if [ -d "$dir/.git" ]; then
            local branch=$(cd "$dir" && git rev-parse --abbrev-ref HEAD)
            local status=$(cd "$dir" && git status --porcelain | wc -l)
            local behind=$(cd "$dir" && git fetch origin 2>/dev/null && git rev-list HEAD..origin/$branch --count 2>/dev/null || echo "?")
            local status_text="clean"
            [ "$status" -gt 0 ] && status_text="${status} changes"
            printf "%-22s %-12s %-10s %s\n" "$dir" "$branch" "$status_text" "$behind behind"
        else
            printf "%-22s %-12s %-10s %s\n" "$dir" "-" "NOT CLONED" "-"
        fi
    done
    echo ""
}

# --- Environment Setup -------------------------------------------------------

setup_env() {
    if [ ! -f .env ]; then
        info "Creating .env from .env.example..."
        cp .env.example .env
        ok ".env created. Edit it if needed (credentials, hostname, etc.)"
    else
        ok ".env already exists"
    fi
}

# --- Main --------------------------------------------------------------------

cd "$(dirname "$0")"

echo ""
echo "============================================="
echo "  RER - Developer Environment Setup"
echo "============================================="
echo ""

case "${1:-}" in
    --pull)
        pull_repos
        ;;
    --status)
        status_repos
        exit 0
        ;;
    --help|-h)
        echo "Usage: ./setup.sh [--pull|--status|--help]"
        echo ""
        echo "  (no args)   Clone repos + setup environment"
        echo "  --pull      Update existing repos (git pull)"
        echo "  --status    Show status of all repos"
        echo ""
        exit 0
        ;;
    *)
        check_prerequisites
        clone_repos
        setup_env
        ;;
esac

echo ""
echo "============================================="
ok "Setup complete!"
echo ""
echo "  Next steps:"
echo "    1. Review .env and adjust if needed"
echo "    2. Run ./start.sh to build and start all services"
echo "       OR ./install.sh to use pre-built images"
echo ""
echo "  Useful commands:"
echo "    ./setup.sh --pull     Update all repos"
echo "    ./setup.sh --status   Check repo status"
echo "    docker compose ps     Show running containers"
echo "    docker compose logs   View logs"
echo "============================================="
