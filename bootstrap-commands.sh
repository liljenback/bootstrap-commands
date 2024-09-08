#!/bin/env bash

# A bash script that checks if commands are installed and if not attempts to install
# them with a package manager or a script.
# Run this script like this: `. ./bootstrap-commands.sh`
# The dot at the beginning of the command is important because it runs the script in the current shell
# and not in a subshell so that the any environment variables are accessible.

DEFAULT_COMMANDS_FILE="commands-common.cfg"
COMMANDS_FILE=$DEFAULT_COMMANDS_FILE

function print_usage() {
  echo "Usage: . ./bootstrap-commands.sh [-f file]"
  echo "Options:"
  echo "  -f file  Install commands from file (default: commands-common.cfg)"
}

if [[ "$BASH_SOURCE" == "$0" ]]; then
  echo "This script must be sourced, run like this: . ./bootstrap-commands.sh"
  print_usage
  exit 1
fi

# Usage
if [ $# -gt 0 ]; then
  if [ $1 == "-h" ] || [ $1 == "--help" ]; then
    print_usage
    return 0
  fi
  # Check what commands file to use
  if [ $1 == "-f" ]; then
    if [ ! -f $2 ]; then
      echo "Commands file does not exist: $2"
      return 1
    else
      COMMANDS_FILE=$2
    fi
  fi
fi

trim_whitespace() {
  echo "$1" | xargs
}

trim_comment() {
  echo "${1%%#*}"
}

unset commands
declare -A commands

# Temporary variables
current_command=""
declare -A command_fields

save_command() {
  if [ ! -z "$current_command" ]; then
    # Serialize the key-value pairs and store them in the commands array
    command_string=""
    for key in "${!command_fields[@]}"; do
      command_string+="[$key]=${command_fields[$key]} "
    done
    commands[$current_command]="$command_string"
  fi
}

read_config() {
  while read -r line; do

    # Remove leading/trailing whitespace
    line=$(trim_comment "$line")
    line=$(trim_whitespace "$line")

    # Skip empty lines or comments
    [ -z "$line" ] && continue
    [[ $line =~ ^# ]] && continue

    if [[ $line =~ ^\[(.*)\]$ ]]; then
      save_command
      current_command="${BASH_REMATCH[1]}"
      command_fields=()
      continue
    fi

    # Check if the line contains a key-value pair
    if [[ $line =~ ^([^=]+)=[[:space:]]*(.*)$ ]]; then
      key=$(trim_whitespace "${BASH_REMATCH[1]}")
      value=$(trim_whitespace "${BASH_REMATCH[2]}")
      command_fields["$key"]="$value"
    fi

  done <$1

  # Save last command read
  save_command
}

output_config() {
  for command in "${!commands[@]}"; do
    eval "declare -A tmp_array=(${commands[$command]})"
    for key in "${!tmp_array[@]}"; do
      echo "  $key: ${tmp_array[$key]}"
    done
  done
}

get_command_value() {
  command_name=$1
  key=$2
  default_value=$3
  eval "declare -A tmp_array=(${commands[$command_name]})"
  [ -z "${tmp_array[$key]}" ] && echo $default_value || echo ${tmp_array[$key]}
}

function command_is_installed() {
  EXISTS=1
  # Check if the command exists with dpkg and make sure it's not listed ad deinstalled
  if dpkg -s $1 &>/dev/null && ! dpkg -s $1 | grep -q "deinstall"; then
    EXISTS=0
  elif snap list $1 &>/dev/null; then
    EXISTS=0
  elif command -v $1 &>/dev/null; then
    EXISTS=0
  elif which $1 &>/dev/null; then
    EXISTS=0
  # elif [ -f "/usr/local/bin/$1" ]; then
  #     EXISTS=0
  # elif [ -f "/usr/bin/$1" ]; then
  #     EXISTS=0
  # elif [ -f "/bin/$1" ]; then
  #     EXISTS=0
  # elif [ -f "/snap/bin/$1" ]; then
  #     EXISTS=0
  fi
  return $EXISTS
}

install_command_with_installer() {
  command=$1
  installer=$2
  if [ $installer == "apt" ]; then
    sudo apt install $command || return 1
  elif [ $installer == "snap" ]; then
    snap install --classic $command || snap install $command || return 1
  elif [ $installer == "dnf" ]; then
    sudo dnf install $command || return 1
  elif [ $installer == "yum" ]; then
    sudo yum install $command || return 1
  elif [ $installer == "pacman" ]; then
    sudo pacman -S $command || return 1
  elif [ $installer == "brew" ]; then
    brew install $command || return 1
  elif [ $installer == "script" ]; then
    # Run the command install script
    install_script="install-scripts/install-$command.sh"
    if [ -f $install_script ]; then
      ./$install_script && return
    else
      echo "Missing install script: $install_script"
      return 1
    fi
  fi
}

install_command() {
  local command=$1
  if command_is_installed $command; then
    return
  fi
  # First install dependencies
  local dependencies=$(get_command_value $command "dependencies" "")
  if [ ! -z "$dependencies" ]; then
    echo "Installing dependencies for $command"
    for dependency in $dependencies; do
      install_command $dependency
    done
  fi
  # Check if the command has a specific installer
  # If not, try to install with the available package managers
  local installer=$(get_command_value $command "installer")
  if [ -z "$installer" ]; then
    for manager in "${available_package_managers[@]}"; do
      echo "Trying to install $command with $manager"
      install_command_with_installer $command $manager && return
    done
  fi
  install_command_with_installer $command $installer && return
  echo "Failed to install $command with the available install options"
}

install_commands() {
  for command in "${!commands[@]}"; do
    if ! command_is_installed $command; then
      echo -en "\e[31m$command\e[0m is not installed, "
      # Ask the user if they want to install the command
      read -p "do you want to? [y/n] " answer
      if [ $answer != "y" ]; then
        continue
      fi
      install_command $command
    else
      echo -e "\e[32m$command\e[0m is already installed"
    fi
  done
}

available_package_managers=()

# Function to detect available package manager(s)
detect_package_managers() {
    local managers=("apt" "snap" "dnf" "yum" "pacman" "brew")

    for manager in "${managers[@]}"; do
        if command -v $manager &> /dev/null; then
            available_package_managers+=($manager)
        fi
    done

    if [ ${#available_package_managers[@]} -eq 0 ]; then
        echo "No supported package manager found."
    fi
}

# Run the function
detect_package_managers

# Load the commands
read_config $COMMANDS_FILE

# Output the parsed commands
# output_config

install_commands
