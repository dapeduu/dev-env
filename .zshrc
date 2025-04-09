# Load asdf
. '/home/dapedu/.asdf/asdf.sh'

# Start mise
eval "$(mise activate zsh --shims)"

# Initialize starship prompt
eval "$(starship init zsh)"

# History settings
SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history

# Load completion system
autoload -Uz compinit
compinit

# Load plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Add zsh-completions to fpath
fpath=(~/.zsh/zsh-completions/src $fpath)

# Adding gpg key to all zsh terminals
export GPG_TTY=$(tty)