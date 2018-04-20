#!/usr/bin/env bash

CIKIT_PATH="/usr/local/share/cikit"
MATRIX_HOSTNAME="example.com"
MATRIX_NAME="matrix1"
DROPLET_NAME="cikit01"
PROJECT_NAME="test_project"
MATRIX_CREDS_DIR=".cikit/credentials/$MATRIX_NAME"
MATRIX_HOSTNAME_FILE="$MATRIX_CREDS_DIR/.hostname"
DROPLET_CREDS_DIR="$MATRIX_CREDS_DIR/$DROPLET_NAME"
MATRIX_PRIVATE_KEY="$DROPLET_CREDS_DIR/$DROPLET_NAME.private.key"
MATRIX_PUBLIC_KEY="$DROPLET_CREDS_DIR/$DROPLET_NAME.public.key"

read -r -d '' NO_ARGS_RUN << EOF
usage: inventory [-h] (--list | --host HOST)
inventory: error: one of the arguments --list --host is required
EOF

read -r -d '' DROPLET_CREDS_JSON << EOF
"${MATRIX_NAME}.${DROPLET_NAME}": {"hosts": ["${DROPLET_NAME}.${MATRIX_HOSTNAME}"], "vars": {"ansible_port": "2201", "ansible_ssh_private_key_file": "${CIKIT_PATH}/${PROJECT_NAME}/${MATRIX_PRIVATE_KEY}", "ansible_user": "root"}}
EOF

read -r -d '' MATRIX_CREDS_JSON << EOF
"${MATRIX_NAME}": {"hosts": ["${MATRIX_HOSTNAME}"], "vars": {"ansible_port": 22, "ansible_ssh_private_key_file": "~/.ssh/id_rsa", "ansible_user": "root"}}
EOF

cd "$CIKIT_PATH"

verify_output()
{
  local RESULT

  RESULT="$($1 2>&1)"

  if [ "$2" != "$RESULT" ]; then
    echo "Test:"
    echo "  $1"
    echo "Expected:"
    echo "  $2"
    echo "Actual:"
    echo "  $RESULT"
    exit 1
  fi
}

# ==============================================================================

# Unable to run without options.
verify_output \
  "python $CIKIT_PATH/lib/inventory" \
  "$NO_ARGS_RUN"

# ==============================================================================

# No credentials initially.
verify_output \
  "python $CIKIT_PATH/lib/inventory --list" \
  "{}"

# ==============================================================================

cikit host/add --alias="$MATRIX_NAME" --domain="$MATRIX_HOSTNAME" --ignore-invalid

verify_output \
  "python $CIKIT_PATH/lib/inventory --list" \
  "{$MATRIX_CREDS_JSON}"

# Clean up.
cikit host/delete --alias=matrix1

# Empty after removal.
verify_output \
  "python $CIKIT_PATH/lib/inventory --list" \
  "{}"

# ==============================================================================

cikit init --project="$PROJECT_NAME" --without-sources
# Go to the created project.
cd "$PROJECT_NAME"
# Define the pseudo droplet.
mkdir -p "$DROPLET_CREDS_DIR"
touch "$MATRIX_PRIVATE_KEY"
touch "$MATRIX_PUBLIC_KEY"
echo "$MATRIX_HOSTNAME" > "$MATRIX_HOSTNAME_FILE"

# Ensure the credentials will be available.
verify_output \
  "python $CIKIT_PATH/lib/inventory --list" \
  "{$DROPLET_CREDS_JSON}"

# Add the host.
cikit host/add --alias="$MATRIX_NAME" --domain="$MATRIX_HOSTNAME" --ignore-invalid

# Ensure the credentials will be available.
verify_output \
  "python $CIKIT_PATH/lib/inventory --list" \
  "{$DROPLET_CREDS_JSON, $MATRIX_CREDS_JSON}"

# Request droplet credentials only.
verify_output \
  "python $CIKIT_PATH/lib/inventory --host=$MATRIX_NAME.$DROPLET_NAME" \
  "{$DROPLET_CREDS_JSON}"

# Request matrix credentials only.
verify_output \
  "python $CIKIT_PATH/lib/inventory --host=$MATRIX_NAME" \
  "{$MATRIX_CREDS_JSON}"

# ==============================================================================

# Clean up.
cikit host/delete --alias=matrix1
rm -rf "$CIKIT_PATH/$PROJECT_NAME"

# ==============================================================================

echo "All good."
