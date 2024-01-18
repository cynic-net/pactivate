pae: Execute Commands in and Manage pactivate Python Virtual Environments
=========================================================================

`pae` is a Bash shell function that creates, lists, activates, removes and
executes commands in Python virtual environments created by [`pactivate`].
This functionality is similar to that of [virtualenvwrapper] and [pipx];
see ["Comparison of pae vs. pipx"][vs-pipx].

### Installation

No files need be installed beyond making `pae` accessible somewhere. To
enable the function, source the `pae` file, with `source ./pae` or `. ./pae`
(replacing `./pae` with the path to wherever it happens to live on your
system). This is usually added to your `~/.bashrc`.

It's not necessary to have `pactivate` anywhere on your system; the first
time it's used, `pae` will download it. To update to the latest version of
`pactivate`, use `pae -U`.

`pae -h` will give brief usage information.


Motivation and Usage
====================

The most common use of `pae` is to set up separate environments for Python
applications and/or development (including with different versions of
Python). For example, to run `grip` (a GitHub-format Markdown preview
server), start by creating a new virtual environment:

    $ pae -c grip
    ----- Installing bootstrap pip (ver=latest)
    pip 23.2.1 from /home/cjs/.pyvirtenv/grip/.build/bootstrap/pactivate/pip \
      (python 3.9)
    ----- Installing bootstrap virtualenv
    ----- Building virtualenv
    Using python3
    Version: Python 3.9.2
    (grip) $ 

The virtual environment is now created and activated, and you can install
whatever you like without worrying about interference (including version
conflicts) with the system or user libraries you've installed:

    (grip) $ pip install grip
    Collecting grip
      Downloading grip-4.6.1-py3-none-any.whl (138 kB)
    ...
    Successfully installed Flask-2.3.3 Jinja2-3.1.2 Markdown-3.4.4 \
      MarkupSafe-2.1.3 Pygments-2.16.1 Werkzeug-2.3.7 blinker-1.6.2 \
      certifi-2023.7.22 charset-normalizer-3.2.0 click-8.1.7 docopt-0.6.2 \
      grip-4.6.1 idna-3.4 importlib-metadata-6.8.0 itsdangerous-2.1.2 \
      path-and-address-2.0.1 requests-2.31.0 urllib3-2.0.4 zipp-3.16.2
    (grip) $ 

Now, with the environment still activated, you could run it just by typing
`grip`. But usually the environment will not be activated, so for the
demonstration here we deactivate it:

    (grip) $ pae -d
    $ 

When the environment is not activated (as is usually the case), you can run
any command in an environment with `pae NAME COMMAND`. In this case the
environment and command name are the same, so we need give only one name.
(Note that after the command is done, the original environment is still in
place, not the activated virtual environment for that command.)

    $ pae grip --version
    Grip 4.6.1
    $ 

The environments in the standard location may be listed and removed:

    $ pae -l
    grip
    $ pae --rm grip
    $ pae -l
    $ 

The `--rm` option is careful _not_ to remove anything it did not install:

    $ pae -c tmp0
    ----- Installing bootstrap pip (ver=latest)
    ...
    (tmp0) $ pae -d
    $ echo 'my own stuff' >~/.pyvirtenv/tmp0/myfile
    $ tree -a -L 2 ~/.pyvirtenv/tmp0
    /home/cjs/.pyvirtenv/tmp0
    ├── .build
    │   ├── bootstrap
    │   └── virtualenv
    ├── README
    └── myfile
    3 directories, 2 files
    $ pae --rm tmp0
    rmdir: failed to remove '/home/cjs/.pyvirtenv/tmp0': Directory not empty
    Warning: non-pae files not removed.
    $ tree -f -a -L 2 ~/.pyvirtenv/tmp0
    /home/cjs/.pyvirtenv/tmp0
    └── /home/cjs/.pyvirtenv/tmp0/myfile
    0 directories, 1 file
    $ 


Additional Features
------------------

### Alternate Virtual Environment Locations

If the name includes a `/` (or is just `.` alone), that specific path will
be used instead of the user-global location for virtualenvs:

    $ pae -c ~/tmp/paetest0
    ----- Installing bootstrap pip (ver=latest)
    ...
    (paetest0) $ tree -a -L 2 ~/tmp/paetest0
    /home/cjs/tmp/paetest0
    ├── .build
    │   ├── bootstrap
    │   └── virtualenv
    └── README
    3 directories, 1 file
    (paetest0) $

This can be convenient in projects that use `pactivate` for their
build/test systems:

    $ git clone https://github.com/0cjs/bastok.git
    $ cd bastok
    $ ./Test
    ...
    $ pytest --version
    bash: pytest: command not found
    $ pae . pytest --version
    This is pytest version 5.4.3, imported from /home/cjs/co/public/gh/0cjs/bastok/.build/virtualenv/lib/python3.9/site-packages/pytest/__init__.py
    $

### Alternate Global virtualenv Locations

`pae` has a standard location for virtualenvs that are given just name,
not a specific path. See `pae -h` for details.

### Alternate Python Versions

XXX write me

### Virtualenvwrapper Compatibility

XXX write me


Pactivate Versions
------------------

`pae` uses `$PAE_HOME/pactivate` to create and activate virtual
environments. If not present, the latest version is downloaded from
github.com. You can update that version with `pae -U`:

    c$ pae -U
    ----- Downloading pactivate
    Current version: #   pactivate version 0.3.5
    Updated version: #   pactivate version 0.3.5



<!-------------------------------------------------------------------->
[`pactivate`]: https://github.com/cynic-net/pactivate
[pipx]: https://pipx.pypa.io/
[virtualenvwrapper]: https://pypi.org/project/virtualenvwrapper/
[vs-pipx]: ./vs-pipx.md
