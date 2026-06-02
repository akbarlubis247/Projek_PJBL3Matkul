# ============================================
# Script: Fix PHP PATH - Switch XAMPP to Laragon PHP 8.5
# Run this as Administrator!
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Fix PHP System PATH" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current system PATH
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# Show current PHP entry
Write-Host "[BEFORE] PHP entries in PATH:" -ForegroundColor Yellow
$oldPath -split ';' | Where-Object { $_ -match "php|xampp|laragon" } | ForEach-Object { Write-Host "  $_" }
Write-Host ""

# Replace XAMPP with Laragon PHP 8.5
$newPath = $oldPath -replace [regex]::Escape("C:\xampp\php"), "C:\laragon\bin\php\php-8.5.5-nts-Win32-vs17-x64"

# Set the new PATH
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

# Verify
$verify = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
Write-Host "[AFTER] PHP entries in PATH:" -ForegroundColor Green
$verify -split ';' | Where-Object { $_ -match "php|xampp|laragon" } | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "Done! Close and reopen your terminal/VS Code for changes to take effect." -ForegroundColor Green
Write-Host ""
pause
