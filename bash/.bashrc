export PATH=$PATH:/usr2/slingapp/.local/bin:/usr2/slingapp/workspace/git/dvtools-vt2/build/iss/models/ebba
export PATH=/usr2/slingapp/local//bin:$PATH
export SSTATE_DIR="${HOME}/workspace/data/bitbake.sstate"
export DL_DIR="${HOME}/workspace/data/bitbake.downloads"

precmd() {
	echo "[PRE][$(date)] Running: $BASH_COMMAND"
}

postcmd() {
	echo "[POST][$(date)] Exit status: $?"
}

#trap precmd DEBUG
#PROMPT_COMMAND=postcmd
