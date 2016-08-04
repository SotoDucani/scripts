#!/bin/bash

# Note, this requires cifs.utils to be installed on the linux system
# Do this via the command "yum -y install cifs.utils"

# Database Settings
user=""
password=""
host=""
db_name=""

# Backup path and date format
backup_path=""
date=$(date +"%d_%b_%Y")

# Default file permissions
umask 177

# Dump database into a file
mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name_$date.sql

# Delete files older than 14 days
find $backup_path/* -mtime + 14 -exec rm{} \;

# Mount backup location on windows file server
mount -t cifs '//server.on.domain/share/folder' -o username=WindowsUser,password=WindowsPassword /mnt/DesiredMountPoint

# Copy the backup files over
cp -Ru $backup_path /mnt/DesiredMountPoint

# Unmount the windows location
umount /mnt/DesiredMountPoint