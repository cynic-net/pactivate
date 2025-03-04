pactivate
=========

`pactivate` is a wrapper for [virtualenv]'s `activate` script that will
additionally create a virtual environment if one does not already exist. It
uses the standard Pip from [pypa.io] and virtualenv from [PyPI], so it
depends on the OS (or you) providing only a Python interpreter, such as the
Debian `python-minimal` package, and does not touch the system environment
at all. It works with any version of Python supported by [`get-pip.py`],
i.e., 2.7 onward.

A `pae` Bash shell function that provides functionality similar to
[virtualenvwrapper], [pipx] and the like is also provided. See the
[pae documentation][pae] and the [`pae`](./pae) file for details. There
is also a [detailed comparison with pipx][vs-pipx].

This documentation assumes you already have a general understanding of
[virtualenv] virtual environments and know how to use the [`activate`]
script.

#### Dependencies

When creating a virtual environment, the bootstrap process uses the latest
versions of virtalenv and Pip from the 'net; any local copies are ignored.
The only local dependency is a Python interpreter itself and its standard
library. This may be supplied by your OS distribution, third-party
packages, or your own build from source (e.g., with [`pythonz`]).

Note that some Linux distributions, such as Debian and Ubuntu, do not
supply the full set of standard libraries in their `python3` package. For
these systems you may need to run `apt-get install python3-distutils` to
add that standard library. (This depends on the Python version; it's
required for 3.9 but not for 3.10.)

This does _not_ use the [`venv`] module that became part of the Python
standard library in version 3.3. This is for two reasons: `venv` is not
available in earlier versions of Python, such as 2.7; and, as [described in
the virtualenv documentation][virtualenv], `venv` is a stripped-down (and
slower) version of `virtualenv` that doesn't receive updates as often.

### Contents

- Basic Usage
- Directories and Options
- Theory of Operation
- Developer Notes


Basic Usage
-----------

The most common way of using this is to copy the `pactivate` script into
your project directory and have your build/test script source it before
performing its other actions. For example:

    $ git init myproject
    $ cd myproject
    $ curl -O https://raw.githubusercontent.com/cynic-net/pactivate/main/pactivate
    $ git add pactivate
    $ git commit -m 'pactivate: from https://github.com/cynic-net/pactivate'

(Note that the `curl` command above can be replaced with `pae -D` if you
are using `pae`.)

At this point you can [source] `pactivate` just as you would the
[`activate`] script from virtualenv to modify your shell environment to be
using the Python virtual environment:

    source ./pactivate -q       # Leave off `-q` if you want verbose mode

This will build a virtual environment in `.build/virtualenv/` if necessary
and then source the `.build/virtualenv/*/activate` script provided by
virtualenv. That does the usual virtualenv setup for your shell: running
`python` will give you the virtual environment's version, `pip list` will
list all the packages installed in the virtual environment, and so on. Also
as usual, type `deactivate` (or `pae -d`) to restore your previous shell
environment.

See "Directories and Options" below for more information on the directory
structure and how to change it.

### Installing Dependencies

If the virtual environment is not already set up and a `requirements.txt`
file exists in the project directory (usually the same directory as the
`pactivate` script), the modules listed there will be installed in the
virtual environment after it's been created. That file uses the [standard
format][req] accepted by `pip install -r`.

If you modify `requirements.txt`, you can manually (re-)install the
requirements with `.build/virtualenv/bin/pip install -r requirements.txt`.
You may also simply remove the virtual environment with `rm -rf
.build/virtualenv/` and let it rebuild the next time `pactivate` is run.

### Test Scripts

