# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _correct _approximate _prefix
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'l:|=* r:|=*'
zstyle :compinstall filename '/home/jimbo/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

export PATH=~/bin:~/.cargo/bin:~/go/bin:$PATH:/usr/share/bcc/tools

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/vault vault

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

md() {
  mkdir -p $1 && cd $1
}

eval "$(zoxide init zsh)"

alias qmv="/usr/bin/qmv --format=destination-only"
alias dotfile="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME" 
alias vi=nvim
alias nvc="nvim ~/.config/nvim/"
alias zsc="nvim ~/.zshrc"
alias zsr="source ~/.zshrc"
test -e /home/jimbo/.iterm2_shell_integration.zsh && source /home/jimbo/.iterm2_shell_integration.zsh || true

eval "$(/usr/bin/starship init zsh)"
