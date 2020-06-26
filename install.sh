#!/usr/bin/env bash

##################################################
#                                                #
#        Scala Automatic Installation Tool       #
#                                                #
#           Copyright © Joshua Quinlan           #
#                                                #
##################################################

# Enable testing mode - 'yes' or 'no'
TESTING='no'

# Text colour variables
COL_GREEN='\033[0;32m'    # Green
COL_RED='\033[0;31m'      # Red
COL_BLUE="\x1b[34;01m"    # Blue
COL_YELLOW="\033[0;33m"   # Yellow
COL_RESET='\033[0m'       # Reset

COLUMNS=$(tput cols) 
testingDisclaimer="-- TEST MODE IS ENABLED --"
title="Scala Automatic Installation Tool" 

function header {
    clear
    echo -e ""
    if [[ $TESTING == 'yes' ]]; then
        printf ${COL_RED}"%*s\n" $(((${#testingDisclaimer}+$COLUMNS)/2)) "$testingDisclaimer"
        echo -e ""
    fi
    printf ${COL_BLUE}"%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
    printf ${COL_GREEN}"%*s\n" $(((${#stage}+$COLUMNS)/2)) "$stage"
    echo -e ""
    echo -e ""${COL_RESET}
}

stage="Instructions"
header

echo -e "Welcome to the Scala Automatic Installation Tool by Joshua Quinlan"
echo -e "-------------------------------------------------------------------"
echo -e "The installation process is ${COL_GREEN}very simple${COL_RESET}, and mostly automated. There are points where you may be required to interact with the program - these are highlighted in ${COL_YELLOW}yellow${COL_RESET}."
echo -e ""
echo -e ""
echo -e ""${COL_YELLOW}
read -p "  >>>    Are you ready to begin? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 

stage="Stage 1"
header

# --------------------------------------------------------------------------------
# Temp Workspace Setup

echo -e ${COL_BLUE}"[INFO] Getting your system ready..."${COL_RESET}

sudo mkdir /tmp/scala-install/

if [ ! -d /tmp/scala-install ]; then
    echo -e ${COL_RED}"[FATAL] Workspace setup failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] Workspace setup successful."${COL_RESET}

cd /tmp/scala-install/

# --------------------------------------------------------------------------------
# Homebrew Setup

brew_installed=$(which brew)

if [[ $brew_installed != "/usr/local/bin/brew" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

wget_installed=$(brew list | grep 'wget')

if [[ $wget_installed != 'wget' ]]; then
    brew install wget
fi

# --------------------------------------------------------------------------------
# X11 Setup

stage="Stage 2"
header

echo -e ${COL_BLUE}"[INFO] Downloading X11 Server"${COL_RESET}

sudo wget -P ~/Downloads/ https://dl.bintray.com/xquartz/downloads/XQuartz-2.7.11.dmg -q

if [ ! -f ~/Downloads/XQuartz-2.7.11.dmg ]; then
    echo -e ${COL_RED}"[FATAL] X11 Server download failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] X11 Server downloaded successfully."${COL_RESET}

echo -e ${COL_BLUE}"[INFO] Installing X11 Server"${COL_RESET}
echo -e ${COL_RED}"THIS COULD TAKE A WHILE! DO NOT RESTART YOUR COMPUTER..."${COL_RESET}

sudo hdiutil attach ~/Downloads/XQuartz-2.7.11.dmg -quiet

sudo cp -R /Volumes/XQuartz-2.7.11/XQuartz.pkg /tmp/scala-install/XQuartz.pkg

if [[ $TESTING != 'yes' ]]; then
    sudo installer -pkg "/tmp/scala-install/XQuartz.pkg" -target /
fi

sudo hdiutil detach /Volumes/XQuartz-2.7.11 -quiet

XQuartz_Exists=$(ls /Applications/Utilities/ | grep 'XQuartz.app')

if [ $XQuartz_Exists != "XQuartz.app" ]; then
    echo -e ${COL_RED}"[FATAL] X11 Server installation failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] X11 Server installed successfully."${COL_RESET}

# --------------------------------------------------------------------------------
# MacPorts Setup

stage="Stage 3"
header

echo -e ${COL_BLUE}"[INFO] Downloading MacPorts"${COL_RESET}

sudo wget -P ~/Downloads/ https://github.com/macports/macports-base/releases/download/v2.5.4/MacPorts-2.5.4-10.14-Mojave.pkg -q

if [ ! -f ~/Downloads/MacPorts-2.5.4-10.14-Mojave.pkg ]; then
    echo -e ${COL_RED}"[FATAL] MacPorts download failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] MacPorts downloaded successfully."${COL_RESET}

echo -e ${COL_BLUE}"[INFO] Installing MacPorts"${COL_RESET}

if [[ $TESTING != 'yes' ]]; then
    sudo installer -pkg "~/Downloads/MacPorts-2.5.4-10.14-Mojave.pkg" -target /
fi

MacPorts_Exists=$(ls /Applications/ | grep 'MacPorts')

if [ $MacPorts_Exists != "MacPorts" ]; then
    echo -e ${COL_RED}"[FATAL] MacPorts installation failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] MacPorts installed successfully."${COL_RESET}

echo -e ${COL_BLUE}"[INFO] Installing Ports"${COL_RESET}

sudo port install -q gtk2

sudo port install -q gnuplot

gtk2_Exists=$(port echo active | grep 'gtk2')

if [[ $gtk2_Exists == "" ]]; then
    echo -e ${COL_RED}"[FATAL] Ports installation failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] Ports installed successfully."${COL_RESET}

# --------------------------------------------------------------------------------
# Scala Setup

stage="Stage 4"
header

echo -e ${COL_BLUE}"[INFO] Downloading Scala"${COL_RESET}

sudo wget -P ~/Downloads/ https://www.joshuaquinlan.co.uk/Scala_Setup.app.zip -q

if [ ! -f ~/Downloads/Scala_Setup.app.zip ]; then
    echo -e ${COL_RED}"[FATAL] Scala download failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] Scala downloaded successfully."${COL_RESET}

echo -e ${COL_BLUE}"[INFO] Opening Scala setup tool..."${COL_RESET}

sudo unzip -q ~/Downloads/Scala_Setup.app.zip -d ~/Downloads/

sudo spctl --master-disable

sudo open ~/Downloads/Scala_Setup.app

echo -e ""
echo -e ""
echo -e ""${COL_YELLOW}

read -p "  >>>    Has Scala Setup finished? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 

echo -e ${COL_RESET}""
Scala_Exists=$(ls /Applications/ | grep 'Scala.app')

if [[ $Scala_Exists == "" ]]; then
    echo -e ${COL_RED}"[FATAL] Scala install failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] Scala installed successfully."${COL_RESET}

# --------------------------------------------------------------------------------
# SimpleSynth Setup

stage="Stage 5"
header

echo -e ${COL_BLUE}"[INFO] Downloading SimpleSynth"${COL_RESET}

sudo wget -P ~/Downloads/ https://joshuaquinlan.co.uk/SimpleSynth-1.1.zip -q

if [ ! -f ~/Downloads/SimpleSynth-1.1.zip ]; then
    echo -e ${COL_RED}"[FATAL] SimpleSynth download failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] SimpleSynth downloaded successfully."${COL_RESET}

echo -e ${COL_BLUE}"[INFO] Installing SimpleSynth"${COL_RESET}

sudo unzip -q ~/Downloads/SimpleSynth-1.1.zip ~/Downloads/

sudo cp ~/Downloads/SimpleSynth.app /Applications/SimpleSynth.app

SimpleSynth_Exists=$(ls /Applications/ | grep 'SimpleSynth.app')

if [[ $SimpleSynth_Exists == "" ]]; then
    echo -e ${COL_RED}"[FATAL] SimpleSynth install failed. Terminating..."${COL_RESET}
    exit
fi

echo -e ${COL_GREEN}"[SUCCESS] SimpleSynth installed successfully."${COL_RESET}

# --------------------------------------------------------------------------------
# Temp workspace cleanup

stage="Stage 6"
header

echo -e ${COL_BLUE}"[INFO] Cleaning up workspace..."${COL_RESET}

files=( /tmp/scala-install/ ~/Downloads/__MACOSX ~/Downloads/MacPorts-2.5.4-10.14-Mojave.pkg ~/Downloads/Scala_Setup.app ~/Downloads/Scala_Setup.app.zip ~/Downloads/SimpleSynth-1.1.zip ~/Downloads/XQuartz-2.7.11.dmg )

for i in ${files[@]}; do
    sudo rm -rf $i

    if [ -d $i ]; then
        echo -e ${COL_RED}"[FATAL] Workspace cleanup failed. Terminating..."${COL_RESET}
        exit
    fi
done

echo -e ${COL_GREEN}"[SUCCESS] Workspace cleaned up successfully."${COL_RESET}

# --------------------------------------------------------------------------------
# Confirmation screen

stage="Complete"
header

echo -e ${COL_GREEN}"SCALA HAS BEEN INSTALLED SUCCESSFULLY"${COL_RESET}
echo -e ""
echo -e "To start using Scala:"
echo -e "1. Open SimpleSynth, either through Launchpad or your Applications folder"
echo -e "2. Open Scala, either through Launchpad or your Applications folder"
echo -e ""
echo -e "Thank you for using Joshua Quinlan's Scala Automatic Installation Tool."
echo -e "If you have any questions or require assistance, email me@JoshuaQuinlan.co.uk"
echo -e ""
