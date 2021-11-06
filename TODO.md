To Do
=====

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
