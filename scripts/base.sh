#!/usr/bin/env bash
# Base system prep: updates, build tooling, and the package managers
# (pipx, go, cargo) that later category scripts rely on.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

base_install() {
    log_info "=== Base system ==="

    log_info "Refreshing package metadata and upgrading system"
    sudo dnf upgrade -y --refresh || log_warn "System upgrade reported errors, continuing"

    dnf_install \
        git curl wget vim tmux zsh htop tree jq unzip \
        gcc gcc-c++ make cmake automake autoconf \
        python3 python3-pip python3-devel pipx \
        golang rust cargo \
        openssl-devel

    pipx ensurepath &>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    base_install
    print_failures
fi
