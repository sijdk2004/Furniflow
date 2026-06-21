@echo off
echo ========================================================
echo Starting Furniflow POC Web Demo...
echo ========================================================
echo.
echo Launching local server...
start http://localhost:8000
python -m http.server 8000
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Python is not installed or not in PATH! 
    echo Please make sure Python is installed on your machine to run this demo.
    pause
)
