#!/usr/bin/env bash

cd "$CIKIT_PROJECT_DIR"

if ! grep "PLATFORMSH_CLI_TOKEN" ~/.profile > /dev/null; then
  cat << 'EOF' >> ~/.profile
export PLATFORMSH_CLI_TOKEN="$(json_pp < "$CIKIT_PROJECT_DIR/.platform.app.json" | awk -F '"' '/token/ {print $4}')"
EOF
fi

PLATFORMSH_ENVIRONMENT="$CIKIT_PROJECT_DIR/.environment"

if [ -f "$PLATFORMSH_ENVIRONMENT" ] && ! grep ".environment" ~/.profile > /dev/null; then
  echo "source \"$PLATFORMSH_ENVIRONMENT\"" >> ~/.profile
fi

# Make the "PLATFORMSH_CLI_TOKEN" available.
source ~/.profile

platform project:set-remote "$(json_pp < "$CIKIT_PROJECT_DIR/.platform.app.json" | awk -F '"' '/id/ {print $4}')"
