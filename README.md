pactivate
=========


Developer Notes
---------------

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
