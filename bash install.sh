#!/bin/bash

# Clear screen
clear

# Banner
echo -e "\e[1;32m"
echo "  ███████╗██╗   ██╗███╗   ███╗    ██████╗  ██████╗ ████████╗"
echo "  ██╔════╝██║   ██║████╗ ████║    ██╔══██╗██╔═══██╗╚══██╔══╝"
echo "  ███████╗██║   ██║██╔████╔██║    ██████╔╝██║   ██║   ██║   "
echo "  ╚════██║╚██╗ ██╔╝██║╚██╔╝██║    ██╔══██╗██║   ██║   ██║   "
echo "  ███████║ ╚████╔╝ ██║ ╚═╝ ██║    ██████╔╝╚██████╔╝   ██║   "
echo "  ╚══════╝  ╚═══╝  ╚═╝     ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   "
echo -e "\e[0m"
echo -e "\e[1;36m          SVM BOT - ALL LATEST VERSION"
echo -e "          Fully Made By ANKITCODER\e[0m"
echo ""
echo "======================================================"
echo ""

# ==================== AUTO DETECT & CLEAN ====================
if [ -f "current_version.txt" ]; then
    OLD_VERSION=$(cat current_version.txt)
    echo -e "\e[1;33m[1/7] Previous Version Detected: $OLD_VERSION\e[0m"
    echo "Removing old version files..."
    
    rm -rf "$OLD_VERSION" 2>/dev/null
    rm -rf SVM-V* 2>/dev/null
    rm -f current_version.txt 2>/dev/null
    rm -f SVM-V*.zip 2>/dev/null
    
    echo -e "\e[1;32m[✓] Old version cleaned successfully!\e[0m"
    echo ""
    sleep 1
else
    echo -e "\e[1;36m[1/7] No previous version found. Fresh install.\e[0m"
    echo ""
fi
# =============================================================

# Menu
echo -e "\e[1;36m[2/7] Select Version:\e[0m"
echo "1) SVM-V12.2"
echo "2) SVM-V12.3"
echo "3) SVM-V13"
echo "4) SVM-V13.2"
echo ""
read -p "Enter Number (1-4): " choice

case $choice in
    1)
        FILE="SVM-V12.2.zip"
        FOLDER="SVM-V12.2"
        ;;
    2)
        FILE="SVM-V12.3.zip"
        FOLDER="SVM-V12.3"
        ;;
    3)
        FILE="SVM-V13.zip"
        FOLDER="SVM-V13"
        ;;
    4)
        FILE="SVM-V13.2.zip"
        FOLDER="SVM-V13.2"
        ;;
    *)
        echo -e "\e[1;31mInvalid choice! Exiting...\e[0m"
        exit 1
        ;;
esac

echo ""
echo -e "\e[1;32m[✓] You selected: $FILE\e[0m"
echo ""

# Update & Install required tools
echo -e "\e[1;36m[3/7] Updating system & installing required tools...\e[0m"
apt update -y
apt install unzip wget -y
echo -e "\e[1;32m[✓] Tools installed successfully!\e[0m"
echo ""

# Download zip from GitHub
echo -e "\e[1;36m[4/7] Downloading $FILE from GitHub...\e[0m"
wget -q --show-progress "https://github.com/AnkitKing7/Svm-v12-13latest-bot/raw/main/$FILE" -O "$FILE"

if [ ! -f "$FILE" ]; then
    echo -e "\e[1;31m[!] Download failed! Check internet connection.\e[0m"
    exit 1
fi
echo -e "\e[1;32m[✓] Download completed!\e[0m"
echo ""

# Create folder and unzip inside it
echo -e "\e[1;36m[5/7] Creating folder: $FOLDER\e[0m"
mkdir -p "$FOLDER"
echo -e "\e[1;32m[✓] Folder created!\e[0m"
echo ""

echo -e "\e[1;36m[6/7] Extracting files into $FOLDER...\e[0m"
unzip -o "$FILE" -d "$FOLDER"
echo -e "\e[1;32m[✓] Extraction completed!\e[0m"
echo ""

# Go inside folder and run install.sh
echo -e "\e[1;36m[7/7] Going inside $FOLDER and running install.sh...\e[0m"
if [ -d "$FOLDER" ]; then
    cd "$FOLDER"
    
    if [ -f "install.sh" ]; then
        echo -e "\e[1;32m[✓] install.sh found! Starting installation...\e[0m"
        echo "------------------------------------------------------"
        bash install.sh
        echo "------------------------------------------------------"
    else
        echo -e "\e[1;31m[!] install.sh not found inside folder!\e[0m"
        echo -e "\e[1;33mPlease run manually:\e[0m"
        echo "cd $FOLDER && bash install.sh"
    fi
else
    echo -e "\e[1;31m[!] Folder not found!\e[0m"
fi

# Save current version
cd ..
echo "$FOLDER" > current_version.txt

# Clean downloaded zip
rm -f "$FILE"

echo ""
echo -e "\e[1;32m======================================================"
echo "          INSTALLATION COMPLETED SUCCESSFULLY!"
echo "======================================================\e[0m"
echo ""
