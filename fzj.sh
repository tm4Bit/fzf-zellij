#!/usr/bin/env bash

EXCLUDE_DIRS=(
  "node_modules"
  "cmake"
  "build"
)

EXCLUDE_FILES=(
  ".git"
  ".next"
  "build"
  "node_modules"
)

DEPENDENCIES=(
  fzf
  zellij
  lolcat
)

for dep in "${DEPENDENCIES[@]}"; do
  if ! command -v "$dep" &> /dev/null; then
    echo "󱧖 -> $dep not found (run: yay -S $dep)"
    exit 1
  fi
done

if [[ $1 == "--help" ]]; then
  echo "  fzj is a shell script that gives extra power to zellij using fzf

  USAGE:
    fzj -> open a zellij session with default name or list all section for selection 
    fzj [option] [valeu]

  OPTIONS:
    -t    create new tab in zellij with the given name[value]
    -s    create new session with a given name[value]
    -f    create a edit pane to the selected file

    --help  show this message"
  exit 0
fi

get_dir() {
  FIND_COMMAND="find $HOME -type d"
  for dir in "${EXCLUDE_DIRS[@]}"; do
    FIND_COMMAND+=" -name '$dir' -prune -o"
  done
  FIND_COMMAND+=" -type d -print"
  SELECTED_PATH=$(eval "$FIND_COMMAND" | fzf --prompt="󰥨 Search dir: " --height=40% --min-height=5 --pointer=" " --layout=reverse --border --preview "ls -la --color {}")
  echo $SELECTED_PATH
}

get_file() {
  FIND_COMMAND="find -type d"
  for dir in "${EXCLUDE_FILES[@]}"; do
    FIND_COMMAND+=" -name '$dir' -prune -o"
  done
  FIND_COMMAND+=" -type f -print"
  FILE=$(eval "$FIND_COMMAND" | fzf --prompt="󰈞 Search file: " --height=40% --min-height=5 --pointer=" " --layout=reverse --border --preview "cat {}")
  echo $FILE
}

if [ $# == 0 ]; then
  if [ $(zellij ls | wc -l) == 0 ]; then
    zellij --session default
  else
    # '[32;1mnew[m [Created [35;1m52m 42s[m ago]' This is the new output for the `zellij ls` for each session 
    # first I remove the `[32;1m`
    # Then I grab the first field using the space delimeter
    # Then I use sed to remove `[m`
    session=$(zellij ls | cut -c 8- | cut -d " " -f1 | sed -r 's/\x1B\[[0-9;]*[mK]//g' | fzf --prompt="󱊄 Select a session: " --height=20% --color --pointer=" " --min-height=5 --layout=reverse --border)
    if [[ $session ]]; then
      zellij a $session
    else
      echo "󰂭  No session selected!"
    fi
  fi
elif [ $# == 1 ]; then
  if [ $1 == "-f" ]; then
    file=$(get_file)
    
    if [ $file ]; then
      zellij action edit $file
    else
      echo "󰂭  No file selected!"
    fi
  else
    echo "󰂭  invalid command: fzj $1 [value]"
  fi
else
  if [ $1 == "-t" ]; then
    path=$(get_dir)

    cd $path
    
    if [ $path ]; then
      zellij action new-tab -n $2 -l ~/.local/share/zap/plugins/fzf-zellij/fzj_tab.kdl -c $path
    else
      echo "󰂭  No path selected!"
    fi
  elif [ $1 == "-s" ]; then
    path=$(get_dir)

    cd $path
    if [ $path ]; then
      zellij --session $2
    else
      echo "󰂭  No path selected!"
    fi
  else
    echo "󰂭  Invalid option!"
  fi
fi
