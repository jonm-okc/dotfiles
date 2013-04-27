alias ls='ls -FG'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'
alias alt='ls -alt'
alias dc='cd'

# alias php='/usr/bin/php'

alias ruby='/opt/local/bin/ruby1.9'

EXEC_RSYNC="rsync -rltv"
alias myrsync="$EXEC_RSYNC"

# Redefine pushd so it doesn't keep echoing the directory
function pushd()
{
    builtin pushd "$@" > /dev/null
}

function files_exist()
{
	for f in $* ; do
		if [ -e "$f" ] ; then return 1; fi
	done
	return 0
}

# Use the equal sign as a command-line calculator
# NOTE: don't use any spaces if the * operator is used
# can also enclose in single-quotes if using * or ()
function =()
{
	echo "$*" | bc -l;
}

#
# Allows you to go up N directories.  For example:
#   .. 3
# is the equivalent of doing 'cd ..' 3 times
#
function ..()
{
	if [ -z $1 ]; then
		NUM=1
	else
		NUM="$1"
	fi
	DIR=''
	for ((i=1; i<=$NUM; i++)); do
		DIR="../$DIR"
	done
	cd $DIR
}

alias preview='open -a Preview'
alias log='tail -f /srv/syslog/syslog'


######################################################
# Database Functions
######################################################

export LOCAL_DB_USER="superjon"
export LOCAL_DB_PASS="asdf123qwe"
export EXEC_MYSQL_LOCAL="mysql -h localhost -u $LOCAL_DB_USER -p$LOCAL_DB_PASS"
alias mydb="$EXEC_MYSQL_LOCAL"

function _db_exec_str()
{
	local user=$(_dbname services)
	local password=$(_dbname pass)
	
	echo "mysql -h $DEV_DB -u $user -p$password"
}

function dbconnect()
{
	local db_host=localhost
	local db_name=$1
	
	if [ "$2" == '-e' ]; then
		mysql -h $db_host -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $db_name -e "$3" || return -1
	else
		mysql -h $db_host -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $db_name || return -1
	fi
}

#-----------------------------------
# Process/system related functions:
#-----------------------------------

function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,time,command ; }
function pp() {
	if [ -z "$1" ] ; then echo "Usage: pp <process_name>" ; return -1; fi
	my_ps -f | awk '!/awk/ && $0~var' var=${1:-".*"} 
}

alias today="date +%Y-%m-%d"
# alias now="date +%Y-%m-%d_%H%M%S"   # the %S has issues w/ zsh
alias utctime='date -u +%Y-%m-%d\ %H:%M:%S'
alias matedot="mate ~/dotfiles/"
alias mateprops="mate ~/dev/workspace/*.properties"
alias rehash="hash -r"

alias jsondecode="php -r 'print_r(json_decode(file_get_contents(\"php://stdin\")));'"


# Load the other aliases
files_exist $DOTFILE_DIR/*_aliases.bash
if [ "$?" == "1" ] ; then
	for file in $DOTFILE_DIR/*_aliases.bash ; do
		dotfile-load $(basename $file)
	done
fi
