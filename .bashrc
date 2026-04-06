


alias cl='clear'
alias gs='git status'
alias gc='git commmit'
alias vi='vim'
alias l='ls -l'
alias ls='ls --color=auto'


# Function to get current git branch
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ -n "$PS1" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '
fi
cd 
