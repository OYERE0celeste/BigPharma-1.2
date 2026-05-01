# MongoDB Backup Script for BigPharma
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BACKUP_DIR = "./backups/db_$DATE"
$MONGO_URI = "mongodb://localhost:27017/bigpharma" # Update with your URI

Write-Host "Starting database backup..." -ForegroundColor Green

# Create backup directory
New-Item -ItemType Directory -Force -Path $BACKUP_DIR

# Run mongodump
& mongodump --uri=$MONGO_URI --out=$BACKUP_DIR

if ($LASTEXITCODE -eq 0) {
    Write-Host "Backup completed successfully at $BACKUP_DIR" -ForegroundColor Green
} else {
    Write-Host "Backup failed!" -ForegroundColor Red
}
