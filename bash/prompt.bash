# Define colors we'll use below
function _color() { 
	echo "\[\e[0;${1}m\]" 
}
function _boldcolor() { 
	echo "\[\e[1;${1}m\]" 
}
function _titlebar() {
	echo -e "\[\033]0;${1}\007\]"
}
RED=$(_color 31)
GREEN=$(_color 32)
YELLOW=$(_color 33)
BLUE=$(_color 34)
MAGENTA=$(_color 35)
CYAN=$(_color 36)
GREY=$(_color 37)

# No color
NC="\[\e[0m\]"

if [[ "a${DISPLAY#$HOST}" == "a" ]]; then  
    HILIT=${RED}   # remote machine: prompt will be partly red
else
    HILIT=${CYAN}  # local machine: prompt will be partly cyan
fi

# Function to get either Subversion or Git info of the current dir
# Requires git completion script
#
# NOTE: git code commented out for now
#
function _scm_ps1() {
	local format="%s"
	if [ -n "${1-}" ]; then
		format=$1
	fi

    local s=
    if [[ -d ".svn" ]] ; then
		local rev=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p' )
		local branch=$(svn info | egrep -o '/(\w+)$')
		#local checkedout=$(svn status | grep -q -v '^?' && echo -n "*" )
		s="svn:${branch}:r${rev}${checkedout}"
#    else
#       s=$(__git_ps1 "git:%s")
    fi

	if [ -z $s ]; then
		echo ''
	else
		printf "$format" "$s"
	fi
}

function _which_workspace()
{
	local format="%s"
	if [ -n "${1-}" ]; then
		format=$1
	fi

	local WS=
	local REGEX='dev/workspace/([A-Za-z0-9_-]+)'
	if [[ $PWD =~ $REGEX ]]; then
		printf "$format" "${BASH_REMATCH[1]}"
		return
	fi
	echo ''
}

#  --> Replace instances of \W with \w in prompt functions below
#+ --> to get display of full path name.

function prompt_basic()
{
    PS1="\h:\w \u\$"
}

function prompt_fast()
{
    unset PROMPT_COMMAND
    case $TERM in
        *term | rxvt )
            PS1="${HILIT}[\h]$NC \W > \[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
		linux )
		    PS1="${HILIT}[\h]$NC \W > " ;;
        *)
            PS1="[\h] \W > " ;;
    esac
}

function prompt_power()
{
    _powerprompt()
    {
        LOAD=$(uptime|sed -e "s/.*: \([^,]*\).*/\1/" -e "s/ //g")
    }

    PROMPT_COMMAND=_powerprompt
    case $TERM in
        *term | rxvt  )
            PS1="${HILIT}[\A \$LOAD]$NC\n[\h \#] \W > \[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
        linux )
            PS1="${HILIT}[\A - \$LOAD]$NC\n[\h \#] \w > " ;;
        * )
            PS1="[\A - \$LOAD]\n[\h \#] \w > " ;;
    esac
}

function prompt_current_ws()
{
	local titlebar=$(_titlebar "\h \w")
	local ws='$(_which_workspace " (%s)")'
	local host="${HILIT}\h${NC}"
	local timestamp="${HILIT}\t${NC}"
	PS1="${titlebar}[${timestamp}][${host}]${MAGENTA}${ws} ${BLUE}\W${GREY} \$${NC} "
}

function prompt_repos()
{
	local TITLEBAR=$(_titlebar "[\u@\h] \w")
	local REPOS_INFO='$(_scm_ps1 " (%s)")'
	PS1="${TITLEBAR}[${HILIT}\h${NC}] ${BLUE}\W${MAGENTA}${REPOS_INFO}${GREY} \$${NC} "
}

function prompt_git()
{
	local TITLEBAR=$(_titlebar "[\u@\h] \w")
	local GIT_REPOS='$(__git_ps1 " (%s)")'
	PS1="${TITLEBAR}[${HILIT}\h${NC}] ${BLUE}\W${GREEN}${GIT_REPOS}${GREY} \$${NC} "
}

# Change this to decide which prompt you want to use
prompt_current_ws


