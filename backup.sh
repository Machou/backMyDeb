#!/bin/bash

## Path to the temporary folder used for backups
STORE_PATH="/root"

## Path to the folder that will be saved
DIR_BACKUP="/var/www"

## Path to folders whose files are to be excluded
DIR_EXC[0]=""

## Request to execute before saving
SQL_QUERY=""

## Path to the log file
LOG_FILE="/root/backup.log"

# Create log file if it does not exist
if [ ! -e "$LOG_FILE" ]; then
	echo 0 > $LOG_FILE
fi

## Reset log file to zero
>$LOG_FILE

exec > >(tee -a $LOG_FILE)
exec 2> >(tee -a $LOG_FILE >&2)

## Archive password
COMPR_PASS=""

## Account email and password (Plowshare)
C_MAIL=""
C_PASS=""

## Database Identifiers
DB_HOST="localhost"
DB_NAME=""
DB_USER=""
DB_PASS=""


##################################################


CUR_DATE_TIME=`date +\%d\%m\%Y-\%H\%M`
CUR_DATE_TIME_H="`date +\%d-\%m-\%Y` à `date +\%H`h`date +\%M`mins`date +\%S`secs"
CUR_DATE=`date +\%d\%m\%Y`
START=$(date +%s)


echo "-------------- DÉMARRAGE DE LA SAUVEGARDE EN DATE DU $CUR_DATE_TIME_H --------------" | tee -a $LOG_FILE


## 1. Starting SQL Script Before Backup
if [ "$SQL_QUERY" != "" ]; then
	echo "-------------- 1 -- $CUR_DATE_TIME_H -- Exécution de la requête SQL avant la sauvegarde de la base de données --------------" | tee -a $LOG_FILE
	echo "$SQL_QUERY" >> $LOG_FILE
	echo "$SQL_QUERY" | mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME | tee -a $LOG_FILE
else
	echo "-------------- 1 -- $CUR_DATE_TIME_H -- Aucune requête SQL à exécuter --------------" | tee -a $LOG_FILE
fi



## 2. Backup database
echo "-------------- 2 -- $CUR_DATE_TIME_H -- Sauvegarde de la base de données --------------" | tee -a $LOG_FILE
mysqldump --skip-add-drop-table --single-transaction -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz | tee -a $LOG_FILE



## 3. Backup files
echo "-------------- 3 -- $CUR_DATE_TIME_H -- Sauvegarde des fichiers --------------" | tee -a $LOG_FILE

## Exclusion du repertoire mentionné
if [ "$DIR_EXC[0]" != "" ]; then
	DIR_EXCLUDE="$FL_BACKUP"
	for dir in "${DIR_EXC[@]}"
	do
		echo "Exclusion des fichiers dans le dossier : $dir"
		DIR_EXCLUDE+="--exclude=\"$dir/*\" "
	done
fi

eval "tar -czf $STORE_PATH/files.$CUR_DATE_TIME.tar.gz $DIR_EXCLUDE -C $DIR_BACKUP ." | tee -a $LOG_FILE



## 4. Backup database + files with password ( just comment if you don't want use this)
echo "-------------- 4 -- $CUR_DATE_TIME_H -- Creation de l archive complète avec mot de passe --------------" | tee -a $LOG_FILE
tar -czf -p$COMPR_PASS -r $STORE_PATH/backup.$CUR_DATE_TIME.7z $STORE_PATH/files.$CUR_DATE_TIME.tar.gz $STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz | tee -a $LOG_FILE



## 5. Upload to website ( just comment if you don't want use this)
echo "-------------- 5 -- $CUR_DATE_TIME_H -- Upload vers la plateforme --------------" | tee -a $LOG_FILE
echo "Fichier en cours d'upload : `ls -alh $STORE_PATH/backup.$CUR_DATE_TIME.7z | cut -d" " -f5-`"
/usr/bin/plowup 1fichier -a "$C_MAIL:$C_PASS" $STORE_PATH/backup.$CUR_DATE_TIME.7z | tee -a $LOG_FILE



## 6. Delete files backup
echo "-------------- 6 -- $CUR_DATE_TIME_H -- Suppression des fichiers de sauvegarde sur le serveur --------------" | tee -a $LOG_FILE

rm $STORE_PATH/files.$CUR_DATE_TIME.tar.gz | tee -a $LOG_FILE
rm $STORE_PATH/BDD.$CUR_DATE_TIME.sql.gz | tee -a $LOG_FILE
rm $STORE_PATH/backup.$CUR_DATE_TIME.7z | tee -a $LOG_FILE



## Display execution time
END=$(date +%s)
DIFF=$(( $END - $START ))


echo "-------------- Sauvegarde terminée après $DIFF secondes" | tee -a $LOG_FILE