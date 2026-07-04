#!/usr/bin/env bash
# fedora-hacker-setup: entrypoint for configuring a Fedora box for
# authorized security research, CTFs, and pentest labs.
#
# Usage:
#   ./install.sh                 interactive menu
#   ./install.sh --all           install every category
#   ./install.sh --list          list available categories
#   ./install.sh recon web       install only the named categories
#
# Always run as your normal user; sudo is invoked only where needed.

set -uo pipefail

# NOTE: named distinctly (and made readonly) because every scripts/*.sh sets
# its own global SCRIPT_DIR when sourced; reusing that name here would get
# clobbered after the first category script loads, breaking later `source`
# calls below.
INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_ROOT

# shellcheck source=scripts/lib/common.sh
source "$INSTALL_ROOT/scripts/lib/common.sh"
# shellcheck source=scripts/base.sh
source "$INSTALL_ROOT/scripts/base.sh"
# shellcheck source=scripts/recon.sh
source "$INSTALL_ROOT/scripts/recon.sh"
# shellcheck source=scripts/web.sh
source "$INSTALL_ROOT/scripts/web.sh"
# shellcheck source=scripts/exploitation.sh
source "$INSTALL_ROOT/scripts/exploitation.sh"
# shellcheck source=scripts/wireless.sh
source "$INSTALL_ROOT/scripts/wireless.sh"
# shellcheck source=scripts/forensics.sh
source "$INSTALL_ROOT/scripts/forensics.sh"
# shellcheck source=scripts/reversing.sh
source "$INSTALL_ROOT/scripts/reversing.sh"
# shellcheck source=scripts/passwords.sh
source "$INSTALL_ROOT/scripts/passwords.sh"
# shellcheck source=scripts/shell.sh
source "$INSTALL_ROOT/scripts/shell.sh"

# Category name -> install function. "base" always runs first when selected.
declare -A CATEGORIES=(
    [base]=base_install
    [recon]=recon_install
    [web]=web_install
    [exploitation]=exploitation_install
    [wireless]=wireless_install
    [forensics]=forensics_install
    [reversing]=reversing_install
    [passwords]=passwords_install
    [shell]=shell_install
)

# Order matters: base first, shell last, everything else in between.
readonly CATEGORY_ORDER=(base recon web exploitation wireless forensics reversing passwords shell)

usage() {
    cat <<EOF
Usage: $(basename "$0") [--all | --list | category [category ...]]

Categories:
EOF
    local cat
    for cat in "${CATEGORY_ORDER[@]}"; do
        printf '  %s\n' "$cat"
    done
}

run_categories() {
    local cat
    for cat in "$@"; do
        if [[ -z "${CATEGORIES[$cat]+x}" ]]; then
            log_error "Unknown category: $cat"
            continue
        fi
        "${CATEGORIES[$cat]}"
    done
}

interactive_menu() {
    echo "fedora-hacker-setup: select categories to install (space-separated numbers, or 'all')"
    local i=1
    local -A index_to_cat
    for cat in "${CATEGORY_ORDER[@]}"; do
        printf '  %d) %s\n' "$i" "$cat"
        index_to_cat[$i]=$cat
        ((i++))
    done

    read -r -p "> " selection
    if [[ "$selection" == "all" ]]; then
        run_categories "${CATEGORY_ORDER[@]}"
        return
    fi

    local chosen=()
    local num
    for num in $selection; do
        if [[ -n "${index_to_cat[$num]+x}" ]]; then
            chosen+=("${index_to_cat[$num]}")
        else
            log_warn "Ignoring invalid selection: $num"
        fi
    done
    run_categories "${chosen[@]}"
}

main() {
    require_not_root
    require_fedora

    if [[ $# -eq 0 ]]; then
        interactive_menu
    elif [[ "$1" == "--all" ]]; then
        run_categories "${CATEGORY_ORDER[@]}"
    elif [[ "$1" == "--list" ]]; then
        usage
        exit 0
    elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
        exit 0
    else
        run_categories "$@"
    fi

    print_failures
    log_ok "Done."
}

main "$@"
