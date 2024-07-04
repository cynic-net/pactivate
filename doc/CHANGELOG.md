Changelog
=========

This file follows most, but not all, of the conventions described at
[keepachangelog.com]. Especially we always use [ISO dates]. Subsections or
notations for changes may include Added, Changed, Deprecated, Fixed,
Removed, and Security.

Version numbers are [_major.minor.patch_][semver]. On any change to
pactivate itelf (not the tests), `-current` is appended to the version
number and stays there until the next release, when `-curent` is removed
and the version number is bumped. (Not all releases are tagged, but
specific releases can also be fetched via the Git commit ID.)

### -current
- Test framework: On Debian use python3-minimal instead of python3

#### pactivate 0.5.3 (2024-04-14)
- Fixed: Python 3.7 now uses its own alternate version of get-pip.py as
  newer versions no longer support 3.7.

#### pactivate 0.5.2 (2024-04-14)
- Added: Support for running on Windows under MINGW.
- Fixed: Support scripts installed by virtualenv under $venv/Scripts/ (as
  used on Windows) as well as $venv/bin/ (as used on Linux).
- Fixed: Use `python -m pip` instead of `pip` for bootstrap virtualenv
  package install because if you use `pip.exe` under Windows, it locks that
  file and then dies because it can't replace it.
- Test framework: Add `local-test` script to run a test in the current
  environment, rather than a in Docker container. The build directory
  for the test is `.local-test/`. This now allows testing under Windows
  (though just for pactivate, not for pae).

#### pae 0.8.2 (2024-01-24)
- Fixed: Heisenbug involving `pae . python ...` not correctly setting up
  virtual environment due to adjacent slashes in the path to bin/python.

#### pae 0.8.1 (2024-01-23)
- Fixed: `pae -p PATH` now handles $PATH searches, e.g., `pae -p python2`.
- Fixed: `pae --rm` no longer leaves fles behind for Pythons ≤3.6.
- Added: `pae -c NAME PKG ...`; an optional list of package specs after the
  name will add those packages to the virtualenv after creation.

#### pae 0.8.0 (2024-01-23)
- Changed: Now use `pae -p PATH -c ENVNAME` to specify a non-default Python
  interpreter for the new virtual environment. (`pae -c ENVNAME PATH` is no
  longer supported.) This is also checked to see if it runs some very basic
  Python code with -c.

#### pae 0.7.0 (2024-01-20)
- Changed: -c option now does not leave virtualenv activated
- Added: -C option to leave new virtualenv activated

#### pae 0.6.0 (2024-01-16)
- Added: `pae -c` now takes an option parameter for an alternate Python
  interpreter.

#### pactivate 0.5.1 (2024-01-16)
- Fixed: New fix for curl timeout failures: retry forcing IPv4.

#### pactivate 0.5.0 (2024-01-12)
- Fixed: Now works with Python 3.12, and no more distuils warning on 3.11.
- Fixed: Longer timeouts and more than one retry for curl.
- Test framework: Do not try to test distutils check on newer versions of
  Debian and Ubuntu where distutils is deprecated/removed.
- Test framework: Do not attempt to install and test python2 on recent
  Debian/Ubuntu systems that do not have a `python2` package.
- Test framework: Add `debian:12` and `ubuntu:23.10`.

### pactivate 0.4.0 (2023-10-31)
- Added: If `python3` is not available, we try `python` as well. (Under
  Windows/MINGW it will first try `py` before these two, but this is
  untested.)

### pactivate 0.3.6 (2023-10-31)
- Fixed: remove spurious re-install of boostrap pip on first run after
  bootstrapping.
- Test framework: Now works with Docker's "official" Python Alpine images
  and probably (with a few more tweaks) other Linux distributions. Various
  other fixes and improvements as well.

### pae 0.5.3 (2023-09-11)
- Changed: Now `pae .` is treated like `pae ./`.
- Added: New `doc/` subdir; initial version of `doc/pae.md`.

### pactivate 0.3.5, pae 0.5.2 (2023-09-11)
- `pae` added.
- Various other changes.

#### pactivate 0.3.2 (2023-06-24)
`pactivate`:
- Fixed: Suppress several spurious warnings.
Test Framework:
- Fixed: In Docker container, suppress Pip's warnings about running as root.
- Added: `Test` now runs docker without `sudo` if `.no-sudo` file present.
- Added: (Linux) Docker container now started properly when `Test` is run
  from MINGW Bash on Windows.

#### 0.3.1 2022-09-27
- Fixed: No longer overwrite calling shell's $ve and $pa vars.
  (This happened only rarely.)

#### 0.3.0 2022-09-24
- Fixed: For Python 3.6, use a versioned `get-pip.py` instead of the default
  (latest) version. This probably changed when 3.6 was deprecated.



<!-------------------------------------------------------------------->
[keepachangelog.com]: https://keepachangelog.com/
[ISO dates]: https://xkcd.com/1179/
[semver]: https://en.wikipedia.org/wiki/Software_versioning#Semantic_versioning
