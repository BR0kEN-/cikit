---
date: 2018-05-22 06:00:00
title: "Control deployment on Platform.sh"
excerpt: "Fail of deploy on Platform.sh cannot be identified by standard toolset but we are able to overcome this."
toc_label: "Paragraphs"
toc: true
header:
  teaser: /assets/posts/2018-05-22-platform-sh-fail-on-deploy/platform.sh.png
tags:
  - platform.sh
  - deploy
  - cikit
---

![{{ page.title }}]({{ page.header.teaser }}){: .align-center}

The [Platform.sh](https://platform.sh) is relatively new and promising Platform-as-a-Service solution that uses [Git flow](https://nvie.com/posts/a-successful-git-branching-model) and [containerization](https://en.wikipedia.org/wiki/Operating-system-level_virtualization), so I'll choose it for sure in favor of [Acquia](https://acquia.com) or [Pantheon.io](https://pantheon.io). But there are not all features in the ideal state and you have something to tune before getting the desired result. In this post, we'll cover deployment process drawbacks and techniques to overcome them for achieving a good automation.

## Issue

Platform.sh gives you two steps for completing the deployment: [build](https://docs.platform.sh/configuration/app/build.html#build-hook) and [deploy](https://docs.platform.sh/configuration/app/build.html#deploy-hook). During the `build` you have a writable filesystem, but no services available (like MariaDB, Redis, RabbitMQ, etc.). At the `deploy` stage the FS is switched to read-only mode and all services are ready to use.

The issue is completely tethered to the `deploy` operation and its technical description looks the following: **unable to bubble up the exit code of deployment to handle it properly and mark the process as failed.**

The `build` hook is executed outside of the container so any exit code can easily stop the process. In the meantime `deploy` hook works in a different way and is being executed inside the container which means there's no easy solution for the Platform.sh to pass it out to the level where it can be handled.

Here is what [Damien Tournoud](https://twitter.com/damz), Platform.sh CTO says:

> There is no way to fail the deployment if the deploy hook fails. It runs  deep inside the deployment process and we don't have a way to bubble up the return code at this point. We have on our roadmap to change the deployment process to allow that, but I cannot give you an ETA for it.

In other words, deployment goes smooth and silently despite the errors. Thus you might mistakenly believe your environment was constructed correctly, but to affirm this you would need to go to the container via SSH and manually ensure there are no errors in [/var/log/deploy.log](https://docs.platform.sh/development/logs.html#deploylog).

## Solution

### Preamble

At the `deploy` stage we can know exit codes on the level where our hook is executed - inside the container. Since the process cannot go out the container, allowing Platform.sh to gracefully track the errors, we can use MariaDB to set a special flag in the database in case if any of processes returns a non-zero exit code.

### Hooks definition

Here is the part of [.platform.app.yaml](https://docs.platform.sh/configuration/app-containers.html) for declaring the hooks.

```yaml
hooks:
  build: 'bash scripts/.platform/hooks/hook.sh build'
  deploy: 'bash scripts/.platform/hooks/hook.sh deploy'
```

The `.platform` directory in a project root isn't available on Platform.sh environments during `deploy` so that's why we create the same-named subdirectory inside the `scripts` and store our custom scripts there.
{: .notice--info}

### hook.sh: implementation

The `scripts/.platform/hooks/hook.sh` is general and all you have to modify per project is the `APP_DIR_RELATIVE` and `PROCESS_SUBDIRS` (read the description for each of them in the code).

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

### hook.sh: process

Within the `scripts/.platform/hooks/<ACTION>` you may consider creating two handlers:

  - `_succeeded.sh` - the file that will be included in a runtime once all commands in a process successfully end.
  - `_failed.sh` - the same as above, but only after first non-zero exit code (a process will be terminated).

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

  [Platform.sh automatically processes the `composer.json`](https://docs.platform.sh/configuration/app/build.html#php-composer-by-default) in a root directory of a project but the `crawler` is a subproject with its own dependencies so we're building them separately.
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

You may see Drupal 8 is used here and we're creating some state for it. Now we need the logic around it, in order to handle deploy failure elegantly. To tackle this we add the HTTP middleware to read the state and deduce a project out of work.

### Drupal 8 HTTP middleware

- `PROFILE_OR_MODULE.services.yml`

  ```yaml
  services:
    PROFILE_OR_MODULE.http_middleware.platformsh:
      class: Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShMiddleware
      arguments:
        - '@state'
      tags:
        - name: http_middleware
          # Should be the first to fail early.
          priority: 1000
  ```

- `src/HttpMiddleware/PlatformShMiddleware.php`

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
  class PlatformShMiddleware implements HttpKernelInterface {

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

- `tests/Unit/HttpMiddleware/PlatformShMiddlewareTest.php`

  ```php
  namespace Drupal\Tests\PROFILE_OR_MODULE\Unit\HttpMiddleware;

  use Drupal\Core\State\StateInterface;
  use Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShMiddleware;
  use Drupal\Tests\UnitTestCase;
  use Symfony\Component\HttpFoundation\Request;
  use Symfony\Component\HttpKernel\HttpKernelInterface;

  /**
   * Tests "platformsh" HTTP middleware.
   *
   * @coversDefaultClass \Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShMiddleware
   * @group PROFILE_OR_MODULE
   */
  class PlatformShMiddlewareTest extends UnitTestCase {

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
     * @var \Drupal\PROFILE_OR_MODULE\HttpMiddleware\PlatformShMiddleware
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
      $this->middleware = new PlatformShMiddleware($this->app, $this->state);
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
        ->with(PlatformShMiddleware::MARKER)
        ->willReturn(TRUE);

      $this
        ->expectOutputRegex('/' . PlatformShMiddleware::MESSAGE . '/');

      $this->middleware->handle($this->request);
    }

  }
  ```

## Conclusion

The Platform.sh provides a good service with unique container dedication and configuration flexibilities. However, there are some issues like this that didn't get an attention yet.

I was also trying to use it as continuous integration tool but it really built in a way to stop you from doing this. For instance, you can't have Xdebug installed in some environments to generate PHPUnit coverage reports. If you are adding something - it will be added everywhere. Everywhere means `master` environment too.

The PHPUnit or Behat tests, PHPCS or HTMLCS checks etc. cannot be run during the `build` but can during `deploy`. When the `build` has passed it means an application is ready for usage, therefore failed tests won't help it to stay in the previous, working state. You even won't know something went wrong unless check the logs manually via SSH.

Concluding the article, I would say it is better to use dedicated CI instruments for achieving continuous delivery to Platform.sh and don't try to put everything on its shoulders. At the bottom line, Platform.sh - is an amazing cloud service for web applications, but it has nothing in common with CI.

*Thanks to [Mikhail Sokolovskiy](https://github.com/lokeoke) and [Roman Liashenko](https://github.com/sirko) who have helped in reviewing this article.*
{: .notice}
