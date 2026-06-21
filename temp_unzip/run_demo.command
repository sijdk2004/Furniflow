#!/bin/bash
echo "========================================================"
echo "Starting Furniflow POC Web Demo on Mac..."
echo "========================================================"
echo ""
echo "Launching local server..."
sleep 1 && open "http://localhost:8000" &
python3 -m http.server 8000
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Python 3 is not installed or not in PATH!"
    echo "Please make sure Python 3 is installed on your Mac."
    read -p "Press [Enter] to exit..."
fi
