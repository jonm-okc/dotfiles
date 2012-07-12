#-----------------------------------
# Source global definitions (if any)
#-----------------------------------

if [ -f /etc/bashrc ]; then
        . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi

DO_OUTPUT=1
function _output_msg()
{
	if [ $DO_OUTPUT == 1 ]; then
		echo "$*"
	fi
}

export DOTFILE_DIR=$HOME/dotfiles

#-------------------
# Other files to include
#-------------------
function dotfile-load()
{
	for filename in "$@"
	do
		local file=$DOTFILE_DIR/$filename
		if [ -f $file ]; then
			_output_msg "Loading $file"
			. $file
		else
			echo "$file does not exist"
		fi
	done	
}

# This prevents OSX from doing silly things with its extended attributes
export COPYFILE_DISABLE=true

DONT_INCLUDE=".git-completion.bash "
INCLUDE_DOT_FILES="prompt.bash aliases.bash set_path.bash complete.bash"
dotfile-load $INCLUDE_DOT_FILES

declare -x PAGER=less
declare -x EDITOR=vim
declare -x DO_OUTPUT=1
declare -x HISTCONTROL=erasedups
declare -x HISTIGNORE='??'
umask 002

alias rel-aliases="dotfile-load aliases.bash"
alias rel-pr="dotfile-load prompt.bash"

