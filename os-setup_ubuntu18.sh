#!/bin/bash

ROOT_DIR=$PWD

# Script help
function printHelp
{
	echo -e "Commands arguments help :"
	echo -e "-h | --help : Show help"
	echo -e "-o | -on | -online | --online : Use images in online mode"
	echo -e "-f | -off | -of | -offline | --offline : Use images in offline mode"
	echo -e "-i | -input : Followed by directory where finding local resources for installation"
	echo -e "-g | -gcc : Followed by GCC version wanted"
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
		"-gcc") 
			set -- "$@" "-g" 
			;;
		# Default
		*)        
			set -- "$@" "$arg"
	esac
done

# Default values
ONLINE_INSTALL=true

inputDirFlag=false
LOCAL_RESOURCES_FOLDER="."

# Versions
COMPILER_VERSION=8
CMAKE_VERSION="3.14.0"

# Parse options
while getopts ":o :f :h :i: :s :g: :z: :w: :c :j :k" option
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
		g)
			COMPILER_VERSION=$OPTARG
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
# If local resources folder set
if [ $inputDirFlag = false ]
then 
	echo -e "Please provide a directory where finding local resources"
	exit 1
fi

# Set variables
INSTALLERS_DIR=$LOCAL_RESOURCES_FOLDER/SoftwareInstallers
MISCELLANEOUS_DIR=$LOCAL_RESOURCES_FOLDER/Miscellaneous

