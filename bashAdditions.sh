# ========== Variables ==========
color_prompt=yes

# ========== Functions ==========

function gitSetUpAlias
{
	git config --global color.ui auto
	#git config --global alias.co checkout
	#git config --global alias.ci commit
	#git config --global alias.df diff
	#git config --global alias.duff diff
	#git config --global alias.st status
	#git config --global alias.s status
	#git config --global alias.t status
	#git config --global alias.br branch
	#git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
	#git config --global alias.type 'cat-file -t'
	#git config --global alias.dump 'cat-file -p'
	#git config --global alias.undo 'reset --soft HEAD^'
	echo "Git alias Done"
}

function greeting 
{
	echo -e
	h=`date +%H`
	if [ $h -lt 2 ]
	then
	    echo "Good night $USER"
	elif [ $h -lt 6 ]
	then
	    echo "You should go to bed..."
	elif [ $h -lt 12 ]
	then
	    echo "Good morning $USER"
	elif [ $h -lt 18 ]
	then
	    echo "Good afternoon $USER"
	else
	    echo "Good evening $USER"
	fi
}

# ========== Aliases ==========
#ls
#alias ls='ls --color=never'
alias ll='ls -l'
alias cls='ls --color=always'
alias cll='cls -l'
alias sl='ls'
alias s='ls'
alias l='ls'

#git
#alias gs='git status '
#alias ga='git add '
#alias gb='git branch '
#alias gc='git commit'
#alias gd='git diff'
#alias go='git checkout '
#alias gp='git push '
#alias got='echo '\''-- -- Tape 'git' ! -- --'\'' && git'
#alias gut='got'

#cd
alias c='cd'
alias cd.='cd ../'
alias cd..='cd ../../'
alias cd...='cd ../../../'
alias cd....='cd ../../../../'
alias cd.....='cd ../../../../../'
alias cd......='cd ../../../../../../'
alias home="cd $HOME"
alias ..='cd ..'
#alias www='cd /var/www'
#alias log='cd /var/log'
#alias logs='log'

#admin sys
alias ports='netstat -tulanp'
alias ping5='ping -c 5'
alias fastping='ping -c 100 -s.2'
alias psmem='ps auxf | sort -nr -k 4' #get top process eating memory
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3' #get top process eating cpu
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias size10='du -sk * | sort -rn | head -10'
alias size10r='du -Sh | sort -hr | head -10'

#bash addition
alias bashupdate='bash <(curl -Ls https://goo.gl/wA12tf)'
alias updatebash='bashupdate'
alias promptupdate='bashupdate'
alias updateprompt='bashupdate'
alias bashinstall='bashupdate'
alias installbash='bashupdate'
alias bashremove='bash <(curl -Ls https://goo.gl/9fb5eV)'
alias removebash='bashremove'
alias removeprompt='bashremove'
alias promptremove='bashremove'

#security
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
#alias rm='rm -i --preserve-root'

#rm tmp
alias rmo='rm *.o'
alias rmt='rm *~'
alias rmot='rmo;rmt'
alias rmto='rmot'

#others
alias cls='clear'
alias dodo='kill -9 -1'
#alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias cgrep='grep --color=auto'
alias webshare='python -m SimpleHTTPServer'

# Tools function for key generations
function generateSSHKey
{
	fileName="sshKey"
	keyName=$fileName

	local OPTIND
	while getopts ":n: :f: :h" option
	do
		case $option in
			n)
				keyName=$OPTARG
				;;
			f)
				fileName=$OPTARG
				;;
			h)
				echo -e "Commands arguments help :"
				echo -e "-h : Show help"
				echo -e "-f : SSH key file names"
				echo -e "-n : SSH key names"
				return 0
				;;
			# Missing argument for option
			:)
				echo -e "Option \"${OPTARG}\" require argument"
				return 1
				;;
			# Inexistant option
			\?)
				echo -e "Invalid option \"${OPTARG}\""
				return 1
				;;
		esac
	done
	
	mkdir -p $HOME/.ssh

	# Generate key
	ssh-keygen -t rsa -C $keyName -b 4096 -f $HOME/.ssh/$fileName
	
	echo -e "The public key is :\n" 
	cat $HOME/.ssh/${fileName}.pub
}

function generateKey
{
	keyName="sshKey"

	# Check if there are args
	if [ $# -gt 0 ]
	then
		keyName=$1
	fi

	mkdir -p $HOME/.ssh

	# Generate key
	openssl genrsa -des3 -out ${keyName}private.pem 2048
	
	echo -e "Now generating public key :\n"
	openssl rsa -in ${keyName}private.pem -outform PEM -pubout -out ${keyName}public.pem

	# Move key
	mv ${keyName}private.pem $HOME/.ssh
	
	echo -e "The public key is :\n" 
	cat ${keyName}public.pem
}

# ========== Shell options ==========
if test `echo $BASH_VERSION | grep "^[3-9].*"`
then
	# bash version > 3.0, enable some options
	shopt -s cdspell
fi
if test `echo $BASH_VERSION | grep "^[4-9].*"`
then
        # bash version > 4.0, enable some options
        shopt -s autocd
        shopt -s dirspell
fi
if test `echo $BASH_VERSION | grep "^[4-9]\.[2-9].*"`
then
	# bash version > 4.2, enable some options
	shopt -s direxpand
fi

# ========== Prompt ==========
# Add git branch if its present to PS1
# Not used for the moment
parse_git_branch() 
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# Color prompt
if [ "$color_prompt" = yes ]
then
	PS1="\n\[\e[30;1m\](\[\e[0m\]\`if [[ \$? == 0 ]]; then echo \"\[\e[32m\]^_^\[\e[0m\]\"; else echo \"\[\e[31m\]O_O\[\e[0m\]\"; fi\`\[\e[30;1m\])-\[\e[30;1m\](\[\e[34;1m\]\u@\h\[\e[30;1m\])-(\[\e[34;1m\]\j\[\e[30;1m\])\n(\[\e[32;1m\]\w\[\e[30;1m\])-> \[\e[0m\]"
fi

# ========== Read file for your personnal modification ==========
PersonalAddition="$HOME/.bash_personnal_addition"
if test -f $PersonalAddition
then
    source $PersonalAddition
fi

