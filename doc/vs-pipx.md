Comparison of pae vs. pipx
==========================

pae and [pipx] both build and use virtual environments; pipx differs
primarily in that it's focused on running Python command-line programs.
Though pae does this as well, it doesn't do it quite so conveniently. In
particular, pipx has the following advantages:

- pipx works from any shell, not just Bash.
- `pipx install PACKAGE` adds links for all command-line programs in
  _PACKAGE_ (but not its dependencies) to a directory (`~/.local/bin/`) in
  your existing $PATH, allowing you to type simply `grip` after a `pipx
  install grip`. pae makes you type `pae grip` instead.
- `pipx run` creates ephemeral virtual environments that are removed after
  the program is run. (This is obviously slower to start the program than
  using an installed environment.) With pae you must manually remove an
  environment after running your program if you don't want it after that.
- `pipx install`, after the first time you run it, will be create virtual
  environments faster than pae (`pae -c ENV`) because pipx re-uses the
  existing `pip` and `venv` packages whereas `pae` re-downloads and
  re-installs them every time. (Package installs after that are the same
  speed.)

pae is focused more on general use of virtual environments, and so has the
following advantages over pipx:

- It can more easily run any command-line program in a virtual environment,
  using `pae ENV PROGRAM` or, when the program and environment name are the
  same, `pae PROGRAM`. With pipx, you need to give the full path to the
  virtual environment for programs that did not have links installed:
  `~/.local/share/pipx/ENV/bin/PROGRAM`.
- pae more easily supports having different versions of packages and Python
  by creating different virtual environments for them. E.g., you can have
  `pae grip4-py12 grip` and `pae grip3-py8 grip` run two different versions
  of `grip` under two different versions of Python.
- It can more easily activate a virtual environment using `pae -a ENV`.
  With pipx you need to `source ~/.local/share/pipx/ENV/bin/activate`.
- pae uses [pactivate], which can work better to support development in a
  code repository.

Further, pae is smaller and has fewer dependencies than pipx (even when
pipx is used as a [zipapp] with `python3 pipx.pyz ...`) and supports more
environments:

- pipx runs only on Python versions ≥3.8. pae supports Python 2.7 and
  Pythons 3.4 upward.
- pae always uses the latest [`virtualenv`] package, not the `venv` subset
  used by pipx. As compared to `venv`, `virtualenv` is faster, more
  extensible, has a richer programmatic API and gets bug fixes and new
  features more quickly.
- pae requires only a small subset of the Python standard library which is
  usually provided entirely by the minimal Python package in most Linux
  distributions.
  - pipx requires `venv` which, on systems such as Debian/Ubuntu, requires
    installation of the OS `python3-venv` package.
  - pae requires extra packages only on Debian 11/Ubuntu 21.10 and below,
    where it requires the OS `python3-distutils` package.

### Command Comparison

Here are some common pipx commands and their pae equivalents:

      pipx                      pae
      ──────────────────────────────────────────────────────
      pipx install PKG          pae -c PKG PKG
      PKG                       pae PKG
      pipx list                 pae -l
      pipx inject APKG BPKG     pae APKG pip install BPKG
      ─                         pae PKG PROG       # run another program in PKG

If the executable name doesn't match the package name, pae can handle this
by letting you use the executable name as the virtual environment name:
`pae -c PROG PKG`, so `pae PROG` will run that program. It's not clear to
me how to do this with pipx.


<!-------------------------------------------------------------------->
[`virtualenv`]: https://virtualenv.pypa.io/en/latest/
[pactivate]: https://github.com/cynic-net/pactivate
[pipx]: https://pipx.pypa.io/
[zipapp]: https://pipx.pypa.io/stable/installation/#using-pipx-without-installing-via-zipapp