if [ $LOCAL_RESOURCES_FOLDER != "" ] && [ -d $LOCAL_RESOURCES_FOLDER ]
then
	ADDITIONAL_APPS=""
	# Add repositories
	echo "Adding repositories..."

	# Update repos
	sudo apt-get update && sudo apt-get upgrade -y

	# Curl
	sudo DEBIAN_FRONTEND=noninteractive apt-get install curl -y

	# Set up terminal
	bash <(curl -Ls https://goo.gl/wA12tf)

	# Tools functions
	echo 'function changeLoginScreen
{
	backgroundName=$(basename "$1")
	DEST_PATH="/usr/share/backgrounds/"
	BACKGROUND_PATH="${DEST_PATH}login_${backgroundName}"
	UBUNTU_CSS_PATH="/usr/share/gnome-shell/theme/ubuntu.css"
	
	sudo cp $1 $BACKGROUND_PATH

	# Replace content with new background
	replaceContent="#lockDialogGroup {\n  background: #2c001e url(file://${BACKGROUND_PATH})\n  background-repeat: no-repeat;\n  background-size: cover;\n  background-position: center;\n}"

	# Escape slashes	
	replaceContent=$(echo $replaceContent | sed '"'"'s;/;\\/;g'"'"')

	# -0 sets the line separator to null
	# -p apply the script given by -e to each line and print that line
	# /s Treat string as single line
	sudo perl -i -p0e "s/#lockDialogGroup\s*{.*?}/${replaceContent}/s" ${UBUNTU_CSS_PATH}
}
alias updateLoginScreen='"'"'changeLoginScreen'"'"'
alias loginScreenUpdate='"'"'changeLoginScreen'"'" >> $HOME/.bash_personnal_addition
	
	echo 'function changeLockScreen
{
	backgroundName=$(basename "$1")
	DEST_PATH="/usr/share/backgrounds/"	
	BACKGROUND_PATH="${DEST_PATH}lock_${backgroundName}"
	sudo cp $1 $BACKGROUND_PATH
	gsettings set org.gnome.desktop.screensaver picture-uri "file://$BACKGROUND_PATH"
}
alias updateLockScreen='"'"'changeLockScreen'"'"'
alias desktopLockUpdate='"'"'changeLockScreen'"'" >> $HOME/.bash_personnal_addition

	echo 'function changeDesktopScreen
{
	backgroundName=$(basename "$1")
	DEST_PATH="/usr/share/backgrounds/"	
	BACKGROUND_PATH="${DEST_PATH}desktop_${backgroundName}"
	sudo cp $1 $BACKGROUND_PATH
	gsettings set org.gnome.desktop.background picture-uri "file://$BACKGROUND_PATH"
}
alias updateDesktopScreen='"'"'changeDesktopScreen'"'"'
alias desktopDesktopUpdate='"'"'changeDesktopScreen'"'" >> $HOME/.bash_personnal_addition
	
	# Reload bashrc
	source $HOME/.bashrc

	# Open in terminal inside explorer
	sudo apt-get install nautilus-extension-gnome-terminal  -y
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
	
	ADDITIONAL_APPS="${ADDITIONAL_APPS}, 'google-chrome.desktop'"
	
	# VLC:
	sudo apt-get install vlc -y

	# Dev
	# Compiler
	echo "Installing Compiler..."
	sudo apt-get install build-essential -y
	sudo apt-get install gcc-${COMPILER_VERSION} g++-${COMPILER_VERSION} -y
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${COMPILER_VERSION} 800 --slave /usr/bin/g++ g++ /usr/bin/g++-${COMPILER_VERSION}
	
	# Install folder for softwares		
	echo "Create installation folder for software installs"
	SOFTWARES_DIRECTORY="$HOME/Softwares"
	mkdir -p $SOFTWARES_DIRECTORY

	# Install CMake
	echo "Installing CMake..."
	sudo apt-get install cmake -y
	# OR Custom
	#tar -zxvf $INSTALLERS_DIR/cmake-${CMAKE_VERSION}.tar.gz -C $SOFTWARES_DIRECTORY # Extraction
	#cd $SOFTWARES_DIRECTORY/cmake-${CMAKE_VERSION}
	#./bootstrap && make && sudo make install && cd .. && rm -rf cmake-*
	#cd $ROOT_DIR	# Back to root

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

	# Softwares Installs
	# None...
	
	# Auto activate Num lock
	sudo -H -u gdm -s /bin/bash -c "dbus-launch gsettings set org.gnome.settings-daemon.peripherals.keyboard numlock-state 'on' & exit"

	# Screen & render
	echo "Configure login & lock screen..."
	# Lock/login screens
	backgroundName="background.png"
	loginName="login.png"
	ubuntuLogoName="ubuntu-logo.png"
	ubuntuLogo16Name="ubuntu-logo16.png"
	progressOnName="progress-dot-on.png"
	progressOn16Name="progress-dot-on16.png"
	progressOffName="progress-dot-off.png"
	progressOff16Name="progress-dot-off16.png"
	THEME_PATH="/usr/share/plymouth/themes/ubuntu-logo/"
	if [ ${ONLINE_INSTALL} = true ]
	then
		# Get images
		wget -O $backgroundName https://bit.ly/2V11Y4q
		changeLockScreen $backgroundName
		changeDesktopScreen $backgroundName
		rm -f $backgroundName
		
		wget -O $loginName https://bit.ly/2UYrO9m
		changeLoginScreen $loginName
		rm -f $loginName
		
		wget -O $ubuntuLogoName https://bit.ly/2WvaY2m
		wget -O $ubuntuLogo16Name https://bit.ly/2CF0CFu
		wget -O $progressOnName https://bit.ly/2FzGIwk
		wget -O $progressOn16Name https://bit.ly/2Oscnnv
		wget -O $progressOffName https://bit.ly/2uwcGnV
		wget -O $progressOff16Name https://bit.ly/2CDj9Sw
	else
		changeLockScreen $MISCELLANEOUS_DIR/$backgroundName
		changeDesktopScreen $MISCELLANEOUS_DIR/$backgroundName
		changeLoginScreen $MISCELLANEOUS_DIR/$loginName
		
		# Copy images
		cp $MISCELLANEOUS_DIR/$ubuntuLogoName $ubuntuLogoName
		cp $MISCELLANEOUS_DIR/$ubuntuLogo16Name $ubuntuLogo16Name
		cp $MISCELLANEOUS_DIR/$progressOnName $progressOnName
		cp $MISCELLANEOUS_DIR/$progressOn16Name $progressOn16Name
		cp $MISCELLANEOUS_DIR/$progressOffName $progressOffName
		cp $MISCELLANEOUS_DIR/$progressOff16Name $progressOff16Name
	fi
	
	# Backup
	sudo mv $THEME_PATH$ubuntuLogoName $THEME_PATH$ubuntuLogoName.bak
	sudo mv $THEME_PATH$ubuntuLogo16Name $THEME_PATH$ubuntuLogo16Name.bak
	sudo mv $THEME_PATH$progressOnName $THEME_PATH$progressOnName.bak
	sudo mv $THEME_PATH$progressOn16Name $THEME_PATH$progressOn16Name.bak
	sudo mv $THEME_PATH$progressOffName $THEME_PATH$progressOffName.bak
	sudo mv $THEME_PATH$progressOff16Name $THEME_PATH$progressOff16Name.bak
	
	sudo mv $ubuntuLogoName $THEME_PATH$ubuntuLogoName
	sudo mv $ubuntuLogo16Name $THEME_PATH$ubuntuLogo16Name
	sudo mv $progressOnName $THEME_PATH$progressOnName
	sudo mv $progressOn16Name $THEME_PATH$progressOn16Name
	sudo mv $progressOffName $THEME_PATH$progressOffName
	sudo mv $progressOff16Name $THEME_PATH$progressOff16Name

	# Custom launcher bar
	gsettings set org.gnome.shell favorite-apps "['ubiquity.desktop', 'gnome-terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox.desktop'${ADDITIONAL_APPS}, 'libreoffice-writer.desktop', 'org.gnome.gedit.desktop', 'update-manager.desktop', 'gnome-system-monitor_gnome-system-monitor.desktop', 'org.gnome.DiskUtility.desktop']"
else
	echo "Given path does not match a valid folder..."
fi
