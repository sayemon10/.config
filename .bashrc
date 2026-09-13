# ~/.bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User-specific environment and PATH
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export PYTHONPATH=/usr/local/lib/python3.14/site-packages:$PYTHONPATH
# Uncomment if you don't like systemctl's auto-paging feature
# export SYSTEMD_PAGER=
set -o vi
# Source modular configs from ~/.bashrc.d (good practice for extensions)
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*.sh; do  # Only source .sh files to avoid issues
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Useful aliases (expanded for productivity)
alias up='sudo dnf upgrade --refresh -y'
alias clean='sudo dnf autoremove -y && sudo dnf clean all'  # Also cleans cache
alias c='clear'
alias cls='clear && ls'  # Clear and list
alias ll='ls -lh'  # Human-readable sizes
alias la='ls -lAh'  # All files, human-readable
alias grep='grep --color=auto'  # Colorized grep
alias diff='diff --color=auto'  # Colorized diff
alias ..='cd ..'
alias ...='cd ../..'
alias cc='sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"'
# alias vi='nvim'  # If you use Neovim; adjust as needed
unset HISTFILE
# Enable color support for ls (Fedora default, but explicit for clarity)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi
# NVM setup (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Bun setup
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Git prompt setup (sourced for __git_ps1)
if [ -f /usr/share/doc/git/contrib/completion/git-prompt.sh ]; then
    . /usr/share/doc/git/contrib/completion/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWSTASHSTATE=true
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=true
fi

# Custom PS1 with Git integration (uncommented and simplified with colors)
# Simple version: Host:dir (git-branch) $
# Adjust colors as needed (0;32=green, 0;34=blue, 0;33=yellow)
export PS1='\[\033[0;34m\]\h:\w\[\033[0m\]$(__git_ps1 " (\[\033[0;33m\]%s\[\033[0m\])")\$ '

# Powerline setup (fallback if available; otherwise use the Git PS1 above)
export POWERLINE_CONFIG_PATHS=~/.config/powerline
if command -v powerline-daemon >/dev/null 2>&1; then
    powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . /usr/share/powerline/bash/powerline.sh
    # If Powerline loads, override the simple PS1
    unset PS1
fi

# Additional shopt settings for better shell behavior
shopt -s checkwinsize  # Resize window after each command
shopt -s autocd        # cd into directories without 'cd'
shopt -s cdspell       # Correct minor cd misspellings
shopt -s dotglob       # Include dotfiles in * glob
shopt -s nocaseglob    # Case-insensitive globbing

# Safety: Set a safe umask (add this if not already in /etc/profile)
umask 0022

# Local overrides (source last, for machine-specific tweaks)
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
export DISABLE_TELEMETRY=1
#Zed
export ZED_ALLOW_EMULATED_GPU=1

export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
export PATH="$HOME/.local/bin:$PATH"

# Auto-attach to tmux when opening Konsole
if [[ -n "$KONSOLE_VERSION" ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
    SESSION_NAME="tmux"
    WINDOW_NAME="konsole"

    # Create session if it doesn't exist
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME"
    else
        # Session exists, ensure the 'konsole' window exists
        if ! tmux list-windows -t "$SESSION_NAME" -F '#W' | grep -q "^$WINDOW_NAME$"; then
            tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME"
        fi
    fi

    # Attach to session and select the specific window
    exec tmux attach-session -t "$SESSION_NAME:$WINDOW_NAME"
fi
