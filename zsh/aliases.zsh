ZSH_DOTFILE_DIR=$HOME/dotfiles/zsh
EDITOR_TEXTMATE=/usr/bin/mate
EDITOR_MVIM=/usr/local/bin/mvim
EDITOR=$EDITOR_MVIM

LAUNCHCTL_DIR=$HOME/Library/LaunchAgents

alias matedot="mate $HOME/dotfiles"
alias refcard="open ~/Dropbox/Programming/zsh_refcard.pdf"
alias relaliases=". $ZSH_DOTFILE_DIR/aliases.zsh"
alias pbcopy="tr -d '\n' | /usr/bin/pbcopy"

# alias delete_empty_dirs="rm -d **/*(/^F)"
alias bigdirs="du -k | sort -n | tail -15"

alias today="date +%Y-%m-%d"
alias now="date +%Y-%m-%d_%H%M%S"
alias utctime='date -u +%Y-%m-%d\ %H:%M:%S'

alias start-redis="/opt/local/bin/redis-server/redis-server /opt/local/etc/redis.conf"
alias start-postgres="sudo su postgres -c '/opt/local/lib/postgresql91/bin/initdb -D /opt/local/var/db/postgresql91/defaultdb'"
alias open_ports="lsof -Pnl +M -i4 | grep LISTEN"
alias envvars="env | sort | egrep -v '^(COLORFGBG|COMMAND_MODE|DISPLAY|GREP_COLOR|GREP_OPTIONS|HOME|IRBRC|ITERM_PROFILE|ITERM_SESSION_ID|LANG|LC_CTYPE|LOGNAME|LSCOLORS|OLDPWD|PAGER|PATH|PWD|SHELL|SHLVL|SSH_AGENT_PID|SSH_AUTH_SOCK|TERM|TERM_PROGRAM|TMPDIR|USER|GEM_HOME|GEM_PATH|MY_RUBY_HOME|RUBY_VERSION)=' | egrep '^[A-Z]+[_=]'"

alias less="less -RS"

# Dev/Ruby aliases
alias rsp="rspec -cf nested"
alias plz='foreman run bundle exec '

# Labs stuff
# OKCL_DIR=$HOME/dev/OkCupid
SCRATCH_DIR=$HOME/dev/OkCupid/scratch
alias phxdir="pushd $HOME/dev/OkCupid/SinglesNet"
alias solr-start="solr /usr/local/Cellar/solr/4.0.0/libexec/phoenix/solr"

function delete_empty_dirs() {
  rm -rf $(du | awk '$1 == 0 {print $2}')
}

function gsga() {
  git stash save $* && git stash apply -q
}

function gittag() {
  tag=$1
  git tag -a "$tag" -m "Release version $tag" && git push --tags
}

function gitdeltag() {
  if (( $# != 1 )) ; then
    echo "Usage: gitdeltag <tagname>"
    return -1
  fi
  tag=$1
  git tag -d "$tag" && git push origin :refs/tags/$tag
}

alias last_deploy_tag="git tag -l 'production/*' | tail -1"
function diff_prod() {
  git fetch && git difftool $(last_deploy_tag) $(git_branch_name)
}

function t {
  if [[ "$1" = <-> ]] ; then
    local level=$1
    shift
  else
    local level="1"
  fi
  tree -C -L $level "$@"
}

function dotdot {
  if [[ "$1" = <-> ]] ; then
    local level=$1
  else
    local level="1"
  fi
  local tmppath=""
  for i in {1..$level} ; do tmppath="../$tmppath" ; done
  cd $tmppath
}
alias ..=dotdot

. $ZSH_DOTFILE_DIR/db_funcs.zsh
