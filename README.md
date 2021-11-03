pactivate
=========

`pactivate` needs to know the _base directory_ (BASE) for the project
(so it can find configuration files) and the _build directory_ under which
it will store the bootstrap files and the virtual environment that it
creates.

BASE defaults to the directory in which `pactivate` resides. (It's usual to
put `pactivate` in the root of the project if developers source it from the
command line.) BUILD is `$BASE/.build/` by default. These may be changed
with the `-B` and `-b` options respectively.

Here's summary of the files and directories used by `pactivate`:

    $BUILD/
    ├ bootstrap/pactivate/  Independent copies of pip and virtualenv
    └ virtualenv/           Virtual environment created for the project
    $BASE/
    ├ .python               Python interpreter (or symlink) to use
    └ requirements.txt      Packages to be installed in the project virtualenv

`pactivate` command-line options:
- `-b BUILD`: Set the build dir
- `-B BASE`: Set the base dir
- `-q`: Run programs in quiet mode to reduce output verbosity

You can use a different python interpreter by symlinking `$BASE/.python` to
your interpreter of choice. This is not normally commited, but is in $BASE
so that it persists even after `rm -rf $BUILD` to do a fully clean build.


Developer Notes
---------------

The tests are run with `./Test`. You can use `./Test -q` to produce
significantly less output, but this usually makes idenitifying problems
significantly more difficult.

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
