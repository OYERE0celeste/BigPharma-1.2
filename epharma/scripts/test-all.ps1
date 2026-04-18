$ErrorActionPreference = "Stop"

Write-Host "[1/2] Running API tests..."
Push-Location "api"
npm run test:api
Pop-Location

Write-Host "[2/2] Running Flutter tests..."
flutter test

Write-Host "All tests completed."
