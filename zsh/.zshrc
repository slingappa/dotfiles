
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/local/bin


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
plugins=(git z zsh-autosuggestions colored-man-pages command-not-found extract zsh-history-substring-search pass taskwarrior web-search ohmyzsh-full-autoupdate)

autoload -U colors && colors

source $ZSH/oh-my-zsh.sh

# Optional local-only secrets file (not committed to git).
[[ -f "$HOME/.config/shell/private.zsh" ]] && source "$HOME/.config/shell/private.zsh"

# Auto-save Codex/QGenie interactive sessions to ~/workspace/chatlogs/codex.
# Set CODEX_CHATLOG_DISABLE=1 to bypass for one shell/session.
function qgenie() {
  local qgenie_real="/usr2/slingapp/.local/bin/qgenie"
  local subcmd="$1"

  if [[ ! -x "$qgenie_real" ]]; then
    command qgenie "$@"
    return $?
  fi

  if [[ -o interactive ]] \
    && [[ -z "${CODEX_CHATLOG_DISABLE:-}" ]] \
    && [[ -z "${INSIDE_CODEX_CHATLOG_SCRIPT:-}" ]] \
    && [[ "$subcmd" == "agent" || "$subcmd" == "chat" || "$subcmd" == "resume" || "$subcmd" == "fork" ]]; then
    mkdir -p "$HOME/workspace/chatlogs/codex"
    export INSIDE_CODEX_CHATLOG_SCRIPT=1
    local codex_chatlog="$HOME/workspace/chatlogs/codex/session-$(date +%F_%H-%M-%S).log"
    script -qf "$codex_chatlog" -c "$qgenie_real ${(q)@}"
    return $?
  fi

  "$qgenie_real" "$@"
}

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"



function clear-scrollback-buffer {
  # Behavior of clear: 
  # 1. clear scrollback if E3 cap is supported (terminal, platform specific)
  # 2. then clear visible screen
  # For some terminal 'e[3J' need to be sent explicitly to clear scrollback
  clear && printf '\e[3J'
  # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
  # https://github.com/sorin-ionescu/prezto/issues/1026
  # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
  # -R: redisplay the prompt to avoid old prompts being eaten up
  # https://github.com/Powerlevel9k/powerlevel9k/pull/1176#discussion_r299303453
  zle && zle .reset-prompt && zle -R
}

zle -N clear-scrollback-buffer
bindkey '^L' clear-scrollback-buffer

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gcp='ssh -i ~/.ssh/id_rsa  subbukl@34.93.146.238'
alias gcp_s='ssh -i ~/.ssh/id_rsa  subbukl@35.200.177.26'
alias gctl='ssh -i ~/.ssh/id_rsa  subbukl@34.93.146.238 /home/subbukl/bin/tl.sh'
alias gl='git log --pretty=format:"%h%x09%an%x09%ad%x09%s"'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias ta='TERM=screen-256color-bce tmux -CC new-session -A -s '
alias tl='telnet localhost 45454'
if [[ -n "${TOTP_SECRET:-}" ]]; then
  alias totp='oathtool -b --totp "$TOTP_SECRET"'
fi
alias pdf='xdg-open '
#alias qvm="ssh root@localhost -p2222"
alias vm='ssh slingappa@ventana-vm-128'
alias pvm='mosh redpanda@172.20.5.120 tmux'
alias pvms='ssh redpanda@172.20.5.120'
alias pvmt='ssh redpanda@172.20.5.120  -t "tmux new-session -s user || tmux attach-session -t user"'
alias tnet='~/bin/tnet.sh'
alias qm='./qm.sh'
alias kl="~/bin/kl.sh"
alias sf="~/bin/send_forceoff.sh"
alias cs="cscope -d"
alias csr="ctags -R; cscope -R"
alias csd="cscope -d"
alias pi="ssh pi@raspberrypi.local"
alias pi2="ssh pi@pi2.local"
alias pi4="ssh pi4@pi4.local"
#alias pi5="ssh pi5@192.168.0.105"
alias pi5="ssh pi5@pi5.local"
alias pi6="ssh pi6@pi6.local"
alias tl="tail -F "
alias tmc="tmux kill-pane -a "
alias fscp="rsync --partial --progress -Pav -e ssh  "

alias loop_desko='for i in `seq 100`; do clear; sleep 1; wget -O -  http://192.168.0.101 ; done'

