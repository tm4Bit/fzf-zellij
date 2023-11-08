#!/usr/bin/zsh

if ! [ -x $HOME/.local/bin/fzj ]; then
  mkdir -p $HOME/.local/bin/
  ln -s $HOME/.local/share/zap/plugins/power_zellij/fzj.sh $HOME/.local/bin/fzj
fi

