#!/bin/bash

SOURCE="Desktop/Script/backup_daily.sh"
BACKUP_DIR="Desktop/Backups"

DAILY_BACKUP_NAME="dailybackup_$(date +\%F).txt"

cp "$SOURCE" "$BACKUP_DIR/$DAILY_BACKUP_NAME"
