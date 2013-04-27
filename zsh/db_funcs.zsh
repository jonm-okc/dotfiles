######################################################
# Database Functions
######################################################

setopt SH_WORD_SPLIT

export LOCAL_DB_USER="root"
export LOCAL_DB_PASS=""
export EXEC_MYSQL_LOCAL="mysql -h localhost -u $LOCAL_DB_USER -p$LOCAL_DB_PASS --default-character-set=utf8"
alias mydb="$EXEC_MYSQL_LOCAL --table"

function dbconnect()
{
	local db_host=localhost
	local db_name=$1
	
	local exec_params="-h $db_host -u $LOCAL_DB_USER $db_name"
	if [ ! "$LOCAL_DB_PASS" = "" ]; then
	  exec_params="$exec_params -p$LOCAL_DB_PASS"
  fi
	  
	
	if [ "$2" = "-e" ]; then
		mysql $exec_params -e "$3" || return -1
	else
		mysql $exec_params || return -1
	fi
}

function db_truncate_tables()
{
  local db_name=$1
  shift
  local sql=""
  
  for t in $* ; do
    sql="$sql TRUNCATE TABLE $t;"
  done
  
  dbconnect $db_name -e "$sql"
}

function db_auto_increment()
{
  local db_name=$1
  local table=$2
  local auto_inc=$3
  
  local sql="ALTER TABLE $table AUTO_INCREMENT = $auto_inc;"
  dbconnect $db_name -e "$sql"
}

function sq-month() {
  local col=$1
  echo "DATE_FORMAT($col, '%Y-%m') as ${col}_month"
}

function sq-day() {
  local col=$1
  echo "DATE_FORMAT($col, '%Y-%m-%d') as ${col}_day"
}

# Outputs SQL queries that can be used to get a count of distributions in a
# table, grouped by the columns specified.  If the column starts with "mon_"
# or "day_", it transforms a DATE or DATETIME columns into a month or date.
#
# Ex: sql-distro users mon_created_at status
# => SELECT DATE_FORMAT(created_at, '%Y-%m') as mon_created_at, status, FORMAT(COUNT(*),0) as num_rows FROM users GROUP BY mon_created_at, status;
function sql-distro() {
  if (( $# < 2 )) ; then
    echo "Usage: sql-distro table col1 [col2...]"
    return -1
  fi

  # For some reason, using arrays here causes zsh to crash.  awesome
  # local group_by_arr=()
  # local columns_arr=()

  local group_by=""
  local columns=""
  
  local table="$1"
  local col=""
  
  while shift && [ -n "$1" ]; do
    col="$1"
    #group_by_arr+=($col)
    group_by="${group_by}, ${col}"
    if [[ "${col:0:4}" == "mon_" ]] ; then
      col="DATE_FORMAT(${col:4}, '%Y-%m') as $col"
    elif [[ "${col:0:4}" == "day_" ]] ; then
      col="DATE_FORMAT(${col:4}, '%Y-%m-%d') as $col"
    fi
    #columns_arr+=($col)
    columns="${columns}, $col"
  done
  
  local sql="SELECT ${columns:2}, FORMAT(COUNT(*),0) as num_rows FROM $table GROUP BY ${group_by:2};"
  echo $sql | pbcopy
  echo $sql
}

function sql-value-counts() {
  cd $HOME/dev/OkCupid/SinglesNet/ok-payments
  sql=$(ruby ./bin/test/gen-sql-counts.rb $*)
  rc=$?

  cd -  
  echo "$sql" | pbcopy
  echo "$sql"
  
  return $rc
}

function sql-dynamic-distro() {
  cd $HOME/dev/OkCupid/SinglesNet/ok-payments
  sql=$(SERVICE_ENV=production ruby ./bin/test/count-record-distro.rb $*)
  rc=$?

  cd -  
  echo "$sql" | pbcopy
  echo "$sql"
  
  return $rc
}
