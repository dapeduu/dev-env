. '/home/dapedu/.asdf/asdf.sh'

eval "$(starship init zsh)"

autoload -Uz compinit
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(~/.zsh/zsh-completions/src $fpath)
