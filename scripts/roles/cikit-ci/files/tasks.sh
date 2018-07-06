#!/usr/bin/env bash

# Allows continuing the process regardless of an exit code at one of the stages.
set +e

# ------------------------------------------------------------------------------
# The required configuration of a process.
# ------------------------------------------------------------------------------

declare -rA VARIABLES=(
  [BUILD_NUMBER]="either \"stable\" or any custom value, like \"54\" or \"my-pr\""
  [BUILD_MODE]="either \"full\", \"pull\" or whatever you have defined in \"scripts/tasks/reinstall/modes/*.yml\""
  [BUILD_ENV]="the name of an environment to build or \"default\""
  [CIKIT_PROJECT_DIR]="the path to directory where repository clones to"
  [CIKIT_PROJECT_HOSTNAME]="the hostname where the project can be accessed"
  [RUN_SNIFFERS]="either \"yes\" or whatever"
  [RUN_TESTS]="either \"yes\" or whatever"
)

for VARIABLE in "${!VARIABLES[@]}"; do
  if [ -z ${!VARIABLE+x} ]; then
    echo "The \"$VARIABLE\" variable is missing! It's value must be ${VARIABLES[$VARIABLE]}."
    exit 101
  fi

  # Ensure the variable is available in the subshells.
  # shellcheck disable=SC2163
  # https://github.com/koalaman/shellcheck/wiki/SC2163
  export "${VARIABLE}"
done

# ------------------------------------------------------------------------------
# Read CIKit configuration.
# ------------------------------------------------------------------------------

declare -A CIKIT_PROJECT_CONFIG=()

for VARIABLE in webroot project build_slug; do
  VALUE="$(awk '/^'"$VARIABLE"':/ {print $2}' < "$CIKIT_PROJECT_DIR/.cikit/config.yml")"

  if [ -z "$VALUE" ]; then
    echo "The value of \"$VARIABLE\" variable cannot be empty!"
    exit 102
  fi

  CIKIT_PROJECT_CONFIG["$VARIABLE"]="$VALUE"
done

# ------------------------------------------------------------------------------
# Compute build parameters.
# ------------------------------------------------------------------------------

if [ "$BUILD_NUMBER" == "stable" ]; then
  export IS_COMMIT=false
  BUILD_ID="${CIKIT_PROJECT_CONFIG['project']}-$BUILD_ENV"
else
  export IS_COMMIT=true
  BUILD_ID="${CIKIT_PROJECT_CONFIG['project']}-${CIKIT_PROJECT_CONFIG['build_slug']}-$BUILD_NUMBER"
fi

# https://docs.python.org/2/using/cmdline.html#cmdoption-u
export PYTHONUNBUFFERED=1
# Replace underscores by dashes in the ID of a build.
export BUILD_ID="${BUILD_ID//_/-}"
# Form an absolute path to directory where the project is accessible from web.
export DESTINATION="${CIKIT_PROJECT_CONFIG['webroot']}/$BUILD_ID"

# Print the environment.
env

# ------------------------------------------------------------------------------
# Define the runtime.
# ------------------------------------------------------------------------------

cikit_run() {
  cikit "$1" \
    "${@:2}" \
    --env="$BUILD_ENV" \
    --site-url="https://$BUILD_ID.$CIKIT_PROJECT_HOSTNAME" \
    --build-id="$BUILD_ID" \
    --workspace="$CIKIT_PROJECT_DIR"
}

cikit_hook() {
  local HOOK_PLAYBOOK="$CIKIT_PROJECT_DIR/.cikit/ci/$1.yml"

  if [ -f "$HOOK_PLAYBOOK" ]; then
    cikit_run "$HOOK_PLAYBOOK" --dist="$DESTINATION" --rc="$PROCESS_EXIT_CODE"
  fi
}

export -f cikit_run cikit_hook

# ------------------------------------------------------------------------------
# Define the process.
# ------------------------------------------------------------------------------

PROCESS_pre() {
  cikit_hook pre-deploy
}

PROCESS_main() {
  # Install a project.
  if ${IS_COMMIT}; then
    cikit_run reinstall --actions="$(php -r "echo json_encode(array_map('trim', array_filter(explode(PHP_EOL, '$(git log -n1 --pretty=%B | awk -vRS="]" -vFS="[" '{print $2}')'))));")"
  else
    cikit_run reinstall --reinstall-mode="$BUILD_MODE"
  fi

  # Copy codebase to directory accessible from the web.
  sudo rsync -ra --delete --chown=www-data:www-data ./ "$DESTINATION/"

  if [ "$RUN_SNIFFERS" == "yes" ]; then
    cikit_run sniffers
  fi

  if [ "$RUN_TESTS" == "yes" ]; then
    cikit_run tests --run --headless
  fi
}

PROCESS_post() {
  cikit_hook post-deploy
}

PROCESS_clean() {
  cikit_hook server-cleaner
}

PROCESS_finish() {
  echo "Restore permissions for \"$USER\"."
  # The "$USER" must be either "jenkins" or "gitlab-runner".
  sudo chown -R "$USER":"$USER" "$CIKIT_PROJECT_DIR"
  # The "$HOME" will be for the "$USER".
  sudo chown -R "$USER":"$USER" "$HOME"
}

export -f PROCESS_pre PROCESS_main PROCESS_post PROCESS_clean PROCESS_finish
