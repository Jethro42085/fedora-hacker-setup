#!/usr/bin/env bash
# Shell/terminal quality-of-life setup: zsh + oh-my-zsh + tmux config.
# Optional and separate from the security tooling categories.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/common.sh
[[ "$(type -t log_info)" == "function" ]] || source "$SCRIPT_DIR/lib/common.sh"

shell_install() {
    log_info "=== Shell environment ==="

    dnf_install zsh tmux util-linux-user

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing oh-my-zsh"
        if RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            &>/dev/null; then
            log_ok "oh-my-zsh installed"
        else
            log_error "Failed to install oh-my-zsh"
            FAILED_ITEMS+=("oh-my-zsh")
        fi
    else
        log_ok "oh-my-zsh already installed"
    fi

    if [[ -f "$REPO_ROOT/config/zshrc.extra" ]]; then
        local marker="# --- fedora-hacker-setup ---"
        local zshrc="$HOME/.zshrc"
        if ! grep -qF "$marker" "$zshrc" 2>/dev/null; then
            # ZSH_THEME/plugins only take effect if set before oh-my-zsh.sh is
            # sourced, so insert above that line rather than just appending.
            if [[ -f "$zshrc" ]] && grep -q 'oh-my-zsh\.sh"' "$zshrc"; then
                local tmp
                tmp="$(mktemp)"
                awk -v marker="$marker" -v extra="$REPO_ROOT/config/zshrc.extra" '
                    !done && /oh-my-zsh\.sh"/ {
                        print marker
                        while ((getline line < extra) > 0) print line
                        print ""
                        done = 1
                    }
                    { print }
                ' "$zshrc" > "$tmp"
                mv "$tmp" "$zshrc"
            else
                {
                    printf '\n%s\n' "$marker"
                    cat "$REPO_ROOT/config/zshrc.extra"
                } >> "$zshrc"
            fi
            log_ok "Added fedora-hacker-setup block to ~/.zshrc"
        else
            log_ok "$HOME/.zshrc already includes fedora-hacker-setup block"
        fi
    fi

    if [[ -f "$REPO_ROOT/config/tmux.conf" ]]; then
        cp "$REPO_ROOT/config/tmux.conf" "$HOME/.tmux.conf"
        log_ok "Installed ~/.tmux.conf"
    fi

    if command -v zsh &>/dev/null && [[ "$SHELL" != *zsh ]]; then
        log_info "Setting zsh as your default shell (takes effect on next login)"
        sudo chsh -s "$(command -v zsh)" "$USER" || log_warn "Could not change default shell"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    require_fedora
    shell_install
    print_failures
fi
