# MongoDB Restore Script for BigPharma
param (
    [Parameter(Mandatory=$true)]
    [string]$BackupPath
)

$MONGO_URI = "mongodb://localhost:27017/bigpharma"

Write-Host "Restoring database from $BackupPath..." -ForegroundColor Yellow

# Run mongorestore
& mongorestore --uri=$MONGO_URI --drop $BackupPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Database restored successfully!" -ForegroundColor Green
} else {
    Write-Host "Restore failed!" -ForegroundColor Red
}
