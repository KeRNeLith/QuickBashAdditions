#!/bin/bash

# Script help
function printHelp
{
	echo -e "Commands arguments help :"
	echo -e "-h | --help : Show help"
	echo -e "-o | -on | -online | --online : Use images in online mode"
	echo -e "-f | -off | -of | -offline | --offline : Use images in offline mode"
	echo -e "-i | -input : Followed by directory where finding local resources for installation"
	echo -e "-s | -sfml | --sfml : If present add SFML to installation process"
	echo -e "-z | -sfmlV | --sfmlV : Followed by SFML version wanted"
	echo -e "-g | -gcc : Followed by GCC version wanted"
	echo -e "-w | -warning | -ssd : Perform a preliminary step to do thing to optimize SSD durability (Will need a reboot)"
}

# Parse command line args
# Transform long options to short ones
for arg in "$@"; do
	shift
	case "$arg" in
		"--help") 
			set -- "$@" "-h" 
			;;
		"-on"|"-online"|"--online") 
			set -- "$@" "-o" 
			;;
		"-off"|"-of"|"-offline"|"--offline") 
			set -- "$@" "-f" 
			;;
		"-input") 
			set -- "$@" "-i" 
			;;
		"-sfml"|"--sfml") 
			set -- "$@" "-s" 
			;;
		"-sfmlV"|"--sfmlV") 
			set -- "$@" "-z" 
			;;
		"-gcc") 
			set -- "$@" "-g" 
			;;
		"-warning"|"-ssd") 
			set -- "$@" "-w" 
			;;
		# Default
		*)        
			set -- "$@" "$arg"
	esac
done

# Default values
SFML_ENABLED=false
ONLINE_INSTALL=true
SSD_INSTALL=false

inputDirFlag=false
LOCAL_RESOURCES_FOLDER="."

# Versions
COMPILER_VERSION=6
CMAKE_VERSION="3.7.2"
SFML_VERSION="2.4.1"

# Parse options
while getopts ":o :f :h :i: :s :g: :z: :w" option
do
	case $option in
		o)
			ONLINE_INSTALL=true
			;;
		f)
			ONLINE_INSTALL=false
			;;
		i)
			inputDirFlag=true
			LOCAL_RESOURCES_FOLDER=$OPTARG
			;;
		s)
			SFML_ENABLED=true
			;;
		g)
			COMPILER_VERSION=$OPTARG
			;;
		z)
			SFML_VERSION=$OPTARG
			;;
		w)
			SSD_INSTALL=true
			;;
		h)
			printHelp
			exit 0
			;;
		# Missing argument for option
		:)
			echo -e "Option \"${OPTARG}\" require argument"
			exit 1
			;;
		# Inexistant option
		\?)
			echo -e "Invalid option \"${OPTARG}\""
			exit 1
			;;
	esac
done

# Treatments
# Perform preliminary step for SSD installs => Will need a reboot without SSD option to end installation
if [ $SSD_INSTALL = true ]
then
	# Check if TRIM is available
	sudo hdparm -I /dev/sda | grep TRIM

	if [ "$?" -eq 0 ]
	then
		# TRIM for SDD regularly to keep nice performances
		# sudo fstrim -v / 

		# Open cron as root to configure it
		echo "fstrim /" | sudo tee -a /etc/cron.weekly/fstrim
		
		# For exec cron
		sudo chmod +x /etc/cron.weekly/fstrim 
	fi

	# Move tmp files into RAM (Max 1Go)
	# Add to /etc/fstab
	echo "tmpfs      /tmp            tmpfs        defaults,size=1g           0    0" | sudo tee -a /etc/fstab

	# Log files into RAM
	# WARNING : No history kept between reboots
	# BUT : enhance SSD durability
	# tmpfs /var/log tmpfs defaults,nosuid,nodev,noatime,mode=0755,size=5% 0 0
	# OR put /var files on other hard drive
	# Change /var location at installation time

	# With system that have more that 6Go of RAM => move apt cache to RAM
	echo "tmpfs    /var/cache/apt/archives    tmpfs    defaults,size=4g    0    0" | sudo tee -a /etc/fstab
	# Clean apt cache
	sudo apt-get clean

	# Personal cache (to RAM)
	# WARNING can crash our session when moving this cache
	rm -rf $HOME/.cache
	echo "tmpfs    /home/$USER/.cache    tmpfs    defaults,size=1g    0    0" | sudo tee -a /etc/fstab

	# Firefox cache (WARNING MANUAL OPERATION)
	# Go to about:config
	# Create string browser.cache.disk.parent_directory set to /tmp

	# Other possible operations : 
	# 1 - Move /usr directory to gain space on SDD
	# See https://doc.ubuntu-fr.org/deplacer_repertoire_usr
	# 2 - Move /home
	# See https://doc.ubuntu-fr.org/tutoriel/deplacer_home
	# BUT consider moving it at installation time

	# Configure swap to be used only when remaining 5% of RAM
	# Add to /etc/sysctl.conf
	# vm.swappiness=5
	# OR
	# Use zRAM that compress RAM
	sudo apt-get install zram-config -y

	echo -e "Please Reboot computer..."
	
	# These operations require a reboot => End script => re-run without option for SSD
	exit 0
