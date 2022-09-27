pactivate
=========

`pactivate` is a dependency-free script to create a Python [virtualenv]
for a project. (This documentation assumes you already know how to use
`virtualenv` virtual environments.)

It requires no modules outside of the standard library included with Python
itself. In particular it does not require `pip` or `virtualenv` modules
(and completely ignores any versions of those you may have installed in
your system or user environment); `pactivate` bootstraps the virtual
environment from the latest releases of these available on the Internet.
The only dependency is a Python interpreter itself. (This may be supplied
by your OS distribution, third-party packages, or your own build from
source, e.g., with [`pythonz`].)

Note that some Linux distributions, such as Debian and Ubuntu, do not
supply the full set of standard libraries in their `python3` package. For
these systems you may need to run `apt-get install python3-distutils` to
add that standard library. (This depends on the Python version; it's
required for 3.9 but not for 3.10.)

If used in a [MINGW] Windows environment (such as that provided by [Git for
Windows][gfw]), `pactivate` will find a default Python using the [`py`]
Python Launcher. (See below for how to set up `.python` links under
Windows.)

`pactivate` does _not_ use the the [`venv`] module that became part of the
Python standard library in version 3.3. This is for two reasons: `venv` is not
available in earlier versions of Python, such as 2.7; and, as [described in
the `virtualenv` documentation][virtualenv], `venv` is a stripped-down (and
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
    $ curl -O https://raw.githubusercontent.com/0cjs/pactivate/main/pactivate
    $ git add pactivate
    $ git commit -m 'pactivate: from https://github.com/0cjs/pactivate'

At this point you can [source] `pactivate` just as you would the
[`activate`] script from virtualenv to modify your shell environment to be
using the Python virtual environment:

    source ./pactivate -q       # Leave off `-q` if you want verbose mode

This will build a virtual environment in `.build/virtualenv/` if necessary
and then source the `.build/virtualenv/*/activate` script provided by
virtualenv. That does the usual virtualenv setup for your shell: running
`python` will give you the virtual environments version, `pip list` will
list all the packages installed in the virtual environment, and so on. Also
as usual, type `deactivate` to restore your previous shell environment.

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

__.python Link in Windows__

Unfortunately, while symlinks are available in modern versions of Windows,
they are [essentially unusable][gfw-symlinks] in most circumstances. (This
is why Git Bash `ln -s` copies files by default.) The developers are
currently considering other methods for specifying a specific Python
interpreter under Windows.

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

The tests are run with `./Test`. You can use the `-q` option to produce
significantly less output, but this usually makes idenitifying problems
significantly more difficult. The `-i` option will start an interactive
shell in the test container after the test completes or fails (the startup
message will give the exit code indicating success or failure) to allow for
interactive investigation of problems or simply playing with the script.

The tests are run in a Docker container to ensure that `pactivate` does not
accidentally use an existing installation of `pip` or `virtualenv`. The
`Test` script runs `docker` with `sudo` and so will first prompt for your
sudo password if sudo requires one and your sudo credentials are not
already cached. (The `docker` command [grants full root privileges to any
user that can run it][docker-is-root], so you should not use a "docker"
group; not granting sudo privileges to members of that group simply
disguises the fact that they have full root access anyway.)

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



<!-------------------------------------------------------------------->
[MINGW]: https://en.wikipedia.org/wiki/Mingw-w64
[`activate`]: https://virtualenv.pypa.io/en/latest/user_guide.html#activators
[`pythonz`]: https://github.com/saghul/pythonz
[`venv`]: https://docs.python.org/3/library/venv.html
[docker-is-root]: https://docs.docker.com/engine/security/#docker-daemon-attack-surface
[gfw-symlinks]: https://github.com/git-for-windows/git/wiki/Symbolic-Links
[gfw]: https://gitforwindows.org/
[py]: https://docs.python.org/3/using/windows.html#launcher
[req]: https://pip.pypa.io/en/stable/reference/requirements-file-format/
[source]: https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-_002e
[virtualenv]: https://virtualenv.pypa.io/
