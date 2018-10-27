DIRECTORY='/opt/backup'
. $DIRECTORY/file-setting.sh

make_archive_file() {
    tar -czvf $DIRECTORY"/"$1 $2
}

make_file_encrypted() {
    openssl aes-256-cbc -a -salt -in $DIRECTORY"/"$1 -out $DIRECTORY"/"$1".enc" -pass file:$DIRECTORY'/passfile'
}

move_enc_file() {
    mv -f $DIRECTORY"/"$1 $DIRECTORY"/secure/"$1
}

remove_temp_files() {
    rm $DIRECTORY"/"$1
}

push_changes() {
    if [ $2 = 'init' ]; then
        gdrive upload $DIRECTORY'/secure/'$1'.enc'
    else
        gdrive update $3 $DIRECTORY'/secure/'$1'.enc' --timeout 0
    fi
}

backup() {
    # FIRST MAKE ZIP FILE OF EACH FOLDER FILES
    ARCHIVE_FILE_NAME=$2'.tar.gz'
    make_archive_file $ARCHIVE_FILE_NAME $1
    # ENCRYPT IT
    make_file_encrypted $ARCHIVE_FILE_NAME
    move_enc_file $ARCHIVE_FILE_NAME".enc"
    remove_temp_files $ARCHIVE_FILE_NAME
    push_changes $ARCHIVE_FILE_NAME $4 $3
}

backup $LOGO_DIRECTORY 'logo' $LOGO_ID $1