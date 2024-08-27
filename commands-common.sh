#!/bin/env bash

# Web Browsing
commands["chromium"]="apt" # For browsing the web
commands["google-chrome"]="apt" # For browsing the web

# File Editing and Management
commands["code"]="apt" # For editing files
commands["meld"]="apt" # For comparing files
commands["tree"]="apt" # For displaying directories
commands["rg"]="apt" # For searching files
commands["fzf"]="apt" # For fuzzy finding

# Version Control
commands["git-all"]="apt" # For version control, git with all dependencies

# System Monitoring
commands["htop"]="apt" # For monitoring system resources
commands["iotop"]="apt" # For monitoring disk usage
commands["tmux"]="apt" # For managing terminal sessions

# Development / Building / Running Tools
commands["npm"]="apt" # For installing node packages
commands["nvm"]="script" # For managing node versions
commands["gradle"]="apt" # For building Java projects
commands["javac"]="apt" # For compiling Java code
commands["go"]="snap" # For building Go projects

# Networking
commands["curl"]="apt" # For making HTTP requests

# Data Parsing / Processing
commands["jq"]="apt" # For parsing JSON

# commands["blupp"]="apt" # For blupping
