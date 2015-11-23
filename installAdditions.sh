#!/bin/bash

User=`whoami`
Bashrc=".bashrc"
BashrcBKP=".bashrc.backup"
BashrcAddition=".bash_addition"
PathBashrc=$HOME"/"$Bashrc
PathBashrcBKP=$HOME"/"$BashrcBKP
PathBashrcAddition=$HOME"/"$BashrcAddition
nbErrors=0

MarkerBegin="#BashRcAdditionByKernelith"
MarkerEnd="#End_of_BashRcAdditionByKernelith"
BashAdditionScriptURL='https://goo.gl/XNYlYQ'

function downloadBashAddition
{
	curl -sL $BashAdditionScriptURL > $PathBashrcAddition
}

function installBashAddition
{
	echo "Installation Begin."
	echo "	Save '$Bashrc'"
	cp $PathBashrc $PathBashrcBKP
	# mod .bashrc
	echo "	Modding '$Bashrc'"
	echo -e >> $PathBashrc
	echo $MarkerBegin >> $PathBashrc
	echo "if test -f $PathBashrcAddition ; then" >> $PathBashrc
	echo "    source $PathBashrcAddition" >> $PathBashrc
	echo "fi" >> $PathBashrc
	echo $MarkerEnd >> $PathBashrc
	echo "	Creating '$BashrcAddition'"
	# create .bash_addition
	downloadBashAddition
}

function updateBashAddition 
{
	# if .bash_addition exists -> move it to check if there is update later
	if test -f $PathBashrcAddition
	then
		mv $PathBashrcAddition ${PathBashrcAddition}.bak
	fi
	downloadBashAddition
	if test -f ${PathBashrcAddition}.bak
	then
		# no modification
		if test `diff ${PathBashrcAddition} ${PathBashrcAddition}.bak|wc -l` -eq "0"
		then
			echo "Already up-to-date."
		else
			echo "Updating '$BashrcAddition'"
		fi
		rm ${PathBashrcAddition}.bak
	else
		echo "Downloading '$BashrcAddition'"
	fi
}

# show username
echo "User: $USER"

# .bashrc exists
if test -f $PathBashrc
then
	# if script already setted up
	if grep "$MarkerBegin" $PathBashrc >/dev/null
	then
		updateBashAddition
	else
		installBashAddition
	fi
else
	echo ".bashrc doesn't exist"
	nbErrors=1
fi

if test $nbErrors -eq 0
then
	echo "Succeed!"
else
	echo "[ERROR] An error occured during the process."
fi

exit $nbErrors

