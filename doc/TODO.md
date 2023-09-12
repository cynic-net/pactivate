To Do
=====

### Bugs and Infelicities

- On Python 3.1.12, during `Installing bootstrap pip` we see a warning,
  `DeprecationWarning: The distutils package is deprecated and slated for
  removal in Python 3.12.` This appears to be due to our `"$__pa_python" -c
  'import distutils.cmd' || ...` used to generate a nice error message if
  distutils isn't installed (because we expect a failure in Python ≤3.11 if
  it's not). Probably what we need is a Python version test around that
  `import distutils.cmd` test.

- If the path given to `pae` has a `pactivate` in it, that should be used
  instead of the default `pactivate` that `pae` downloads. (This ensures
  that it functions the same way as the build system presumably using that
  `pactivate`, and allows testing with older and newer versions of
  `pactivate`.)

### Features

- On Windows (MinGW) the default Python interpreter (when there is no
  `$BASE/.python` link) should be `py`, not `python3`.

### Consider

- Some commands in `pactivate` remain untested, and some even can't be
  tested, such as the current `curl` command because it's in a pipeline
  and we can't guarantee that `-o pipefail` is enabled. Consider whether
  we need to test all of these explicitly for better error messages.

### Bugfixes that may not be worth the added complexity

- .python, if it exists, must always point to a valid Python interpreter or
  pactivate will fail even if the virtualenv has a valid Python interpreter
  (and thus pactivate doesn't need one).

- If .python points to a different interpreter than virtualenv/bin/python
  and the .python interpreter requires a separate bootstrap (e.g., it's 2.7
  and the virtualenv is 3.9), the separate bootstrap will be setup first,
  even though it's not used. This both wastes time and makes the warning
  message less obvious because it comes at the end of a (possibly very
  large) pile of text.
