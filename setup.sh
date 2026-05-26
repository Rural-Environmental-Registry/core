#!/bin/bash
# =============================================================================
# RER - Rural Environmental Registry
# Development environment setup (first run / clean machine)
# =============================================================================
# Based on setup.sh, with extra validations:
#   - Do not run as root/sudo
#   - envsubst (gettext-base) required by start.sh
#   - User in docker group and Docker accessible without sudo
#   - If usermod/new session is needed, the script re-runs once (sg docker)
#
# Prerequisite: Docker and Docker Compose already installed.
#
# Usage:
#   ./setup.sh              # Clone repositories + environment
#   ./setup.sh --pull       # Update existing repositories
#   ./setup.sh --status     # Repository status
#
# Then:
#   ./start.sh                # Build and start via Docker Compose (no sudo)
# =============================================================================

set -e

# --- Configuration -----------------------------------------------------------

GITHUB_ORG="https://github.com/Rural-Environmental-Registry"
BRANCH="${RER_BRANCH:-develop}"

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

# --- Environment checks ------------------------------------------------------

check_not_root() {
    if [ "$(id -u)" -eq 0 ]; then
        error "Do not run this script as root or with sudo."
        error "Use: ./setup.sh"
        exit 1
    fi

    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "${USER}" ]; then
        warn "SUDO_USER detected. Run without sudo so clones belong to your user."
    fi
}

user_in_docker_group() {
    id -nG 2>/dev/null | grep -qw docker
}

# Re-run this script with the docker group active in the session (avoids a manual second run).
reexec_with_docker_group() {
    local script_dir script_path
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    script_path="$script_dir/$(basename "$0")"

    info "Restarting setup with docker group active (no need to run the script again)..."
    export SETUP_DOCKER_GROUP_ACTIVE=1
    exec sg docker -c "cd $(printf '%q' "$script_dir") && export SETUP_DOCKER_GROUP_ACTIVE=1 && $(printf '%q' "$script_path") $(printf '%q' "$@")"
}

check_docker_access() {
    info "Checking Docker access without sudo..."

    if docker info &>/dev/null; then
        ok "Docker accessible without sudo"
        return 0
    fi

    if [ -n "${SETUP_DOCKER_GROUP_ACTIVE:-}" ]; then
        error "Docker inaccessible even after activating the docker group in this run."
        echo "  Check the service: sudo systemctl status docker"
        echo "  Start if needed: sudo systemctl start docker"
        exit 1
    fi

    if ! user_in_docker_group; then
        warn "User '$USER' is not in the docker group"
        info "Adding to group (sudo password requested once)..."
        if ! sudo usermod -aG docker "$USER"; then
            error "Failed to run: sudo usermod -aG docker $USER"
            exit 1
        fi
        ok "User added to docker group"
    else
        info "User is already in the docker group; activating group in this run..."
    fi

    reexec_with_docker_group "$@"
}

check_prerequisites() {
    info "Checking prerequisites..."
    local missing=0

    if ! command -v git &>/dev/null; then
        error "git not found. Install: https://git-scm.com/"
        missing=1
    fi

    if ! command -v docker &>/dev/null; then
        error "docker not found. Install Docker before continuing."
        missing=1
    fi

    if ! command -v envsubst &>/dev/null; then
        error "envsubst not found (gettext-base package)."
        echo "  Ubuntu/Debian: sudo apt install gettext-base"
        missing=1
    fi

    if [ "$missing" -eq 1 ]; then
        error "Fix the prerequisites above and run again."
        exit 1
    fi

    ok "git, docker, and envsubst found"

    check_docker_access "$@"

    if ! docker compose version &>/dev/null; then
        error "docker compose v2 not found. Install the Docker compose plugin."
        exit 1
    fi

    ok "docker compose available"
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
            info "Updating $dir..."
            (cd "$dir" && git pull --ff-only 2>/dev/null && ok "$dir updated") || \
                warn "$dir: pull failed (check local changes)"
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
    printf "%-22s %-12s %-10s %s\n" "----------" "------" "------" "-----"

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

# --- Environment -------------------------------------------------------------

setup_env() {
    if [ ! -f .env ]; then
        if [ ! -f .env.example ]; then
            error ".env.example not found in project root."
            exit 1
        fi
        info "Creating .env from .env.example..."
        cp .env.example .env
        ok ".env created. Adjust credentials and hostname if needed."
    else
        ok ".env already exists"
    fi
}

# --- Main --------------------------------------------------------------------

cd "$(dirname "$0")"

echo ""
echo "============================================="
echo "  RER - Environment setup (setup)"
echo "============================================="
echo ""

check_not_root

case "${1:-}" in
    --pull)
        check_prerequisites "$@"
        pull_repos
        ;;
    --status)
        status_repos
        exit 0
        ;;
    --help|-h)
        echo "Usage: ./setup.sh [--pull|--status|--help]"
        echo ""
        echo "  (no args)   Clone repositories + prepare environment"
        echo "  --pull      Update existing repositories"
        echo "  --status    Show repository status"
        echo ""
        echo "Requirements: Docker installed; run without sudo."
        echo "If docker group is missing, the script asks for sudo once and re-runs itself."
        echo "After setup: ./start.sh (also without sudo)"
        exit 0
        ;;
    *)
        check_prerequisites "$@"
        clone_repos
        setup_env
        ;;
esac

echo ""
echo "============================================="
ok "Setup complete!"
echo ""
echo "  Next steps:"
echo "    1. Review .env if needed"
echo "    2. Run ./start.sh (no sudo) to build and start services"
echo ""
echo "  Useful commands:"
echo "    ./setup.sh --pull     Update all repositories"
echo "    ./setup.sh --status   Repository status"
echo "    docker compose ps       Running containers"
echo "============================================="
