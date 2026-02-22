#!/usr/bin/env bash
set -euo pipefail

extensions=(
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-docker
  github.vscode-github-actions
  eamodio.gitlens
  redhat.vscode-yaml
  ms-python.python
  ms-python.vscode-pylance
  streetsidesoftware.code-spell-checker
  editorconfig.editorconfig
  ms-kubernetes-tools.vscode-kubernetes-tools
)

for ext in "${extensions[@]}"; do
  echo "Installing $ext"
  code --install-extension "$ext" || true
done

echo "Installed/recommended extensions processed."
