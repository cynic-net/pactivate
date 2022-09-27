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

#### -current
- Fixed: Suppress several spurious warnings in pactivate.

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