#!/bin/bash

User=`whoami`
Bashrc=".bashrc"
BashrcBKP=".bashrc.backup"
BashrcBKP2=".bashrc.before_uninstall.backup"
BashrcAddition=".bash_addition"
PathBashrc=$HOME"/"$Bashrc
PathBashrcBKP=$HOME"/"$BashrcBKP
PathBashrcBKP2=$HOME"/"$BashrcBKP2
PathBashrcAddition=$HOME"/"$BashrcAddition
nbErrors=0

MarkerBegin="#BashRcAdditionByKernelith"

# show username
echo "User: $User"

# .bashrc exists
if test -f $PathBashrc
then
	echo "Found: '$Bashrc'"
	# detect installation script
	if grep "$MarkerBegin" $PathBashrc >/dev/null
	then
		# .bashrc.backup exists
		if test -f $PathBashrcBKP
		then
			echo "	Found: '$BashrcBKP'"
			# backup before restoring
			cp $PathBashrc $PathBashrcBKP2
			echo "		Restoring backup"
			cp $PathBashrcBKP $PathBashrc
		else
			echo "	Missing: '$BashrcBKP'"
			echo "		Do nothing."
		fi
	else
		echo "	No trace of installation in '$BASHRC'"
		echo "	Do nothing."
	fi
fi

# .bash_completion exists
if test -f $PathBashrcAddition
then
	echo "Found: '$BashrcAddition'"
	echo "	Remove '$BashrcAddition'"
	# remove .bash_completion
	rm $PathBashrcAddition
else
	# no .bash_completion
	echo "Missing: '$BashrcAddition'"
	echo "	Do nothing."
fi

if test $nbErrors -eq 0
then
	echo "Succeed!"
else
	echo "[ERROR] An error occured during the process."
fi

exit $nbErrors

