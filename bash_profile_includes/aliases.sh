function current_git_branch_bare {
    echo `git branch --no-color 2> /dev/null | perl -n -e 'next unless /^\s*\*\s*(?:.\d+.\s*)?(.*)/; print "$1"; exit;'`
}

alias ag='ag --ignore \*.json'

alias g=git
alias gd="git diff"
alias gds="git diff --staged"
alias gco="git checkout"
alias gc="git commit"
alias nerd="cd /srv/nerdwallet"
alias jan="cd /srv/nerdwallet/janitor"
alias gst="git stash"
alias gsl="git stash list"
alias gpr="git pull --rebase"
alias gmu="git fetch upstream && git merge --ff-only upstream/master"
alias gru="git fetch upstream && git rebase upstream/master"
alias gitprune="git remote prune origin"
alias gst="git about && echo && git status"
alias gfa="git fetch upstream && git fetch"
alias ff="git merge --ff-only origin/\$(current_git_branch_bare)"
alias fff="git fetch origin && git merge --ff-only origin/\$(current_git_branch_bare)"
alias ffu="git merge --ff-only upstream/\$(current_git_branch_bare)"
alias fffu="git fetch upstream && git merge --ff-only upstream/\$(current_git_branch_bare)"

alias ll="ls -lah"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias .........="cd ../../../../../../../.."
alias ..........="cd ../../../../../../../../.."

alias ls="ls -p --color"
# alias vi='vi -u /usr/share/vim/vimrc'
alias act="source venv/bin/activate"
