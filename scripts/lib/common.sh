#!/usr/bin/env bash
# Shared helpers for fedora-hacker-setup category scripts.
# Sourced, never executed directly.

set -uo pipefail

readonly C_RED=$'\033[0;31m'
readonly C_GREEN=$'\033[0;32m'
readonly C_YELLOW=$'\033[1;33m'
readonly C_BLUE=$'\033[0;34m'
readonly C_RESET=$'\033[0m'

log_info()  { printf '%s[*]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
log_ok()    { printf '%s[+]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
log_warn()  { printf '%s[!]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
log_error() { printf '%s[-]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

# Tracks packages/tools that failed so install.sh can print a summary at the end.
FAILED_ITEMS=()

# Set DRY_RUN=1 (see install.sh --dry-run) to log intended actions without
# making any changes to the system.
DRY_RUN="${DRY_RUN:-0}"

is_dry_run() { [[ "$DRY_RUN" == "1" ]]; }

require_fedora() {
    if [[ ! -f /etc/os-release ]] || ! grep -qi '^ID=fedora' /etc/os-release; then
        log_warn "This does not look like Fedora. Continuing anyway, but dnf-based steps may fail."
    fi
}

require_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Run this script as a normal user, not root. It will call sudo where needed."
        exit 1
    fi
}

# dnf_install pkg1 pkg2 ...  -- installs what it can, records failures, never aborts the run.
dnf_install() {
    local pkg
    for pkg in "$@"; do
        if rpm -q "$pkg" &>/dev/null; then
            log_ok "$pkg already installed"
            continue
        fi
        if is_dry_run; then
            log_info "[dry-run] would install $pkg"
            continue
        fi
        log_info "Installing $pkg"
        if sudo dnf install -y "$pkg" &>/dev/null; then
            log_ok "$pkg installed"
        else
            log_error "Failed to install $pkg (dnf)"
            FAILED_ITEMS+=("dnf:$pkg")
        fi
    done
}

copr_enable() {
    local repo=$1
    if is_dry_run; then
        log_info "[dry-run] would enable COPR repo $repo"
        return 0
    fi
    log_info "Enabling COPR repo $repo"
    if ! sudo dnf copr enable -y "$repo" &>/dev/null; then
        log_error "Failed to enable COPR repo $repo"
        FAILED_ITEMS+=("copr:$repo")
        return 1
    fi
}

pipx_install() {
    local pkg
    for pkg in "$@"; do
        if is_dry_run; then
            log_info "[dry-run] would pipx install $pkg"
            continue
        fi
        log_info "pipx install $pkg"
        if pipx install "$pkg" &>/dev/null; then
            log_ok "$pkg installed via pipx"
        else
            log_error "Failed to install $pkg (pipx)"
            FAILED_ITEMS+=("pipx:$pkg")
        fi
    done
}

go_install() {
    local pkg
    for pkg in "$@"; do
        if is_dry_run; then
            log_info "[dry-run] would go install $pkg"
            continue
        fi
        log_info "go install $pkg"
        if go install "$pkg"@latest &>/dev/null; then
            log_ok "$pkg installed via go"
        else
            log_error "Failed to install $pkg (go)"
            FAILED_ITEMS+=("go:$pkg")
        fi
    done
}

print_failures() {
    if [[ ${#FAILED_ITEMS[@]} -eq 0 ]]; then
        return
    fi
    log_warn "The following items failed to install and may need manual attention:"
    local item
    for item in "${FAILED_ITEMS[@]}"; do
        printf '    - %s\n' "$item"
    done
}
