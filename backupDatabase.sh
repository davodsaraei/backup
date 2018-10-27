DIRECTORY='/opt/backup'
. $DIRECTORY/database-setting.sh
# FILES NAME SETTING
SQL_FILE_NAME=$DIRECTORY'/db.sql'
ARCHIVE_FILE_NAME=$SQL_FILE_NAME".tar.gz"

# CREATE BACKUP FILE
mysqldump -u $DATA_BASE_USER_NAME -p$DATA_BASE_PASSWORD $DATA_BASE_NAME > $SQL_FILE_NAME
echo 'database dump saved in sql file...'
# CREATED .SQL FILE WITH NAME TODAY DAY NUMBER

# ZIP SQL FILE
tar -zcvf $ARCHIVE_FILE_NAME $SQL_FILE_NAME
echo 'zip file created...'

# ENCRYPT ZIP FILE
ENCRYPTED_FILE_PATH=$ARCHIVE_FILE_NAME".enc"
openssl aes-256-cbc -a -salt -in $ARCHIVE_FILE_NAME -out $ENCRYPTED_FILE_PATH -pass file:$DIRECTORY'/passfile'
echo 'encrypted...'

if [ $1 = 'init' ]; then
    gdrive upload $ARCHIVE_FILE_NAME'.enc'
else
    gdrive update $DATABASE_ID $ARCHIVE_FILE_NAME'.enc'
fi

echo 'pushed successfully!'

# MOVE ENCRYPTED FILE TO BARREL
SECURE_FOLDER=$DIRECTORY/secure/
INSECURE_FOLDER=$DIRECTORY/insecure/
mv -f $ENCRYPTED_FILE_PATH $SECURE_FOLDER
mv -f $SQL_FILE_NAME $INSECURE_FOLDER 
echo 'moved!' 

rm $ARCHIVE_FILE_NAME
echo 'deleted files'


