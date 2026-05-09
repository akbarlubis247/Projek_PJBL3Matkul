@echo off
setlocal
cd /d "%~dp0"

if not exist "node_modules\.bin\concurrently.cmd" (
    echo Dependency frontend belum ada. Jalankan: npm.cmd install
    exit /b 1
)

node_modules\.bin\concurrently.cmd -c "#93c5fd,#fdba74" "php artisan serve" "node_modules\.bin\vite.cmd" --names=server,vite --kill-others
