#!/bin/sh
# Filesystem backup script
#
# Version: 0.1
# Author: Nagu Gopalakrishnan (avial.io)
#
# Dependency tar
#
# inspired by ideas from https://code.google.com/p/mycodedump/wiki/BackupScripts
#
# Changelog:
# July 08 2015 / Version 0.1 / Initial release

####### Configuration #######

# Which all directories do you want to back up? Use [space] as seperators
DIRS="var/www/ var/data etc"

# Log File location
LOGFILE="/var/log/ftpbackup.log"

Which directory you would store as local backup. This is where the backed up data would be compressed and stored
BACKUPDIR="/backup/filesystem"

# Directory, where a copy of the "latest" dumps will be stored
LATEST=$BACKUPDIR/latest

# When do you want to do a full backup? By defualt it is an incremental backup. 
#Day of Week (1-7) where 1 is monday
FULLBACKUP="7"

#######House keeping############
# if housekeeping set to ON, housekeeping would be done by deleting older files
HOUSEKEEP=1

# How old would you like to keep the files, before house keeping is done
OLDERTHAN=14

### Now the backup exection ###
# File having info on incremental backup
INCFILE=$BACKUPDIR/tar-inc-backup.bac

#date for easy identification of file stamp
NOW=$(date +"%Y-%m-%d")
DAY=$(date +"%u")

#Name of the host
# you can also hos HOST ="Custom Name" instead of direct hostname
HOST="$(hostname)"

##Lets start the tar##
##Plan to include other options for the next release##
TAR=$(which tar)
if [ -z "$TAR" ]; then
    echo "$NOW : Error: tar not found" >> $LOGFILE
    exit 1
fi
CP="$(which cp)"
if [ -z "$CP" ]; then
    echo "$NOW : Error: CP not found" >> $LOGFILE
    exit 1
fi

### Start Backup for file system ###
[ ! -d $BACKUPDIR ] && mkdir -p $BACKUPDIR || :
[ ! -d $LATEST ] && mkdir -p $LATEST || :

if [ $DAY -eq $FULLBACKUP ]; then
  FILE="$HOST-full_$NOW.tar.gz"
  $TAR -zcPf $BACKUPDIR/$FILE -C / $DIRS
  $CP $BACKUPDIR/$FILE "$LATEST/$HOST-full_latest.tar.gz"
  echo "$NOW : Action: Full backup done" >> $LOGFILE
else
  FILE="$HOST-incremental_$NOW.tar.gz"
  $TAR -g $INCFILE -zcPf $BACKUPDIR/$FILE -C / $DIRS
  $CP $BACKUPDIR/$FILE "$LATEST/$HOST-incremental_latest_$DAY.tar.gz"
  echo "$NOW : Action: Incremental backup done" >> $LOGFILE
fi

# Remove files older than x days if cleanup is activated
if [ HOUSEKEEP == 1 ]; then
    find $BACKUPDIR/ -name "*.gz" -type f -mtime +$OLDERTHAN -delete
fi


