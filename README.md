# MongoDb / Mysql backup to S3

A simple script to store back up in S3. It is ideal for medium scale backups. Mysqldump will lock take lock on all tables while generating .sql file. Hence it is not recommended for large databases.
Snapshot would be ideal for large scale databases.

# Setup requirements
  - aws cli should already be configured
  - mongo shell if mongodb backup is required
  - mysql-client if mysql backup is required

# Configuration Files

> config.ini
  - TOTAL_BACKUPS : The number of host back up is required for.
  - BACKUP_{$i} : If you need to take back for 3 host then, as many variables should be present. Explained below :

```config.ini
  TOTAL_BACKUPS=3
  BACKUP_1=mongo_staging.ini
  BACKUP_2=mongo_production.ini
  BACKUP_3=mysql_production.ini
```

> Config files for each host.
- Each config files would be present under the config folder. It needs following variable

```config.ini
TYPE=[MONGO/MYSQL]
DESTINATION_FOLDER=mongo_production
HOST=mongo-prod-host
PORT=27017
USERNAME=confused-pv
PASSWORD=YES
DB=pv
S3_BUCKET=mongo-production
```
# Execution

> confused@Prakhars-MacBook-Pro ~ $ sh start_backup.sh

You can just put in crontab of your system to make sure backup is done every day without any issue.

### Version
1.0.0
