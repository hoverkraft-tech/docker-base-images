export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode disabled  # disable automatic updates
ENABLE_CORRECTION="true"
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true

plugins=(
  git
  helm
  kubectl
  mise
  zsh-autosuggestions
  zsh-fzf-history-search
)

source $ZSH/oh-my-zsh.sh

# mise-en-place config
eval "$(mise activate zsh)"
mise hook-env -s zsh
