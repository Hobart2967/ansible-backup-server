#!/bin/bash
#==============================================================================
#TITLE:            mysql_backup.sh
#DESCRIPTION:      script for automating the daily mysql backups on development computer
#USAGE:            ./mysql_backup.sh
#CRON:
  # example cron for daily db backup @ 9:15 am
  # min  hr mday month wday command
  # 15   9  *    *     *    /Users/[your user name]/scripts/mysql_backup.sh

#RESTORE FROM BACKUP
  #$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]

if [ $# -ne 6 ]; then
  echo "Usage: $0 <tunnel-name> <mysql-username> <mysql-password> <mysql-host> <mysql-port> <backup-directory>"
  exit 1
fi

#==============================================================================
# CUSTOM SETTINGS
#==============================================================================

# MYSQL Parameters
MYSQL_UNAME=$2
MYSQL_PWORD=$3
MYSQL_HOST=$4
MYSQL_PORT=$5

# directory to put the backup files
BACKUP_DIR=$6

# Don't backup databases with these names
# Example: starts with mysql (^mysql) or ends with _schema (_schema$)
IGNORE_DB="(^mysql|_schema$)"

# include mysql and mysqldump binaries for cron bash user
PATH=$PATH:/usr/local/mysql/bin

# Number of days to keep backups
KEEP_BACKUPS_FOR=30 #days

#==============================================================================
# METHODS
#==============================================================================

# YYYY-MM-DD
TIMESTAMP=$(date +%F)

function delete_old_backups()
{
  echo "Deleting $BACKUP_DIR/*.sql.gz older than $KEEP_BACKUPS_FOR days"
  find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
  echo "Done cleaning up."
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME -h$MYSQL_HOST -P$MYSQL_PORT"
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD"
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r';
  printf ' %0.s' {0..100}
  printf '\r';
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$TIMESTAMP.$database.sql.gz"
    output+="$database => $backup_file\n"
    echo_status "...backing up $count of $total databases: $database"
    $(mysqldump $(mysql_login) $database | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function hr(){
  printf '=%.0s' {1..100}
  printf "\n"
}

#==============================================================================
# RUN SCRIPT
#==============================================================================


mkdir -p $BACKUP_DIR

delete_old_backups
hr
echo "Creating SSH tunnel for connections to ${MYSQL_HOST}:${MYSQL_PORT}..."
/usr/sbin/service ssh-tunnel-$1 start
echo "Established!"
sleep 5
echo "Initializing backup"
backup_databases
echo "Done backing up, closing tunnel"
hr
/usr/sbin/service ssh-tunnel-$1 stop
printf "All backed up!\n\n"