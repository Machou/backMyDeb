#!/bin/bash


## Options Requires

# Path to the temporary folder used for backups, can't be empty
STORE_PATH="/root/backup"

# Path to the folder that will be saved, can't be empty
DIR_BACKUP="/var/www"


## Options not required

# Path to folders whose files are to be excluded, can be empty
DIR_EXC[0]=""

# Request to execute before saving, can be empty
SQL_QUERY=""


# Path to the log file
LOG_FILE="/root/backup/backup.log"


# Generate the log file, if it does not exist
if [ ! -e "$LOG_FILE" ]; then
	echo 0 > $LOG_FILE
fi


# Clean log file
>$LOG_FILE

exec > >(tee -a $LOG_FILE)
exec 2> >(tee -a $LOG_FILE >&2)


# Tar Archive Password
COMPR_PASS=""


# Email and account password to upload your backup file
C_MAIL=""
C_PASS=""


# Database identifiers
DB_HOST="localhost"
DB_NAME=""
DB_USER=""
DB_PASS=""


##################################################


CUR_DATE_TIME=`date +\%d\%m\%Y-\%H`
CUR_DATE_TIME_H="`date +\%d-\%m-\%Y` - `date +\%H`h`date +\%M`mins`date +\%S`secs"
CUR_DATE=`date +\%d\%m\%Y`
START=$(date +%s)


echo "-------------- START OF BACKUP - $CUR_DATE_TIME_H --------------"


# 1. Executing the SQL query before saving the database
if [ "$SQL_QUERY" != "" ]; then
	echo "-------------- 1 -- $CUR_DATE_TIME_H -- Executing the SQL query before saving the database --------------"
	echo "$SQL_QUERY" | mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME
else
	echo "-------------- 1 -- $CUR_DATE_TIME_H -- No SQL query to run --------------"
fi


# 2. Backup the database
echo "-------------- 2 -- $CUR_DATE_TIME_H -- Backup the database --------------"
mysqldump --skip-add-drop-table --single-transaction -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz | tee -a $LOG_FILE


# 3. Backup the files
echo "-------------- 3 -- $CUR_DATE_TIME_H -- Backup the files --------------"

# Exclude the directory mentioned
if [ "$DIR_EXC[0]" != "" ]; then
	DIR_EXCLUDE="$FL_BACKUP"
	for dir in "${DIR_EXC[@]}"
	do
		echo "Excluding files in the folder: $dir"
		DIR_EXCLUDE+="--exclude=\"$dir/*\" "
	done
else
	echo "-------------- 3 -- $CUR_DATE_TIME_H -- No folder is to be excluded --------------"
fi

eval "tar -czf $STORE_PATH/files.$CUR_DATE_TIME.tar.gz $DIR_EXCLUDE -C $DIR_BACKUP ." | tee -a $LOG_FILE


# 4. Create a tar archive with files + database with a password
echo "-------------- 4 -- $CUR_DATE_TIME_H -- Create a tar archive with files + database with a password --------------"
tar -czf -p$COMPR_PASS -r "$STORE_PATH/backup.$CUR_DATE_TIME.tar.gz" "$STORE_PATH/files.$CUR_DATE_TIME.tar.gz" "$STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz" | tee -a $LOG_FILE


# 5. Upload to the cloud
#echo "-------------- 5 -- $CUR_DATE_TIME_H -- Upload to the cloud --------------"
#echo "File upload in progress: `ls -alh $STORE_PATH/backup.$CUR_DATE_TIME.7z | cut -d" " -f5-`"
#/usr/bin/plowup 1fichier -a "$C_MAIL:$C_PASS" $STORE_PATH/backup.$CUR_DATE_TIME.7z | tee -a $LOG_FILE


# 6. Deleting backup files
echo "-------------- 6 -- $CUR_DATE_TIME_H -- Deleting backup files --------------"
rm $STORE_PATH/files.$CUR_DATE_TIME.tar.gz | tee -a $LOG_FILE
rm $STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz | tee -a $LOG_FILE
rm $STORE_PATH/backup.$CUR_DATE_TIME.7z | tee -a $LOG_FILE


# 7. Execution time display
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "-------------- Backup completed after $DIFF seconds"
