To Do
=====

Features:
- We should compare `$__pa_python` to `$__pa_builddir/virtualenv/python`
  and emit a warning if they're not the same. (We don't want to just
  rebuild the virtualenv because it might have been built manually for
  testing purposes.)
- On Windows (MinGW) the default Python interpreter (when there is no
  `$BASE/.python` link) should be `py`, not `python3`.

Consider:
- Some commands in `pactivate` remain untested, and some even can't be
  tested, such as the current `curl` command because it's in a pipeline
  and we can't guarantee that `-o pipefail` is enabled. Consider whether
  we need to test all of these explicitly for better error messages.