fi

# If local resources folder set
if [ $inputDirFlag = false ]
then 
	echo -e "Please provide a directory where finding local resources"
	exit 1
fi

# Set variables
INSTALLERS_DIR=$LOCAL_RESOURCES_FOLDER/SoftwareInstallers
MISCELLANEOUS_DIR=$LOCAL_RESOURCES_FOLDER/Miscellaneous
backgroundName="background.png"
logoName="kernelith.png"

if [ $LOCAL_RESOURCES_FOLDER != "" ] && [ -d $LOCAL_RESOURCES_FOLDER ]
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
	# Tools functions
	echo 'function changeLockScreen
	{
		backgroundName="background.png"
		DEST_PATH="/usr/share/unity-greeter"
		sudo cp $1 $DEST_PATH/$backgroundName
		gsettings set com.canonical.unity-greeter background $DEST_PATH/$backgroundName
	}
	alias updateLockScreen='"'"'changeLockScreen'"'"'
	alias lockScreenUpdate='"'"'changeLockScreen'"'" >> $HOME/.bash_personnal_addition
	
	echo 'function changeDesktopScreen
	{
		backgroundName="desktopBackground.png"
		DEST_PATH="/usr/share/unity-greeter"
		sudo cp $1 $DEST_PATH/$backgroundName
		gsettings set org.gnome.desktop.background picture-uri file://$DEST_PATH/$backgroundName
	}
	alias updateDesktopScreen='"'"'changeDesktopScreen'"'"'
	alias desktopScreenUpdate='"'"'changeDesktopScreen'"'" >> $HOME/.bash_personnal_addition
	source $HOME/.bashrc
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
	tar -zxvf $INSTALLERS_DIR/cmake-${CMAKE_VERSION}.tar.gz -C $SOFTWARES_DIRECTORY # Extraction
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
	if [ ${SFML_ENABLED} = true ]
	then
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
	fi

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
	
	ADDITIONAL_APPS="${ADDITIONAL_APPS}, 'application://atom.desktop'"
	
	# Softwares Installs
	# Jetbrains
	echo "Installing CLion..."
	tar -zxvf $INSTALLERS_DIR/CLion-*.tar.gz -C $SOFTWARES_DIRECTORY # Extraction
	cd $SOFTWARES_DIRECTORY/clion-*/bin
	echo 'export PATH=$PATH:'$PWD >> "$HOME/.bash_personnal_addition"
	source "$HOME/.bashrc"
	ADDITIONAL_APPS="${ADDITIONAL_APPS}, 'application://jetbrains-clion.desktop'"

	# Screen & render
	echo "Configure login screen..."
	# Login screen
	# Settings		
	gsettings set com.canonical.unity-greeter draw-grid false
	gsettings set com.canonical.unity-greeter draw-user-backgrounds false
	gsettings set com.canonical.unity-greeter play-ready-sound false
	gsettings set com.canonical.unity-greeter background-logo ""
	DEST_PATH="/usr/share/unity-greeter/"
	if [ ${ONLINE_INSTALL} = true ]
	then
		# Get images
		wget -O $backgroundName https://goo.gl/AezBJt
		wget -O $logoName https://goo.gl/Y14J5b
		sudo mv $backgroundName $DEST_PATH
		sudo mv $logoName $DEST_PATH
	else
		# Copy images
		sudo cp $MISCELLANEOUS_DIR/$backgroundName $DEST_PATH
		sudo cp $MISCELLANEOUS_DIR/$logoName $DEST_PATH
	fi
	gsettings set com.canonical.unity-greeter background "${DEST_PATH}$backgroundName"
	gsettings set com.canonical.unity-greeter logo "${DEST_PATH}$logoName"
	# Custom launcher bar
	gsettings set com.canonical.Unity.Launcher favorites "['application://ubiquity.desktop', 'application://gnome-terminal.desktop', 'application://nautilus.desktop', 'application://firefox.desktop'${ADDITIONAL_APPS}, 'application://libreoffice-writer.desktop', 'application://unity-control-center.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
else
	echo "Given path does not match a valid folder..."
fi