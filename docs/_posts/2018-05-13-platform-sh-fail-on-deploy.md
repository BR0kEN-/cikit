---
date: 2018-05-13 01:37:00
title: "Control deployment on Platform.sh"
excerpt: "Fail of deploy on Platform.sh cannot be identified by standard toolset but we are able to overcome this."
toc_label: "Paragraphs"
toc: true
header:
  teaser: /assets/posts/2018-05-13-platform-sh-fail-on-deploy/platform.sh.png
tags:
  - platform.sh
  - deploy
  - cikit
---

![{{ page.title }}]({{ page.header.teaser }}){: .align-center}

The [Platform.sh](https://platform.sh) is relatively new and promising hosting service that uses [Git flow](https://nvie.com/posts/a-successful-git-branching-model) and [containerization](https://en.wikipedia.org/wiki/Operating-system-level_virtualization). I personally choose it for sure in favor of [Acquia](https://acquia.com) or [Pantheon.io](https://pantheon.io). But there are not all features in the ideal state and you have something to tune before getting the desired result. In this post, we'll cover nasty moments of deployment process and techniques to overcome them for achieving a good automation.

## What's the problem?

The hosting gives you two steps for completing the deployment: [build](https://docs.platform.sh/configuration/app/build.html#build-hook) and [deploy](https://docs.platform.sh/configuration/app/build.html#deploy-hook). During the `build` you have a writable filesystem, but no services available (like MariaDB, Redis, RabbitMQ, etc.). At the `deploy` the FS is switched to read-only mode and all the services are ready for usage.

The problem is completely tethered to the `deploy` operation and its technical description is the following: **unable to bubble up the exit code of deployment to handle it properly and mark process as failed.**

The `build` hook executes outside of a container so any exit code can easily stop the process. That cannot be said about the `deploy` hook because its area of operation is within a container and there's no technical solution exists at desks of Platform.sh development team to pass it out to the level where it can be handled.

Here is what [Damien Tournoud](https://twitter.com/damz), Platform.sh CTO says:

> There is no way to fail the deployment if the deploy hook fails. It runs  deep inside the deployment process and we don't have a way to bubble up the return code at this point. We have on our roadmap to change the deployment process to allow that, but I cannot give you an ETA for it.

All this means that failed deploy will produce you a working environment and you won't know about the problems until login to an environment via SSH and manually trace the [/var/log/deploy.log](https://docs.platform.sh/development/logs.html#deploylog) in there.

## The solution

### Preamble

At the `deploy` we can know the exit codes but the Platform.sh cannot. We have services like MariaDB available, so when our process ends up in a non-zero exit code we can set a flag in a database to rely on it in the future.

### Implementation

Here is a part of [.platform.app.yaml](https://docs.platform.sh/configuration/app-containers.html) declaring the hooks.

```yaml
hooks:
  build: 'bash scripts/.platform/hooks/hook.sh build'
  deploy: 'bash scripts/.platform/hooks/hook.sh deploy'
```

The `.platform` directory (in a project root) isn't available on Platform.sh environments during `deploy` operation so that's why the directory with the same name is in `scripts` subdirectory. There we will store our custom, Platform.sh related scripts.
{: .notice--info}

### hook.sh: implementation

The `scripts/.platform/hooks/hook.sh` is general for every project and all you have to modify per project is the `APP_DIR_RELATIVE` and `PROCESS_SUBDIRS` (read the description for every one of them in the code).

```bash
#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Configuration.
# ------------------------------------------------------------------------------

# Ongoing action.
declare -r ACTION="$1"
# The path to project root, relative to the directory with this file.
# E.g.: if this file in "scripts/.platform/hooks", then the value is "../../..".
declare -r APP_DIR_RELATIVE="../../.."
# The list of directories where to execute the action.
# The key is a name of "*.sh" file in "<ACTION>". E.g., if the action
# is "deploy" then the path will be "deploy/<KEY>.sh". The "pwd" of
# running a concrete script will be the directory that is a value for
# the key.
declare -rA PROCESS_SUBDIRS=(
  [crawler]="crawler"
  [drupal]="docroot"
)

# ------------------------------------------------------------------------------
# DO NOT EDIT BELOW.
# ------------------------------------------------------------------------------

set -eE

inform() {
  echo "[$(date --iso-8601=seconds)]" "$@"
}

if [[ ! "$ACTION" =~ ^(build|deploy)$ ]]; then
  inform "Invalid argument. It must be either \"build\" or \"deploy\"."
  exit 19
fi

# The path to directory with this file.
HOOK_DIR="$(cd "$(dirname "$0")" && pwd -P)"
# Set variables that are defined on Platform.sh environment but doesn't locally.
# The designation of every variable is described in the official documentation.
# https://docs.platform.sh/development/variables.html#platformsh-provided-variables
# The default values allows running the script locally.
: "${PLATFORM_APP_DIR:="$(cd "$HOOK_DIR/$APP_DIR_RELATIVE" && pwd -P)"}"

if [ "build" == "$1" ]; then
  : "${PLATFORM_BRANCH:="unknown-at-build-stage"}"
else
  : "${PLATFORM_BRANCH:="$(cd "$PLATFORM_APP_DIR" && git rev-parse --abbrev-ref HEAD)"}"
fi

include() {
  for SUB_DIR in "/" "/environment/$PLATFORM_BRANCH/"; do
    FILE="$HOOK_DIR/$ACTION$SUB_DIR$1.sh"

    if [ -f "$FILE" ]; then
      inform "--- include \"$FILE\"."
      . "$FILE"
    fi

    unset FILE
  done
}

handle_shutdown() {
  if [ $? -eq 0 ]; then
    inform "${ACTION^} successfully finished."
    include "_succeeded"
  else
    inform "${ACTION^} failed."
    include "_failed"
  fi
}

trap handle_shutdown EXIT

for HANDLER in "${!PROCESS_SUBDIRS[@]}"; do
  inform "${ACTION^}ing ${HANDLER^}..."
  cd "$PLATFORM_APP_DIR/${PROCESS_SUBDIRS[$HANDLER]}"
  include "$HANDLER"
done

inform "Printing the environment..."
env
```

Now let's create couple more directories in `scripts/.platform/hooks`: `deploy` and `build`. Since in above-posted `hook.sh` we have

```bash
declare -rA PROCESS_SUBDIRS=(
  [crawler]="crawler"
  [drupal]="docroot"
)
```

it means inside of newly created directories we're optionally can place the `crawler.sh` and `drupal.sh` to build/deploy the specific part of our application.

### hook.sh: configuration

To setup a runner properly you may need to edit available variables at the top of the file.

- `ACTION` - the argument position to the runner, defaults to `$1`.
- `APP_DIR_RELATIVE` - the path to project root, relative to the directory with the runner, defaults to `../../..`.
- `PROCESS_SUBDIRS` - the list of directories where to execute the action. The key is a name of `*.sh` file in `scripts/.platform/hooks/<ACTION>`. E.g., if the action is `deploy` then the path will be `scripts/.platform/hooks/deploy/<KEY>.sh`. Defaults to `([drupal]="docroot")`.

### hook.sh: process

Within the `scripts/.platform/hooks/<ACTION>` you may consider creating two handlers:

  - `_succeeded.sh` - the file that will be included in a runtime once all commands in a process will successfully end.
  - `_failed.sh` - the same as above, but only after first non-zero return code (a process will be terminated).

Available environment variables:

- `PLATFORM_APP_DIR` - the path to directory with a project.
- `PLATFORM_BRANCH` - the name of a Git branch an environment exists for (the `unknown-at-build-stage` if the action is `build`).

*The `hook.sh` can be run locally if it doesn't rely on Platform.sh environment.*

### hook.sh: environment specific handlers

The `build` hook executes in an isolation, therefore, an environment cannot be determined. The opposite situation for `deploy` and it gives the possibility to perform environment-specific actions. The following Bash scripts may be included (after non-specific) in a runtime context if exist:

- `scripts/.platform/hooks/deploy/environment/<PLATFORM_BRANCH>/<PROCESS_SUBDIR_KEY>.sh`
- `scripts/.platform/hooks/deploy/environment/<PLATFORM_BRANCH>/_succeeded.sh`
- `scripts/.platform/hooks/deploy/environment/<PLATFORM_BRANCH>/_failed.sh`

### Samples of build & deploy scripts

As a sample we'll consider the following scripts:

- `scripts/.platform/hooks/build/crawler.sh`

  ```bash
  #!/usr/bin/env bash

  composer install --no-ansi --no-interaction --no-progress --optimize-autoloader
  ```

  [Platform.sh automatically processes the `composer.json`](https://docs.platform.sh/configuration/app/build.html#php-composer-by-default) in a root directory of a project but the `crawler` is a subproject with its own dependencies so we're building it separately.
  {: .notice--info}

- `scripts/.platform/hooks/build/drupal.sh`

  ```bash
  #!/usr/bin/env bash

  cp sites/default/default.settings.php sites/default/settings.php
  ```

- `scripts/.platform/hooks/deploy/drupal.sh`

  ```bash
  #!/usr/bin/env bash

  # Do not rebuild the cache after running database updates.
  drush updatedb --cache-clear=0 -y
  # Forcibly rebuild the cache. This is needed because if no
  # DB updates weren't run then the rebuild not happen.
  drush cache-rebuild -y
  drush config-import -y
  drush entity-updates -y
  ```

  The `scripts/.platform/hooks/deploy/crawler.sh` is not mandatory as well as any other scripts. If we omit their creation just nothing won't be executed.
  {: .notice--info}

- `scripts/.platform/hooks/deploy/_failed.sh`

  ```bash
  #!/usr/bin/env bash

  drush php-eval "\Drupal::state()->set('psh_deploy_fail', TRUE)"
  ```

- `scripts/.platform/hooks/deploy/_succeeded.sh`

  ```bash
  #!/usr/bin/env bash

  drush php-eval "\Drupal::state()->delete('psh_deploy_fail')"
  ```

You may see Drupal 8 is used here and we're creating some state for it. Now we need the logic around this state to handle a failure of deploy gracefully. To tackle this we'll create the HTTP middleware that reads the state and deduces a project out of work.

### Drupal 8 HTTP middleware

- `PROFILE_OR_MODULE.services.yml`

  ```yaml
  services:
    PROFILE_OR_MODULE.http_middleware.platformsh:
      class: Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShDeployHookFailedHttpMiddleware
      arguments:
        - '@state'
      tags:
        - name: http_middleware
          # Should be the first to fail early.
          priority: 1000
  ```

- `src/HttpMiddleware/PlatformShDeployHookFailedHttpMiddleware.php`

  ```php
  namespace Drupal\PROFILE_OR_MODULE\HttpMiddleware;

  use Drupal\Core\State\StateInterface;
  use Symfony\Component\HttpFoundation\Request;
  use Symfony\Component\HttpKernel\HttpKernelInterface;

  /**
   * Makes Platform.sh website instance inaccessible if deploy has been failed.
   *
   * Preamble:
   * There is no way to fail the deployment if the deploy hook fails. It runs
   * deep inside the deployment process and we don't have a way to bubble up
   * the return code at this point. We have on our roadmap to change the
   * deployment process to allow that, but I cannot give you an ETA for it.
   *
   * Damien Tournoud, Platform.sh CTO.
   *
   * @link https://platformsh.slack.com/archives/C0JHEUHQD/p1523719755000057
   */
  class PlatformShDeployHookFailedHttpMiddleware implements HttpKernelInterface {

    /**
     * The error message.
     */
    public const MESSAGE = 'The deploy to Platform.sh has been failed.';
    /**
     * The full path to the environment deployment log.
     */
    public const LOGFILE = '/var/log/deploy.log';
    /**
     * The name of the key in a state. Existence means a failed deployment.
     *
     * @see scripts/.platform/hooks/deploy/_failed.sh
     */
    public const MARKER = 'psh_deploy_fail';

    /**
     * The decorated kernel.
     *
     * @var \Symfony\Component\HttpKernel\HttpKernelInterface
     */
    protected $httpKernel;
    /**
     * An instance of the "state" service.
     *
     * @var \Drupal\Core\State\StateInterface
     */
    protected $state;

    /**
     * Constructs the HTTP middleware.
     *
     * @param \Drupal\Core\State\StateInterface $state
     *   An instance of the "state" service.
     */
    public function __construct(HttpKernelInterface $http_kernel, StateInterface $state) {
      $this->httpKernel = $http_kernel;
      $this->state = $state;
    }

    /**
     * {@inheritdoc}
     */
    public function handle(Request $request, $type = self::MASTER_REQUEST, $catch = TRUE) {
      // No error or we're not on Platform.sh environment.
      if (
        empty($_ENV['PLATFORM_BRANCH']) ||
        empty($_ENV['PLATFORM_ENVIRONMENT']) ||
        empty($this->state->get(static::MARKER))
      ) {
        return $this->httpKernel->handle($request, $type, $catch);
      }

      if (is_readable(static::LOGFILE)) {
        $log = file_get_contents(static::LOGFILE);
      }
      else {
        $log = sprintf(
          'The <b>%s</b> is not readable, do <b>platform environment:ssh -e %s</b> and check it on a server.',
          static::LOGFILE,
          $_ENV['PLATFORM_BRANCH']
        );
      }

      print '<section>';
      print '<h1>' . static::MESSAGE . '</h1>';
      print '<pre>';
      print preg_replace(
        '/(PLATFORM(?:SH_CLI_TOKEN|_ROUTES|_PROJECT_ENTROPY|_APPLICATION|_VARIABLES|_RELATIONSHIPS)=).*/',
        '\1SANITIZED',
        $log
      );
      print '</pre>';
      print '</section>';
      print '<br>';

      throw new \RuntimeException(static::MESSAGE);
    }

  }
  ```

- `tests/Unit/HttpMiddleware/PlatformShDeployHookFailedHttpMiddlewareTest.php`

  ```php
  namespace Drupal\Tests\PROFILE_OR_MODULE\Unit\HttpMiddleware;

  use Drupal\Core\State\StateInterface;
  use Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShDeployHookFailedHttpMiddleware;
  use Drupal\Tests\UnitTestCase;
  use Symfony\Component\HttpFoundation\Request;
  use Symfony\Component\HttpKernel\HttpKernelInterface;

  /**
   * Tests "platformsh" HTTP middleware.
   *
   * @coversDefaultClass \Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShDeployHookFailedHttpMiddleware
   * @group PROFILE_OR_MODULE
   */
  class PlatformShDeployHookFailedHttpMiddlewareTest extends UnitTestCase {

    /**
     * The application.
     *
     * @var \Symfony\Component\HttpKernel\HttpKernelInterface|\PHPUnit\Framework\MockObject\MockObject
     */
    protected $app;
    /**
     * The mock of the "state" service.
     *
     * @var \Drupal\Core\State\StateInterface|\PHPUnit\Framework\MockObject\MockObject
     */
    protected $state;
    /**
     * The mock of HTTP request.
     *
     * @var \Symfony\Component\HttpFoundation\Request
     */
    protected $request;
    /**
     * The instance of "platformsh" HTTP middleware.
     *
     * @var \Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShDeployHookFailedHttpMiddleware
     */
    protected $middleware;

    /**
     * {@inheritdoc}
     */
    protected function setUp() {
      parent::setUp();

      $this->app = $this
        ->getMockBuilder(HttpKernelInterface::class)
        ->getMock();

      $this->state = $this
        ->getMockBuilder(StateInterface::class)
        ->getMock();

      $this->request = Request::create('/');
      $this->middleware = new PlatformShDeployHookFailedHttpMiddleware($this->app, $this->state);
    }

    /**
     * Checks that middleware will have no effect on non-Platform.sh environments.
     */
    public function testHandleDefault() {
      $this->app
        ->expects(static::once())
        ->method('handle');

      $this->middleware->handle($this->request);
    }

    /**
     * Checks that failed deploy makes a site instance inaccessible.
     *
     * @expectedException \RuntimeException
     * @expectedExceptionMessage The deploy to Platform.sh has been failed.
     */
    public function testHandleDeployFailed() {
      $_ENV['PLATFORM_BRANCH'] = 'pr-104';
      $_ENV['PLATFORM_ENVIRONMENT'] = 'pr-104-47cw5cy';

      $this->state
        ->expects(static::once())
        ->method('get')
        ->with(PlatformShDeployHookFailedHttpMiddleware::MARKER)
        ->willReturn(TRUE);

      $this
        ->expectOutputRegex('/' . PlatformShDeployHookFailedHttpMiddleware::MESSAGE . '/');

      $this->middleware->handle($this->request);
    }

  }
  ```

## Conclusion

The Platform.sh is a good hosting with its container dedication and configuration flexibilities. However, as usual, there is a lot of work to do for improving the service.

I was also trying to use it as continuous integration tool but it really built in a way to stop you from doing this. For instance, you can't have Xdebug installed in some environments to generate PHPUnit coverage reports. If you are adding something, it'll be added everywhere. Everywhere means `master` environment too. The PHPUnit tests, PHPCS or HTMLCS checks etc. cannot be run during the `build` but can be at `deploy`. When the `build` has passed it means the application is ready for usage... I believe you've got the point - use dedicated CI instruments for achieving continuous delivery to Platform.sh and don't try to put everything to its shoulders. At the bottom line, it's just a hosting!
