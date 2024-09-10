#!/usr/bin/env bash

# Install script grabbed from here:
#   https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# aaand here's some custom stuff because it looks like when installing on macOS,
# you need to add this to your .bashrc or .bash_profile and it might not get added.
if ! grep -q "export NVM_DIR" ~/.bashrc; then
  echo "export NVM_DIR=\"\$HOME/.nvm\"" >> ~/.bashrc
  echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" >> ~/.bashrc
fi