#export VMS_PATH=/home/redpanda/git/vt_caliptra/
export VMS_PATH=/home/redpanda/git/caliptra_demo/
export QEMU_PATH=$VMS_PATH/qemu/build
export LUCROM_SOURCE_PATH=$VMS_PATH/veyron-v2-luc-rom
export LUCROM_BUILD_FW_DIR=build/platform/veyron-v2/firmware
export LUCROM_BUILD_OP_DIR=$LUCROM_SOURCE_PATH/$LUCROM_BUILD_FW_DIR
export LUCROM=$LUCROM_BUILD_OP_DIR/lucrom
export PATH=$QEMU_PATH:$PATH
alias lddd='ddd --debugger riscv64-unknown-linux-gnu-gdb $LUCROM.elf --eval-command="target remote localhost:1234"'
alias lqmu='qemu-system-riscv64 -M ventana-luc-sandbox-v2 -nographic -bios $LUCROM.bin -d guest_errors -D 1m_log.txt --semihosting-config enable=on'
alias lqm0='lqmu -s -S'
alias lqm1='rm /dev/shm/qemu-ram; lqmu -object memory-backend-file,id=mem,size=1025M,mem-path=/dev/shm/qemu-ram,share=on -machine memory-backend=mem'
alias lqm2='lqm1 -s -S'
alias lqm3='lqmu -object memory-backend-file,id=mem,size=1025M,mem-path=/dev/shm/qemu-ram,share=on -machine memory-backend=mem'
alias gtl='git log --pretty=format:"%h%x09%an%x09%ad%x09%s"'
alias gtb='git branch | more'
alias gts='git status | more'
alias tl='telnet localhost 45454'
alias tmh='tmux split-window -h -c "#{pane_current_path}"'
alias tmv='tmux split-window -v -c "#{pane_current_path}"'
alias get_idf='. $HOME/esp/esp-idf/export.sh'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#eval "$(starship init zsh)"

function tmux-connect {
    TERM=xterm-256color ssh -p ${3:-22} $1@$2 -t "tmux new-session -s $1 || tmux attach-session -t $1"
  }

export ARCH=riscv
export CROSS_COMPILE=riscv64-unknown-linux-gnu-
export PATH=/home/redpanda/git/caliptra_demo//qemu/build:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/redpanda/bin:/usr/local/bin:/home/redpanda/.cargo/bin:/home/redpanda/local/bin:/home/redpanda/.local/bin:/usr2/slingapp/.local/bin

alias sd='~/bin/sd.sh'
alias duhome="du -sh ~/* ~/.??* 2>/dev/null | sort -h"
alias kl="sd; ~/bin/kl.sh"

#export PAGER="vim -R +AnsiEsc"
#cd /home/redpanda/git/ventana_openbmc_ws
# Autostart Tmux session if not already attached
#if ! pgrep -x tmux > /dev/null
#then
#    tmux new-session -d -s main || true
#    tmux attach-session -t main
#else
#    tmux attach-session || true
#fi

## Disable shared history between all sessions/panes
#unsetopt share_history
#
## Set a unique history file for each tmux pane
#if [[ -n "$TMUX_PANE" ]]; then
#  HISTFILE=$HOME/.zsh_history_dir/tmux_$(echo "$TMUX_PANE" | tr -d '%:')
#else
#  # Fallback for sessions outside of tmux
#  HISTFILE=$HOME/.zsh_history
#fi
#
## Recommended history options
#setopt inc_append_history   # Immediately append history to the history file
#setopt hist_ignore_dups     # Ignore duplicate commands
#setopt hist_ignore_space    # Ignore commands starting with a space
#setopt hist_save_nodups     # Don't save dups to the history file
#setopt hist_expire_dups_first # Remove older duplicate entries first
#

# --- History sizing (optional but recommended) ---
# Keep enough history in memory and on disk
HISTSIZE=${HISTSIZE:-100000}
SAVEHIST=${SAVEHIST:-100000}

# Keep timestamps for better merging and auditing
setopt extended_history

# Your recommended history options (kept as-is)
setopt inc_append_history     # Immediately append commands to $HISTFILE
setopt hist_ignore_dups       # Ignore duplicate commands in a row
setopt hist_ignore_space      # Ignore commands starting with space
setopt hist_save_nodups       # Don't save dups to the history file
setopt hist_expire_dups_first # Remove older duplicate entries first

# --- Paths ---
: ${ZSH_GLOBAL_HIST:="$HOME/.zsh_history"}
: ${ZSH_PANE_HIST_DIR:="$HOME/.zsh_history_dir"}
mkdir -p -- "$ZSH_PANE_HIST_DIR"

# --- 1) Import global history into this shell's memory at startup ---
# Do this BEFORE pointing HISTFILE to a per-pane file so we don't write global into pane file.
if [[ -s "$ZSH_GLOBAL_HIST" ]]; then
  builtin fc -R -- "$ZSH_GLOBAL_HIST"
fi

