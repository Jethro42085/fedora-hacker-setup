#!/usr/bin/env bash
# Software-defined radio tools (RTL-SDR).
#
# Receive-only hardware, but listening on some frequency ranges (e.g.
# cellular, encrypted trunked radio) is restricted in many jurisdictions
# regardless. Know your local regulations before you tune in.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

sdr_install() {
    log_info "=== Software-defined radio ==="

    dnf_install \
        rtl-sdr \
        gqrx
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    sdr_install
    print_failures
fi
