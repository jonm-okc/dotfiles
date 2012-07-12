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
alias qamachine='ssh web1qa.sfo2.zoosk.com'
alias jump='ssh jump.sea.zoosk.com'

function devid()
{
	if [ ! -z $1 ]; then
		export DEVID=$1
	fi
	
	echo "DEVID = "$DEVID
}

function _devmachine()
{
	if (( $DEVID < 10 )) ; then
		echo "web1dev.sfo2.zoosk.com"
	elif (( $DEVID < 20 )) ; then
		echo "web2dev.sfo2.zoosk.com"
	elif (( $DEVID < 30 )) ; then
		echo "web3dev.sfo2.zoosk.com"
	else
		echo "web4dev.sfo2.zoosk.com"
	fi	
}


######################################################
# Database Functions
######################################################

export LOCAL_DB_USER="superjon"
export LOCAL_DB_PASS="asdf123qwe"
export EXEC_MYSQL_LOCAL="mysql -h localhost -u $LOCAL_DB_USER -p$LOCAL_DB_PASS"
alias mydb="$EXEC_MYSQL_LOCAL"

function _dbname()
{
	local db=$1
	
	if (( $DEVID < 10 )) ; then
		echo "0${DEVID}${db}"
	else
		echo "${DEVID}${db}"
	fi	
}

function _db_exec_str()
{
	local user=$(_dbname services)
	local password=$(_dbname pass)
	
	echo "mysql -h $DEV_DB -u $user -p$password"
}

function dbconnect()
{
	local db_host=localhost
	local db_name=$(_dbname $1)
	
	if [ "$2" == '-e' ]; then
		mysql -h $db_host -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $db_name -e "$3" || return -1
	else
		mysql -h $db_host -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $db_name || return -1
	fi
}

function dbuserall()
{	
	if [ -z "$1" ]; then
		echo 'usage: dbuserall "<SQL statement>"'
		return -1
	fi
	
	local sql=$1
	echo "Running SQL on both user clusters: \"$sql\""

	echo "Executing on dbuser1"
	dbconnect user1 -e "$sql" || return -1
	
	echo "Executing on dbuser2"
	dbconnect user2 -e "$sql" || return -1
	
	echo "Complete"
}

function dbuserfile()
{	
	if [ -z "$1" ]; then
		echo 'usage: dbuserfile <file1> [<file2> ...]'
		return -1
	fi

	for f in $* ; do
		echo "Running file $f on user databases"
		dbconnect user1 < $f || return -1
		dbconnect user2 < $f || return -1
	done
	
	echo "Complete"
}


alias dbaffinity1="dbconnect affinity1"
alias dbaffinity2="dbconnect affinity2"
alias dbuser1="dbconnect user1"
alias dbuser2="dbconnect user2"
alias dbmsg1="dbconnect msg1"
alias dbmsg2="dbconnect msg2"
alias dbglobal="dbconnect zoosk"
alias dbfinance="dbconnect finance"
alias dbschwartz="dbconnect theschwartzdb"

alias jondb="mysql -h $DEV_DB -u superjon -pasdf123qwe"

function devuserinfo() {
	if [ -z $1 ]; then
		echo "usage: usercluster <user id|user guid>"
		return -1
	fi
	
	local uid=$1
	if [[ $uid =~ ^[0-9]+$ ]] ; then
		local sql="SELECT * FROM mapuser WHERE user_id = $uid\G"
	else
		local sql="SELECT * FROM mapuser WHERE guid = '$uid'\G"
	fi
	
	dbglobal -e "$sql"
}

#
# Backs up all the databases in a dev instance to a specified directory,
# creating a different file for each database.  Uses mysqldump to create
# the files.
#
# Usage: backup_db <num user clusters> <host> <output directory>
#
function backup_dev_databases()
{
	local numUserClusters=$1
	local host=$2
	local outdir=$3
	
	if [ -z "$outdir" ] ; then
		echo "Usage: backup_db <num user clusters> <host> <output directory>"
		return -1
	fi
	
	mkdir -p $outdir || { echo "Could not create $outdir" ; return -1 ; }
	
	local dbprefix=$DEVID
	if (( $DEVID < 10 )) ; then
		dbprefix="0${DEVID}"
	fi
	local dbuser="${dbprefix}services"
	local dbpass="${dbprefix}pass"

	local userdbs=
	local gamedbs=
	for (( i=1; i<=$numUserClusters; i++ )) ; do
		userdbs="$userdbs user${i}"
		gamedbs="$gamedbs game${i}"
	done

	local dbnames="admindb affinity1 affinity2 event finance $gamedbs msg1 msg2 photodb schwartz2db theschwartzdb $userdbs util zoosk"
	
	local dblist=""
	for db in $dbnames ; do
		dblist="$dblist ${dbprefix}${db}"
	done
	
	echo "Outputting the following databases to $outdir:"
	echo "  $dblist"

	for db in $dblist ; do
		local outfile="$outdir/${db}.sql"
		echo "Dumping $db to $outfile"
		mysqldump --host=$host --user=$dbuser --password=$dbpass $db > $outfile
		if [ $? != 0 ] ; then
			echo "An error occurred outputting $db to $outfile"
			return -1
		fi
	done
	
	echo ""
	echo "Completed outputting databases to $outdir"
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
alias now="date +%Y-%m-%d_%H%M%S"
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
