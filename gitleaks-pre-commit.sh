#!/bin/bash

# Git config flag to enable/disable the hook
ENABLED=$(git config --bool --get gitleaks.enable)

if [ "$ENABLED" = "false" ]; then
  echo "Gitleaks pre-commit hook is disabled. Skipping..."
  exit 0
fi

# Detect OS
OS="$(uname -s)"

# Gitleaks install if missing
if ! command -v gitleaks &> /dev/null; then
  echo "Gitleaks not found. Installing..."

  case "${OS}" in
    Linux*)
      curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks-linux-amd64 -o /usr/local/bin/gitleaks
      chmod +x /usr/local/bin/gitleaks
      ;;
    Darwin*)
      curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks-darwin-amd64 -o /usr/local/bin/gitleaks
      chmod +x /usr/local/bin/gitleaks
      ;;
    *)
      echo "Unsupported OS: ${OS}"
      exit 1
      ;;
  esac

  echo "Gitleaks installed successfully."
fi

# Run gitleaks scan
echo "Running gitleaks scan..."
gitleaks detect --no-git -v

if [ $? -ne 0 ]; then
  echo "🚨 Potential secrets detected. Commit aborted."
  exit 1
fi

echo "✅ No secrets detected. Proceeding with commit."
exit 0
