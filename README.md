# scm


### About

This is a tool to build, test, and deploy your projects to either another
server or to a [clone](https://github.com/plockaby/clone) system for deployment
by `clone`.

**NOTE:** This project is no longer being developed.


### Installing

The installation for `scm` is not the most standard. Configuration files must
be written before it can be deployed. So follow these steps to get those
created.

1. Copy `bin/config.example` to `bin/config`. You can change the paths in here
   for things like `ssh` and `rsync`. However, there is are a few specific
   configuration value that MUST be set:

     * `CLONE_BASE_DIR` is the path on your clone system (see
       [clone](https://github.com/plockaby/clone)) to where all sources can be
       found. This should be set to something like `/clone/sources`.

     * `CLONEDIR` is the default clone source directory to use on the `clone`
       system when deploying projects. This might be something like
       `scm/common` and is appended to the `CLONE_BASE_DIR`. This should
       generally be set by the project's `.scmrc` file but you can set a
       default value here.

     * `HOSTDIR` is the default directory on the remote host to which projects
       will be deployed. This might be something like `/srv/www` and, when
       deploying to the `clone` system will be appended to `CLONEDIR`. This
       should generally be set by the project's `.scmrc` file but you can set
       a default value here.

     * `HOSTUSER` is the default user on the remote host that the project will
       be deployed as. This user must be one that the user can `sudo` to. This
       might be something like `www` or `ops`. This should generally be set by
       the project's `.scmrc` file but you can set a default value here.

2. Copy `bin/servers.example` to `bin/servers`. Here is where you set all of
   the servers to which you might deploy manually. There is only one required
   server on this list:

    * `server_clone` should be to the hostname of the server where the `clone`
       system is installed.

3. You can decide to either deploy your project to the `clone` system so that
   it may be deployed later using `clone` or to deploy it to a host to start
   using now.

    * To deploy to the local host you can run this:

          make live

      That will deploy the project to the same system on which you are
      currently running. It will do the deployment without using `ssh` but it
      will use `sudo`.

    * To deploy to a host defined in `bin/servers` you can run this:

          make live_some-host

      That will deploy the project to the system defined in your server
      configuration list. It will do the deplyment with `ssh` and then using
      `sudo` on the remote side.

    * To deploy to the `clone` system you can run this:

          make clone

      That will deploy the project to the defined `clone` host using `ssh` and
      then `sudo` on the other side.


### Using

To use `scm` to deploy your project, you need to create a file called `.scmrc`
in the root directory of your project. Decide what type of deployment you need
to have. Only one type of deployment is included.

* copy

  This type of deployment is for just straight up copying the files in the
  project to the remote location. The default only copies three directories:
  `bin`, `lib`, and `etc`. Examples of how to copy others are detailed below.

  Here is an example `.scmrc` using the `copy` deployment type that will put
  your project into the `scm/common` directory on your `clone` system:

      CLONEDIR=scm/common
      HOSTDIR=/srv/www
      HOSTUSER=www
      include $(SCMDIR)/actions/copy.makefile

  You can make it copy more than just `bin`, `lib`, and `etc`. To make it also
  copy the `web` directory, for example:

      DEPLOY_web=$(BUILD_DIR)/web
      SUBDIRS=bin lib etc web

  To override where files go -- for example, to have files in the project's bin
  directory deploy to foobar/bin -- you can use this example:

      DEPLOY_bin=$(BUILD_DIR)/foobar/bin

After configuring your project's `.scmrc` file you can run these commands:

    scm build
    scm test
    scm archive

To ultimately deploy your project you can run, from your project's directory:

    scm clone
    scm live
    scm live_server-name

In the first example, your project will be sent to the `clone` system. In the
second example, your project will be deployed to the local host, and in the
third example your project will be sent to the server defined in `bin/servers`
with the name `server-name`.


### Extending

This project is just a series of Makefiles and can be extended very easily
through new actions and new plugins. Because of the global nature of Makefiles,
the following variables are available in all plugins and actions. Any variable
in bold can be overridden on the command line or in your plugin or action.

* `$(SCMDIR)` This is the full path to where `scm` is found.
* `$(CURDIR)` This is the full path to the current directory from where `scm`
  was called.
* `$(CONTAINMENT_DIR)` This is the root path where `scm` does its work.
* `$(TEMP_DIR)` The full path to a temporary directory that may be used when
  `scm` is doing its work.
* `$(BUILD_DIR)` The full path to the directory from where the project is
  built.
* `$(RELEASE_DIR)` The full path to the directory where the release will be
  created. Basically, anything that goes in here will be deployed when the
  project is deployed.
* `$(TEST_DIR)` The full path to the directory where test output is sent.
* `$(ARCHIVE_DIR)` The full path to the directory where archives created by the
  archive task will be stored.
* **`$(PROJECT_NAME)`** The name of the project derived from the name of the
  git directory.
* `$(GIT_ROOT)` The full path to the root of the git repository in which the
  project is contained.
* `$(ARCHIVE_FILE)` The name of the archive created when running the archive
  task.
* `$(ARCHIVE)` The full path to the archive created when running the archive
  task.
* **`$(TAR_X_FLAGS)`** Flags to pass to `tar` when extracting a tar archive.
* **`$(TAR_C_FLAGS)`** Flags to pass to `tar` when creating a tar archive.
* **`$(RSYNC_FLAGS)`** Flags to pass to `rsync`.
* **`$(CLONE_BASE_DIR)`** The root clone source directories.
* **`$(CLONEDIR)`** The clone source directory to use when deploying to
  `clone`.
* **`$(HOSTDIR)`** The directory to deploy your project to on remote systems.
* **`$(HOSTUSER)`** The user to `sudo` to when deploying to remote systems.
* **`$(GIT)`** The path to the `git` program.
* **`$(TAR)`** The path to the `tar` program.
* **`$(RSYNC)`** The path to the `rsync` program.
* **`$(SUDO)`** The path to the `sudo` program.
* **`$(SSH)`** The path to the `ssh` program.

You can change the functionality of deployments using the following options:

* `DEBUG=1` By default, the actual commands called are hidden. If you set this
  flag then you can see very single command executed by `scm`.
* `NO_TAG=` By default, before projects are sent to `clone`, `scm` will check
  to see if the project is clean and tagged. Sometimes it is desirable to
  deploy anyway. Setting this flag will bypass the tag check.

The `build`, `test`, and `archive` steps of the build process have "pre" and
"post" hooks that can be implemented by actions and plugins to add
functionality to the build process. If there are multiple hooks there is no
guarantee of the order in which the hooks will be run. To use a hook, write in
your action or plugin a block that looks like this:

    .PHONY: post_archive_hook
    post_archive_hook::
        echo "doing work before the archive has been created"

    .PHONY: post_archive_hook
    post_archive_hook::
        echo "doing work after the archive has been created"

Similarily, there is a `pre_build_hook`, `post_build_hook`, `pre_test_hook`,
and `post_test_hook`.


#### Actions

Any file put into the `actions` directory can be used as a new deployment type.
There is no particular naming convention or strategy. It's just a standard
Makefile.


#### Plugins

Any file put into the `plugins` directory will be loaded every time `scm` is
run. The files must be named `scm.whatever.plugin` in order to be found.


### Prerequisites

This software requires:

* GNU Make
* rsync
* GNU tar
* git


### Credits and Copyright

This project is a derivation of a similar project created and used internally
by the University of Washington Information Technology Computing Infrastructure
division. The code seen here was created by Paul Lockaby with the help of
Benjamin Roy, Joby Walker, and others.
