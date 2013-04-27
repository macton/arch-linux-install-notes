# ~/.bashrc for ArchLinux userspace
# Thanks https://gist.github.com/4432429 for git-based prompt
 
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
 
if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc   # --> Read /etc/bash.bashrc, if present.
fi
 
# Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  c_reset='\[\e[0m\]'
  c_user='\[\e[1;33m\]'
  c_path='\[\e[0;33m\]'
  c_git_cleancleann='\[\e[0;36m\]'
  c_git_dirty='\[\e[0;35m\]'
else
  c_reset=
  c_user=
  c_git_cleancleann_path=
  c_git_clean=
  c_git_dirty=
fi
# Function to assemble the Git parsingart of our prompt.
git_prompt ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
  return 0
  fi
  git_branch=$(git branch 2>/dev/null | sed -n '/^\*/s/^\* //p')
  if git diff --quiet 2>/dev/null >&2; then
  git_color="$c_git_clean"
  else
  git_color="$c_git_dirty"
  fi
  echo "[$git_color$git_branch${c_reset}]"
}
# Thy holy prompt.
PROMPT_COMMAND='PS1="${c_user}\u${c_reset}@${c_user}\h${c_reset}:${c_path}\w${c_reset}$(git_prompt)\$ "'

export TERM=xterm
export PATH=$PATH:$HOME/bin
alias ls='ls --color=auto'
clear
