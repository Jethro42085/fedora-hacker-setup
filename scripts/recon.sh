#!/usr/bin/env bash
# Recon / OSINT / network scanning tools.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

recon_install() {
    log_info "=== Recon & scanning ==="

    dnf_install \
        nmap nmap-ncat \
        whois bind-utils traceroute \
        wireshark tcpdump \
        masscan

    if command -v pipx &>/dev/null; then
        pipx_install theharvester
    else
        log_warn "pipx not found, skipping theHarvester (run scripts/base.sh first)"
    fi

    if command -v go &>/dev/null; then
        go_install \
            github.com/projectdiscovery/subfinder/v2/cmd/subfinder \
            github.com/projectdiscovery/httpx/cmd/httpx \
            github.com/projectdiscovery/naabu/v2/cmd/naabu \
            github.com/owasp-amass/amass/v4/...
    else
        log_warn "go not found, skipping subfinder/httpx/naabu/amass (run scripts/base.sh first)"
    fi

    if is_dry_run; then
        log_info "[dry-run] would add $USER to the 'wireshark' group for non-root packet capture"
    else
        log_info "Adding current user to the 'wireshark' group for non-root packet capture"
        sudo usermod -aG wireshark "$USER" || log_warn "Could not add $USER to wireshark group"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    recon_install
    print_failures
fi
