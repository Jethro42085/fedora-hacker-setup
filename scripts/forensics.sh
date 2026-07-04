#!/usr/bin/env bash
# Forensics and file/memory analysis tools.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

forensics_install() {
    log_info "=== Forensics ==="

    dnf_install \
        binwalk \
        foremost \
        sleuthkit \
        exiftool \
        testdisk

    if command -v pipx &>/dev/null; then
        pipx_install volatility3
    else
        log_warn "pipx not found, skipping volatility3 (run scripts/base.sh first)"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    forensics_install
    print_failures
fi
