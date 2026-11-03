# manage_hooks

Supplementary reference for managing session hooks. The tool description
covers the operations; this document explains the interface details.

# States

The session is a state machine. Hooks run when a state is entered
("before") or left ("after").

- read-loop: waiting for user input; entered on session start and after
  every agent turn.
- agent-loop-api-call: an API call to the model is being made.
- agent-loop-tool-call: a tool call returned by the model is being
  executed.
- agent-loop-end: the agent turn is finished and is committed; read-loop
  is entered next.
- agent-loop-api-call-interrupted: the user interrupted during an API
  call.
- agent-loop-tool-call-interrupted: the user interrupted during a tool
  call.
- end: the session is ending. Its "before" hooks run; its "after" hooks
  do not.
- any-state: a wildcard. Its hooks run on every transition, in addition
  to the hooks of the specific state.

# Hook execution

- A hook is a POSIX sh script run by the session. It runs synchronously:
  the session waits for it to finish, so keep hooks short.
- The hook inherits the session's environment and working directory; it
  receives no arguments.
- Its output goes to the user's terminal; it is not seen by the model.
- Hooks exist only within the current session.

# Edge cases

- Creating a hook with a name that already exists fails
  ("hook already exists") unless "append" is true.
- "append" requires "name" and can not be used with mode "symlink".
- In "copy" and "symlink" modes, the source pathname is resolved
  relative to the working directory of the session.
- Hook names can not contain "/" or newlines, and can not be "." or
  "..".
- "remove" and "path" locate the hook by "state", "type" and "when" as
  well as "name"; "type" defaults to "oneshot" and "when" to "after", so
  pass them explicitly for hooks created with other values.

# Interface notes

- "path" returns the absolute pathname of the hook file; pass it to the
  shell tool to inspect or edit the hook directly.
- "list-enabled" without filters lists all hooks; "state", "type" and
  "when" filter the list.
