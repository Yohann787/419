#!/bin/bash

# Chemin vers le fichier à sauvegarder
SOURCE="/chemin/vers/ton/fichier.txt"
# Répertoire où sauvegarder les fichiers
BACKUP_DIR="/chemin/vers/backup"

# Backup quotidien
DAILY_BACKUP_NAME="dailybackup_$(date +\%F).txt"

# Sauvegarde quotidienne (toujours)
cp "$SOURCE" "$BACKUP_DIR/$DAILY_BACKUP_NAME"

# Vérifier si aujourd'hui c'est le 28 du mois pour le backup mensuel
if [ "$(date +\%d)" -eq 28 ]; then
    MONTHLY_BACKUP_NAME="monthlybackup_$(date +\%F).txt"
    cp "$SOURCE" "$BACKUP_DIR/$MONTHLY_BACKUP_NAME"
fi
