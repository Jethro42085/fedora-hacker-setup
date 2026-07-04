#!/usr/bin/env bash
# Password cracking and credential auditing tools.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

passwords_install() {
    log_info "=== Password cracking ==="

    dnf_install \
        john \
        hashcat \
        hydra \
        seclists
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    passwords_install
    print_failures
fi
