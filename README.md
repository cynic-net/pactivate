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

This does _not_ use the the [`venv`] module that became part of the Python
standard library in version 3.3. This is for two reasons: `venv` is not
available in earlier versions of Python, such as 2.7; and, as [described in
the `virtualenv` documentation][virtualenv], `venv` is a stripped-down (and
slower) version of `virtualenv` that doesn't receive updates as often.

### Contents

- Directories and Options
- Theory of Operation
- Developer Notes


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
2. pactivate runs `git-pip.py`, directing it to install Pip to the
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
[`pythonz`]: https://github.com/saghul/pythonz
[`venv`]: https://docs.python.org/3/library/venv.html
[docker-is-root]: https://docs.docker.com/engine/security/#docker-daemon-attack-surface
[virtualenv]: https://virtualenv.pypa.io/
