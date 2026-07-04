#!/usr/bin/env bash
# Wireless auditing tools.
#
# Only use these against networks and devices you own or are explicitly
# authorized to test. Deauth/jamming and unauthorized network attacks are
# illegal in most jurisdictions.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

wireless_install() {
    log_info "=== Wireless auditing ==="

    dnf_install \
        aircrack-ng \
        reaver \
        macchanger
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    wireless_install
    print_failures
fi
