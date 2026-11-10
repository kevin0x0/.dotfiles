# Hook runtime

A hook is a POSIX sh script run by the session: it is sourced by the
session's shell (no shebang is needed), and its content is provided
according to the create mode ("command" text with a trailing newline
added, a copied file, or a linked file).

- Each hook runs in a subshell of its own: changes to variables and
  the working directory do not leak into other hooks or into the
  session.
- It runs synchronously and has no timeout: the session waits for it
  to finish, so keep hooks short; a hook that does not finish blocks
  the session.
- Hooks never run concurrently: the session runs them one at a time,
  event by event. The relative order of several hooks on the same
  event is unspecified.
- The hook inherits the session's execution environment and working
  directory. It receives no arguments and no standard input.
- Hooks are not re-entered: one hook's run never directly triggers
  another hook's run.
- The hook's exit status is ignored by the session. When the document
  of the relevant event describes the exit status handling, that
  description takes precedence.

# Symbols

Three names describe the run to the hook: llmcc_event holds the event
name, llmcc_hook_script the hook's own pathname (if relative, it is
relative to the current working directory), and llmcc_hook_log is the
logging function. llmcc_hook_get_my_state_dir <var> creates the
hook's own state directory when needed and stores its pathname in
<var>.

llmcc_hook_dump_vars <name>... prints one shell assignment per name,
in the order given, quoted so that the output can be sourced by a
POSIX shell to restore the values. An unset variable is printed as an
empty assignment; an invalid name is reported in the hook log and
skipped. Keep state by redirecting it into a file of the hook's own
state directory, and view values by redirecting it to standard error
(the hook log).

# Output and the hook log

- The hook's standard output goes to the user's terminal; it is not
  seen by the model. Its standard error is appended to the hook log;
  each line is prefixed with "[<event>/<hook name>] " (the full hook
  name, including the type suffix).
- llmcc_hook_log <level> <message>... writes "[<level>] <time>:
  <message>" lines to the hook log, one per line of a multi-line
  message. <level> is any word; INFO and ERROR are conventional. These
  are standard error lines, so each also gets the "[<event>/<hook
  name>] " prefix.
- The hook log has no size limit; read the dump with tail or grep.

# Life cycle

- A hook stays installed if its event is later uninstalled; it does
  not run while the event is uninstalled (the session only runs hooks
  for the events it emits), and it runs again if the event is
  reinstalled and emitted.
- Hooks exist only within the current session; there is no limit on
  the number of hooks. Each hook has a state directory of its own; it
  is deleted when the hook is removed, including after a "oneshot"
  hook has run.

# Environment

The documents of the relevant event describe its execution environment
(the variables, files and functions a hook can use). When such a
document describes something explicitly, it takes precedence over this
document.