Typically you want to have a test script activate the virtual environment
before running tests. Here's a sample script, called `Test`, that finds the
project directory (assuming that it lives in the root of it), checks for a
`-q` option to pass on to `pactivate` (ignoring any other options), and the
sets up the environment before running the tests.

    #!/usr/bin/env bash
    set -eu -o pipefail     # Generally, fail on unchecked errors

    #   Find the directory in which this script resides, allowing
    #   this script to be run from any current working directory.
    export PROJDIR=$(cd "$(dirname "$0")" && pwd -P)

    #   Set `quiet=-q` if we have a -q in our command-line arguments.
    args_words_regex="^($(IFS=\|; echo "$*"))$"   # -i -q → ^(-i|-q)$
    quiet=; [[ -q =~ $args_words_regex ]] && quiet=-q

    #   Set up and use the virtual environment using default paths:
    #   • The project directory is the one in which `pactivate` resides.
    #   • The build directory is `.build/` under the project directory,
    #     with the Python virtual environment in `.build/virtualenv/`.
    #   • Pass on `-q` for quiet mode if we were run with that.
    source "$PROJDIR/pactivate" $quiet

    #   Here we run the build, tests or whatever else we need to do.
    pip --version           # Runs .build/virtualenv/bin/pip
    cd "$PROJDIR"           # If you don't want to use absolute paths

The developer can then type `./Test` (or whatever the appropriate relative
or absolute path to it is) to run the build/tests/etc., with the Python
virtual environment being created as necessary.


Directories and Options
-----------------------

`pactivate` needs to know the _project directory_ (PROJDIR) for your project
(so it can find configuration files) and the _build directory_ under which
it will store the bootstrap files and the virtual environment that it
creates.

PROJDIR defaults to the directory in which `pactivate` resides. (It's usual to
put `pactivate` in the root of the project if developers source it from the
command line.) BUILD is `$PROJDIR/.build/` by default. These may be changed
with the `-B` and `-b` options respectively.

### Files and Directories

    $PROJDIR/
    ├ .python               (Optional) Python interpreter for the virtualenv
    └ requirements.txt      (Optional) Package list for the virtualenv

    $BUILD/
    ├ bootstrap/pactivate/  Independent copies of pip and virtualenv
    └ virtualenv/           Virtual environment created for the project

If it exists, `$PROJDIR/.python` (which is typically a symlink) is used
only to install a new virtualenv when there isn't an existing one. Changing
this after the virtualenv has been built will not change the interpreter
used in the existing virtualenv.

### Command-line options

- `-b BUILD`: Set the build dir
- `-B PROJDIR`: Set the project dir (sometimes called the "BASE" dir)
- `-i`: Enter interactive shell in container after the test completes
- `-q`: Run programs in quiet mode to reduce output verbosity

You can use a different python interpreter by symlinking `$PROJDIR/.python` to
your interpreter of choice. This is not normally commited, but is in $PROJDIR
so that it persists even after `rm -rf $BUILD` to do a fully clean build.


Theory of Operation
-------------------

The general plan is that we create a bootstrap directory,
`$BUILD/bootstrap/pactivate/`, into which we install the `virtualenv`
package, and then use that `virtualenv` package to create the virtual
environment.

Note that the bootstrap directory, though it looks similar to the virtual
environment directories created by `virtualenv`, is much more limited. In
particular, it depends on the user correctly setting up the runtime
environment (usually with the `PYTHONPATH` environment variable, etc.)
before loading or executing any of the bootstrap files.

1. pactivate determines which Python version is being used and fetches the
   appropriate version of `get-pip.py` from pypa.io. (Pythons ≥3.6 all use
   the latest version of that script; earlier versions of Python have their
   own versions of that script.) If not using the latest version, the
   `$BUILD/bootstrap/pactivate` directory will have the version number
   appended to it. (This is necessary to avoid using the wrong version of
   Pip if the user changes to a different Python version after running the
   bootstrap once.)
2. pactivate runs `get-pip.py`, directing it to install Pip to the
   bootstrap directory. This also installs Pip's dependencies, `setuptools`
   and `wheel`.
3. pactivate then uses that version of Pip to install the `virtualenv`
   module to the same bootstrap directory.
