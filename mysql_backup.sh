#!/bin/bash
#==============================================================================
#TITLE:            mysql_backup.sh
#DESCRIPTION:      script for automating the daily mysql backups on development computer
#AUTHOR:           tleish
#DATE:             2013-12-20
#VERSION:          0.4
#USAGE:            ./mysql_backup.sh
#CRON:
  # example cron for daily db backup @ 9:15 am
  # min  hr mday month wday command
  # 15   9  *    *     *    /Users/[your user name]/scripts/mysql_backup.sh

#RESTORE FROM BACKUP
  #$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]

#==============================================================================
# CUSTOM SETTINGS
#==============================================================================

# directory to put the backup files
BACKUP_DIR=/backups

# MYSQL Parameters
MYSQL_UNAME=root
MYSQL_PWORD=

# Don't backup databases with these names 
# Example: starts with mysql (^mysql) or ends with _schema (_schema$)
IGNORE_DB="(^mysql|_schema$)"

# include mysql and mysqldump binaries for cron bash user
PATH=$PATH:/usr/local/mysql/bin

# Number of min to keep backups
KEEP_BACKUPS_FOR=3 #min

#Check min size
MINIMUM_SIZE=800

#==============================================================================
# METHODS
#==============================================================================

# YYYY-MM-DD
TIMESTAMP=$(date +%F_%H-%M)


function check_size()
{
  actualsize=$(stat -c%s ${backup_file})
  if [[ ${actualsize} -le ${MINIMUM_SIZE} ]]; then
    echo "${backup_file} size is under ${MINIMUM_SIZE}" 
    exit 1
  fi
}



function create_backups_folder()
{
  echo "Check backup folder ${BACKUP_DIR}"
  if [[ ! -d "${BACKUP_DIR}" ]]; then
    mkdir -p ${BACKUP_DIR} || exit 1 
  fi 
}


function delete_old_backups()
{
  echo "Deleting $BACKUP_DIR/*.sql.gz older than $KEEP_BACKUPS_FOR min"
  find $BACKUP_DIR -type f -name "*.sql.gz" -mmin +$KEEP_BACKUPS_FOR -exec rm {} \;
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME" 
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
    mysqldump $(mysql_login) $database | gzip -9 > $backup_file
    if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]];then exit 1; fi
    check_size
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
create_backups_folder
hr
backup_databases
hr
delete_old_backups
hr
printf "All backed up!\n\n"