# --- 2) Use a per-pane history file inside tmux ---
if [[ -n "$TMUX_PANE" ]]; then
  # Sanitize pane ID to be filesystem-safe (zsh substitution removes % and :)
  pane_id="${TMUX_PANE//[%:]/}"
  export HISTFILE="$ZSH_PANE_HIST_DIR/tmux_${pane_id}"
else
  export HISTFILE="$ZSH_GLOBAL_HIST"
fi

# Ensure the active history file exists
: >| "$HISTFILE"

# --- 3) Merge back into the global history (deduped) ---
# A tiny lock helper to avoid concurrent writes from multiple panes
_zsh_hist_lock() {
  local lock="$ZSH_GLOBAL_HIST.lock"
  local tries=0
  # mkdir as a lock (portable); remove on RETURN trap
  until mkdir "$lock" 2>/dev/null; do
    (( tries++ > 100 )) && return 1  # ~5s max wait
    sleep 0.05
  done
  # When the function returns, remove the lock
  trap 'rmdir "$lock"' RETURN
  return 0
}

# Merge current pane's history (and existing global) into a clean global history.
# We use a child zsh to apply zsh's own history rules while writing.
zsh_hist_merge_global() {
  [[ -w "$ZSH_GLOBAL_HIST" || ! -e "$ZSH_GLOBAL_HIST" ]] || return 0

  _zsh_hist_lock || return 0

  # Use a subshell zsh to read both files and write out a de-duplicated global
  # We include extended_history so timestamps are preserved.
  command zsh -c '
    setopt extended_history hist_ignore_dups hist_save_nodups hist_expire_dups_first
    global="$1"; shift
    # Read existing global first
    [[ -s "$global" ]] && builtin fc -R -- "$global"
    # Then read this pane (if any)
    for f in "$@"; do
      [[ -s "$f" ]] && builtin fc -R -- "$f"
    done
    # Now write a clean global (overwrites)
    HISTFILE="$global"
    builtin fc -W -- "$HISTFILE"
  ' -- "$ZSH_GLOBAL_HIST" "$HISTFILE" 2>/dev/null
}

# --- Choose how often to merge back ---

# Option A: Merge back on shell exit (recommended: simple and low overhead)
autoload -Uz add-zsh-hook
add-zsh-hook zshexit zsh_hist_merge_global

# Option B: Merge back periodically at each prompt (comment Option A and uncomment this)
#   This throttles to at most once every 10 seconds to reduce contention.
#   NOTE: Continuous merging is heavier if you have many panes.
#last_hist_merge_epoch=0
#zsh_hist_precmd_merge() {
#  local now=$EPOCHSECONDS
#  (( now - ${last_hist_merge_epoch:-0} >= 10 )) || return
#  last_hist_merge_epoch=$now
#  zsh_hist_merge_global
#}
#add-zsh-hook precmd zsh_hist_precmd_merge
#
export PATH=/local/mnt/workspace/ts_ws_0.21.1-rc2/ventana-cross-toolchain-2025.11.18/bin:/usr2/slingapp/workspace/git/dvtools-vt2/build/iss/models/ebba:/usr2/slingapp/.local/bin/:/usr2/slingapp/bin/:${PATH}
export PATH=/usr2/slingapp/local//bin:$PATH


alias sg="GIT_SSH_COMMAND='ssh -i ~/.ssh/slingappa_git/id_rsa -o IdentitiesOnly=yes' git "

# QGenie Environment Variables
[ -f "/usr2/slingapp/.qgenie/.exports" ] && source "/usr2/slingapp/.qgenie/.exports"

qdbg() { qgenie agent exec -C "$PWD" --sandbox workspace-write "$*"; }


# Keep your manual alias too (optional)
alias sg="GIT_SSH_COMMAND='ssh -i ~/.ssh/slingappa_git/id_rsa -o IdentitiesOnly=yes' git"

git() {
  local key_cmd="ssh -i ~/.ssh/slingappa_git/id_rsa -o IdentitiesOnly=yes"
  local remotes

  # 1) For commands that include a URL (e.g. clone)
  if [[ "$*" == *"git@github.com:slingappa/"* || "$*" == *"git@github.com:slingappa:"* ]]; then
    GIT_SSH_COMMAND="$key_cmd" command git "$@"
    return
  fi

  # 2) For commands run inside an existing repo
  remotes="$(command git config --get-regexp '^remote\..*\.url$' 2>/dev/null)"
  if [[ "$remotes" == *"git@github.com:slingappa/"* || "$remotes" == *"git@github.com:slingappa:"* ]]; then
    GIT_SSH_COMMAND="$key_cmd" command git "$@"
  else
    command git "$@"
  fi
}


