#!/bin/bash

if [ $# -eq 1 ] 
then
	USB=$1
	USB_INSTALLER=$USB/SoftwareInstallers
	USB_MISCELLANEOUS=$USB/Miscellaneous
	backgroundName="background.png"
	logoName="kernelith.png"

	# Versions
	COMPILER_VERSION=6
	CMAKE_VERSION="3.7.2"
	SFML_VERSION="2.4.1"

	if [ $USB != "" ] && [ -d $USB ]
	then
		ADDITIONAL_APPS=""
		# Add repositories
		echo "Adding repositories..."
		# For Java
		sudo add-apt-repository ppa:webupd8team/java -y
		# For GCC
		sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
		# For Atom		
		sudo add-apt-repository ppa:webupd8team/atom -y
		# For Play on Linux (maybe not needed)
		#sudo add-apt-repository ppa:noobslab/apps -y

		# Update repos
		sudo apt-get update && sudo apt-get upgrade -y

		# Curl
		sudo DEBIAN_FRONTEND=noninteractive apt-get install curl -y

		# Set up terminal
		bash <(curl -Ls https://goo.gl/wA12tf)
		sudo apt-get install nautilus-open-terminal -y
		nautilus -q

		# Dependency for google chrome
		sudo apt-get install -y libappindicator1
		# Google Chrome
		if [[ $(getconf LONG_BIT) = "64" ]]
		then
			echo "64bit Detected" &&
			echo "Installing Google Chrome..." &&
			wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
			sudo dpkg -i google-chrome-stable_current_amd64.deb &&
			rm -f google-chrome-stable_current_amd64.deb
		else
			echo "32bit Detected" &&
			echo "Installing Google Chrome..." &&
			wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb &&
			sudo dpkg -i google-chrome-stable_current_i386.deb &&
			rm -f google-chrome-stable_current_i386.deb
		fi
		
		ADDITIONAL_APPS="${ADDITIONAL_APPS}, 'application://google-chrome.desktop'"
		
		# VLC:
		sudo apt-get install vlc -y

		# Dev
		# Compiler
		echo "Installing Compiler..."
		sudo apt-get install gcc-${COMPILER_VERSION} g++-${COMPILER_VERSION} -y
		sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${COMPILER_VERSION} 60 --slave /usr/bin/g++ g++ /usr/bin/g++-${COMPILER_VERSION}

		# Install folder for softwares		
		echo "Create installation folder for software installs"
		SOFTWARES_DIRECTORY="$HOME/Softwares"
		mkdir -p $SOFTWARES_DIRECTORY

		# Install CMake
		echo "Installing CMake..."
		tar -zxvf $USB_INSTALLER/cmake-${CMAKE_VERSION}.tar.gz -C $SOFTWARES_DIRECTORY # Extraction
		cd $SOFTWARES_DIRECTORY/cmake-${CMAKE_VERSION}
		./bootstrap && make && sudo make install && cd .. && rm -rf cmake-*

		echo "Installing Git features..."
		# Git
		sudo apt-get install git -y
		# Gource
		sudo apt-get install gource -y		
		# Config
		git config --global user.email "kernelith@live.fr"
		git config --global user.name "Alexandre Raberin"
		git config --global push.default simple

		echo "Installing dev. tools..."
		# Valgrind
		sudo apt-get install valgrind -y

		# Doxygen
		sudo apt-get install doxygen -y
		sudo apt-get install graphviz -y
		# HTML to PDF for Atom : Needed for plugin gfm-pdf
		sudo apt-get install wkhtmltopdf -y
		
		# SFML
		# Dependencies for SFML		
		sudo apt-get install libx11-dev -y
		sudo apt-get install libudev-dev -y
		sudo apt-get install libjpeg-dev -y
		sudo apt-get install libopenal-dev -y
		sudo apt-get install libvorbis-dev -y
		sudo apt-get install libflac-dev -y
		sudo apt-get install libfreetype6-dev -y
		sudo apt-get install libxrandr-dev -y
		# OpenGL
		sudo apt-get install libgl1-mesa-glx libgl1-mesa-dri libgl1-mesa-dev libglu1-mesa mesa-common-dev -y
		# Getting sources		
		wget https://www.sfml-dev.org/files/SFML-${SFML_VERSION}-sources.zip
		unzip -a SFML-${SFML_VERSION}-sources.zip
		cd SFML-${SFML_VERSION}
		mkdir build
		cd build
		cmake ..
		make && sudo make install && cd ../.. && rm -rf SFML-*

		# Wine for PlayOnLinux :
		sudo DEBIAN_FRONTEND=noninteractive apt-get install wine -y
		sudo apt-get install playonlinux -y

		# Java
		echo "Installing Java..."
		# Accept license non-iteractive
		echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
		sudo apt-get install -y oracle-java8-installer
		# Make sure Java 8 becomes default java
		sudo apt-get install -y oracle-java8-set-default

		# Atom
		echo "Installing Atom..."
		sudo apt install atom
		# Plugins
		# Git Flavoured Markdown to PDF
		apm install gfm-pdf
		# Open PDF
		apm install pdf-view
		# Syntaxic coloration for markdown
		apm install language-markdown
		
		# Installation de logiciels à partir de .deb
		#sudo dpkg -i $USB_INSTALLER/atom.deb
		#echo "installation Slack :"
		#sudo dpkg -i $USB_INSTALLER/slack-desktop-2.0.6-amd64.deb
		#echo "installation Virtualbox :"
		#sudo dpkg -i $USB_INSTALLER/virtualbox-5.0_5.0.16-105871-Debian-jessie_amd64.deb
		#echo "installation GanttProject"
		#sudo dpkg -i $USB_INSTALLER/ganttproject_2.7.1-r1924-1_all.deb
		#echo "installation PlayOnLinux"
		#sudo dpkg -i $USB_INSTALLER/PlayOnLinux_4.2.10.deb

		#echo "installation de Clion :"
		#tar -zxvf $USB_INSTALLER/CLion-2016.2.2.tar.gz -C $SOFTWARE_DIRECTORY
		#ADDITIONAL_APPS="${ADDITIONAL_APPS}, 'application://google-chrome.desktop'"
		#echo "installation de IntellIJ :"
		#tar -zxvf $USB_INSTALLER/ideaIU-2016.3.tar.gz -C $SOFTWARE_DIRECTORY
		#echo "installation de WebStorm :"
		#tar -zxvf $USB_INSTALLER/WebStorm-2016.2.4.tar.gz -C $SOFTWARE_DIRECTORY

		# Screen & render
		echo "Configure login screen..."
		# Login screen
		# Copy images
		cp $USB_MISCELLANEOUS/$backgroundName /usr/share/unity-greeting
		cp $USB_MISCELLANEOUS/$logoName /usr/share/unity-greeting
		# Settings		
		gsettings set com.canonical.unity-greeter draw-grid false
		gsettings set com.canonical.unity-greeter draw-user-backgrounds false
		gsettings set com.canonical.unity-greeter play-ready-sound false
		gsettings set com.canonical.unity-greeter background "/usr/share/unity-greeting/$backgroundName"
		gsettings set com.canonical.unity-greeter background-logo ""
		gsettings set com.canonical.unity-greeter logo "/usr/share/unity-greeting/$logoName"
		gsettings set com.canonical.Unity.Launcher favorites "['application://ubiquity.desktop', 'application://gnome-terminal.desktop', 'application://nautilus.desktop', 'application://firefox.desktop'${ADDITIONAL_APPS}, 'application://libreoffice-writer.desktop', 'application://unity-control-center.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
	else
		echo "Les chemin ne correspondent pas à des dossiers valides..."
	fi
else
	echo "Les arguments à donner sont le chemin vers le dossier contenant les fichiers d'installation"
fi