4. pactivate uses the `virtualenv` package from the bootstrap directory to
   create the `$BUILD/virtualenv` virtual environment. `virtualenv`
   installs `bin/activate`, `bin/python`, `bin/pip`, etc. into that
   directory.

This new virtual environment provides all the usual environmental setup to
make sure it's used for any programs run from it. That is, running
`$BUILD/virtualenv/bin/pip` will use that virtual environment's Pip, as
opposed to some other version of Pip installed in a more standard place on
the system.

"Developer Notes" below also contains some further details on how the script
works and some of the constraints it must deal with.


Developer Notes
---------------

The test scripts are under `tscript/`; these can be run individually or all
run in sequence for a default set of test images using the top-level `Test`
script. The test scripts are summarised below.

Some tests are run in a Docker container to ensure that `pactivate` does
not accidentally use an existing installation of `pip` or `virtualenv`. For
these you may be prompted for your sudo password in order to run Docker as
root. If you don't want to use `sudo` you can create a `.no-sudo` file in
base directory of the project (repo). See below for more information on
this.

### Test Scripts

* `tscript/pactivate-test-docker` uses data files under `tscript/docker-data/`
  to set up a Docker image and run the `pactivate` tests within a container.
  It requires a single argument giving the name of the image on which to
  base the test image, e.g., `debian:11`.
  options.

* `tscript/pae-test` tests the `pae` program; this does not require Docker.

All test scripts also have the following optional arguments, that must
appear before any required arguments. Inapplicable optional arguments for a
particular test script (e.g., `-i` for `pae-test`) are ignored.
- `-q`: Quiet mode. Produces significantly less output, but can make
  identifying problems more difficult.
- `-i`: Interactive mode. When the tests exit (whether via successful
  completion or a failure) a shell is started in the test container. This
  allows for interactive investigation of problems or simply playing with
  the script.

### Implementation Notes and Gotchas

`pactivate`, being sourced, runs in a special environment:
1. We cannot use `exit` because that will exit the calling script (or worse
   yet, close the window of the user that sourced the script at the command
   line). However, in a sourced script `return` will abort execution of the
   remainder of the sourced script, and the source command will return the
   exit code given to `return`.
2. We are constrained by the environment set by the calling script (or in
   the calling user's shell). For example, the `-e` option may or may not
   be set, so we can't rely on untested commands stopping execution. We
   also cannot use `trap` for any cleanup because a) we're only a fragment
   of a script, so we never exit, and b) it would override any `trap`
   setting in a calling script.

### Sudo for Docker

The `Test` script normally runs `docker` with `sudo` and so will prompt for
your sudo password if sudo requires one and your sudo credentials are not
already cached.

The reason for using sudo is that not all system administrators use a
`docker` group. Being able to control the Docker daemon with the `docker`
command [grants full root privileges to any user that can run
it][docker-is-root], so some admins prefer to dispense with the `docker`
group and just make it clear (via putting the user in the `sudo` group)
that the user has root access.

If you can't use `sudo` (or don't want to), `Test` can be configured not to
use it by creating a file `.no-sudo` in the same directory as `Test`. (The
contents of this file are ignored.)



<!-------------------------------------------------------------------->
[PyPI]: https://pypi.org/
[`activate`]: https://virtualenv.pypa.io/en/latest/user_guide.html#activators
[`get-pip.py`]: https://github.com/pypa/get-pip
[`pythonz`]: https://github.com/saghul/pythonz
[`venv`]: https://docs.python.org/3/library/venv.html
[docker-is-root]: https://docs.docker.com/engine/security/#docker-daemon-attack-surface
[pae]: ./doc/pae.md
[pipx]: https://pipx.pypa.io/
[pypa.io]: https://www.pypa.io/en/latest/
[req]: https://pip.pypa.io/en/stable/reference/requirements-file-format/
[source]: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-_002e
[virtualenv]: https://virtualenv.pypa.io/
[virtualenvwrapper]: https://pypi.org/project/virtualenvwrapper/
[vs-pipx]: ./doc/vs-pipx.md
