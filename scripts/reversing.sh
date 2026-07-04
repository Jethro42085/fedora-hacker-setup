#!/usr/bin/env bash
# Reverse engineering and binary analysis tools.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

reversing_install() {
    log_info "=== Reverse engineering ==="

    dnf_install \
        radare2 \
        gdb \
        ghidra \
        strace \
        ltrace
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    reversing_install
    print_failures
fi
