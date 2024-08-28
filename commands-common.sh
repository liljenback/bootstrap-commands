#!/bin/env bash

# You can add or remove commands here for your specific needs.

# Networking
commands+=("curl apt") # For making HTTP requests
commands+=("openssh-server apt") # For SSH access to the machine

# Version Control
commands+=("git-all apt") # For version control, git with all dependencies

# Web Browsing
commands+=("chromium-browser apt") # For browsing the web

# File Editing and Management
commands+=("code snap") # For editing files
commands+=("meld apt") # For comparing files
commands+=("tree apt") # For displaying directories
commands+=("ripgrep apt") # For searching files
commands+=("fzf apt") # For fuzzy finding
commands+=("gparted apt") # For managing partitions

# System Monitoring
commands+=("htop apt") # For monitoring system resources
commands+=("iotop apt") # For monitoring disk usage
commands+=("tmux apt") # For managing terminal sessions

# Development / Building / Running Tools
commands+=("nodejs apt") # For running JavaScript code
commands+=("npm apt") # For installing node packages
commands+=("nvm script") # For managing node versions
commands+=("gradle apt") # For building Java projects
commands+=("openjdk-21-jdk apt") # For building Java projects
commands+=("python3 apt") # For building Go projects
commands+=("python-is-python3 apt") # For making python command point to python3
commands+=("python3-pip apt") # For installing Python packages
commands+=("build-essential apt") # For building C(++) code
commands+=("go snap") # For building Go projects

# Data Parsing / Processing
commands+=("jq apt") # For parsing JSON

# Audio / Video
commands+=("vlc apt") # For playing media files
commands+=("ffmpeg apt") # For converting media files

# Containers
commands+=("docker.io apt") # For running containers

# commands+=("blupp apt") # For blupping
