#!/bin/bash

#------------- Configure
# Make changes here to adapt to your needs

# If you want to back up the contents of $source (and not the directory itself),
# there must be a trailing slash
source=$HOME/
# The path of the backup directories is this prefix plus the timestamp
backup_prefix=/Volumes/eGoHD/backup/rauschma

# --archive   preserve almost anything (user, group etc.)
# --recursive   copy directories recursively
# --compress   data during transit
# --delete   files that don't exist on sender
# --extended-attributes   copy extended attributes, resource forks (Mac OS X)
# -v   verbose (use twice for extra verbosity)
# --progress   is shown during transfer
# --partial   keep partially transferred files

options="--rsh=ssh --archive --recursive --compress --delete --extended-attributes -v --progress --partial"

# What files should not be backed up?
excludes='--exclude=.DS_Store --exclude=/.Trash --exclude=/Library/Caches'

#------------- Parse arguments

# optional argument: restart with the given timestamp
if [ $# = 1 ]; then
	timestamp=$1
	echo "Resume backup $timestamp"
else
	timestamp=`date "+%Y-%m-%d_%H-%M"`
	echo "New backup: $timestamp"
fi

#------------- Perform the backup

# Is there a current backup?
if [ -h ${backup_prefix}_current ]; then
	echo "Incremental backup"
	# --link-dest=DIR   hardlink to files in DIR when unchanged
	linkdest="--link-dest=${backup_prefix}_current"
else
	echo "Full backup"
	linkdest=""
fi

echo "rsync $options $excludes $linkdest $source ${backup_prefix}_${timestamp}"
rsync $options $excludes $linkdest $source ${backup_prefix}_${timestamp}

if [ -h ${backup_prefix}_current ]; then
	rm ${backup_prefix}_current
fi
ln -s ${backup_prefix}_${timestamp} ${backup_prefix}_current
