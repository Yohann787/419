#!/bin/bash

# Chemin vers le fichier à sauvegarder
SOURCE="Desktop/Script/backup_daily.sh"
# Répertoire où sauvegarder les fichiers
BACKUP_DIR="Desktop/Backups"

# Sauvegarde quotidienne
DAILY_BACKUP_NAME="dailybackup_$(date +\%F).txt"

# Sauvegarde quotidienne (toujours)
cp "$SOURCE" "$BACKUP_DIR/$DAILY_BACKUP_NAME"
