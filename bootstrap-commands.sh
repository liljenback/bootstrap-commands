#!/bin/env bash

# A bash script that checks if commands are installed and if not attempts to install
# them with a package manager or a script.
# Run this script like this: `. ./bootstrap-commands.sh`
# The dot at the beginning of the command is important because it runs the script in the current shell
# and not in a subshell so that the any environment variables are accessible.

DEFAULT_COMMANDS_FILE="commands-common.sh"
COMMANDS_FILE=$DEFAULT_COMMANDS_FILE

function print_usage() {
    echo "Usage: . ./bootstrap-commands.sh [-f file]"
    echo "Options:"
    echo "  -f file  Install commands from file (default: commands.sh)"
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

# Load the commands
unset commands
commands=()
. $COMMANDS_FILE

function command_exists() {
    EXISTS=1
    if dpkg -s $1 &> /dev/null; then
        EXISTS=0
    elif snap list $1 &> /dev/null; then
        EXISTS=0
    elif command -v $1 &> /dev/null; then
        EXISTS=0
    elif which $1 &> /dev/null; then
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

for key in "${commands[@]}"; do
    key_parts=($key)
    command=${key_parts[0]}
    installer=${key_parts[1]}
    if ! command_exists $command; then
        echo -en "\e[31m$command\e[0m is not installed, "
        # Ask the user if they want to install the command
        read -p "do you want to? [y/n] " answer
        if [ $answer != "y" ]; then
            continue
        fi
        if [ $installer == "apt" ]; then
          sudo apt install $command
        elif [ $installer == "snap" ]; then
          snap install --classic $command
        elif [ $installer == "script" ]; then
            # Run the command install script
            install_script="install-scripts/install-$command.sh"
            if [ -f $install_script ]; then
                ./$install_script
            else
                echo "Missing install script: $install_script"
            fi
        fi
    else
        echo -e "\e[32m$command\e[0m is already installed"
    fi
done

