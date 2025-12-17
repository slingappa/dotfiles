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
plugins=(git z zsh-autosuggestions colored-man-pages command-not-found extract zsh-history-substring-search pass taskwarrior web-search)

source $ZSH/oh-my-zsh.sh

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
alias totp='oathtool  -b --totp 7C232KQQYRLSQ4RPMJZ24BNTCEYPWI7G'
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
export PATH=/home/redpanda/git/caliptra_demo//qemu/build:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/redpanda/bin:/usr/local/bin:/home/redpanda/.cargo/bin:/home/redpanda/local/bin:/home/redpanda/.local/bin

#export PAGER="vim -R +AnsiEsc"
#cd /home/redpanda/git/ventana_openbmc_ws

