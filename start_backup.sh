#!/bin/bash
# Backup mongo databases

# stop on errors
set -e

pidDir=backup.pid
# lock it
if mkdir ./${pidDir}; then
	echo "Locking succeeded" >&2
else
	echo "Lock failed - exit" >&2
	exit 1
fi

if [ -n "$1" ]; then
    DATESTRING=$1
else
    DATESTRING=`date +"%Y-%m-%d"`
fi

source config.ini
echo "Total number of back ups to be taken = "${TOTAL_BACKUPS}
for i in `seq 1 ${TOTAL_BACKUPS}`;
do
	BACKUP_FILE=BACKUP_${i}
	echo "sourcing backup file = "${BACKUP_FILE}
	source ./config/${!BACKUP_FILE}
	echo "file sourced = "${!BACKUP_FILE}
	case "$TYPE" in

		MONGO )
			echo "Type of database found = MONGO";
			echo "Creating destination folder - "${DESTINATION_FOLDER}
			mkdir -p ${DESTINATION_FOLDER}
			echo "Running mongo dump"
			mongodump --host ${HOST} --port ${PORT} --username ${USERNAME} --password ${PASSWORD} --db ${DB} --out ./${DESTINATION_FOLDER}/backup-${DATESTRING}

			echo "Compressing back folder"
			tar -zcvf ./${DESTINATION_FOLDER}/backup-${DATESTRING}.tar.gz ./${DESTINATION_FOLDER}/backup-${DATESTRING}
			echo "Removing uncompressed folder"
			rm -rf ./${DESTINATION_FOLDER}/backup-${DATESTRING}

			echo "Pushing Backup to S3 Bucket - "${S3_BUCKET}
			aws s3api put-object --bucket ${S3_BUCKET} --key backup-${DATESTRING}.tar.gz --body ./${DESTINATION_FOLDER}/backup-${DATESTRING}.tar.gz

			;;
		MYSQL )
			echo "Type of database found = MYSQL";
			echo "Creating destination folder - "${DESTINATION_FOLDER}
			mkdir -p ${DESTINATION_FOLDER}
			echo "Running mysql dump"
			mysqldump -u${USERNAME} -p${PASSWORD} -h${HOST} -P${PORT} ${DB} > ./${DESTINATION_FOLDER}/backup-${DATESTRING}.sql
			echo "Compressing mysql file"
			gzip ./${DESTINATION_FOLDER}/backup-${DATESTRING}.sql

			echo "Pushing Backup to S3 Bucket - "${S3_BUCKET}
			aws s3api put-object --bucket ${S3_BUCKET} --key backup-${DATESTRING}.sql.gz --body ./${DESTINATION_FOLDER}/backup-${DATESTRING}.sql.gz

			;;
	esac
done

mail -s "backup Completed" {email} <<< "Back Up Completed"
rmdir ./${pidDir}
