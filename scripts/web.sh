#!/usr/bin/env bash
# Web application testing tools.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

web_install() {
    log_info "=== Web application testing ==="

    dnf_install \
        nikto sqlmap \
        gobuster ffuf \
        zaproxy

    if command -v pipx &>/dev/null; then
        pipx_install wfuzz
    else
        log_warn "pipx not found, skipping wfuzz (run scripts/base.sh first)"
    fi

    log_info "Burp Suite Community is not packaged for dnf; download it manually from:"
    log_info "  https://portswigger.net/burp/communitydownload"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    web_install
    print_failures
fi
