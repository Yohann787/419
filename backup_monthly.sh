#!/bin/bash


SOURCE="Desktop/Script/backup_monthly.txt"
BACKUP_DIR="Desktop/Backups"

if [ "$(date +\%d)" -eq 28 ]; then
    MONTHLY_BACKUP_NAME="monthlybackup_$(date +\%F).txt"
    cp "$SOURCE" "$BACKUP_DIR/$MONTHLY_BACKUP_NAME"
fi
