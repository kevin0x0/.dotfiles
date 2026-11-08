# manage_hooks

Supplementary reference for managing session hooks. The tool description
covers the operations; this document explains the interface details.

# Events

A hookable event is a lowercase dot-separated name (e.g.
"state.read-loop.enter"). Events are installed in the llm-scripts
events directory (in the config and data dirs, config takes priority);
"create" requires the event to be installed, while "list", "remove" and
"path" only validate the name syntactically.

The events directory is a namespace tree: entries ending with "." are
namespaces, other entries are events, and consecutive segments of an
event name can be folded into one entry ("state.read-loop.enter" can be
installed as "state./read-loop.enter", as "state.read-loop.enter", or
as any other folding). Entries whose relative path contains an uppercase
letter are documents, never events or namespaces; a document with an
arbitrary name can be placed under a directory whose name contains an
uppercase letter (e.g. "DOCS/"). An event or namespace directory may
hold a "SUMMARY" file whose content is its summary; "list-events" with
"with_summary" includes it (empty when missing).

The session currently emits "builtin.state.<state>.enter" and
"builtin.state.<state>.leave" for <state> in read-loop, agent-loop-api-call,
agent-loop-tool-call, agent-loop-end, agent-loop-api-call-interrupted,
agent-loop-tool-call-interrupted, end.

# Documents

A document path has the form "<entry name>/<doc path relative to the
entry>", e.g. "builtin.state./STATES.md". "list-docs" collects the
documents of the given entry (an event or a namespace) and of all its
ancestors, recursively including those under uppercase directories such
as "DOCS/"; the optional "pattern" is an ERE filtering the paths.
"doc" reads the documents at the given paths; paths that do not exist
are silently omitted.

# Hooks

- A hook name has the form "<name>.<type>" with exactly one dot: the
  type suffix selects the run policy. "oneshot" runs once and is then
  removed; other types run every time.
- "remove" and "path" identify the hook by its full name, including the
  type suffix: removing "notify.always" as "notify.oneshot" fails.
- A hook is a POSIX sh script run by the session. It runs synchronously:
  the session waits for it to finish, so keep hooks short.
- The hook inherits the session's execution environment and working
  directory; some sensitive variables are unset before it runs. It
  receives no arguments.
- Two variables describe the run to the hook: llmcc_event holds the
  event name, llmcc_hook_script the hook's own pathname.
- When the document of the relevant event describes the execution
  environment explicitly, that description takes precedence.
- Its output goes to the user's terminal; it is not seen by the model.
- Hooks exist only within the current session.

# Edge cases

- Creating a hook with a name that already exists fails
  ("hook already exists") unless "append" is true.
- "append" requires "name" and can not be used with mode "symlink".
- In "copy" and "symlink" modes, the source pathname is resolved
  relative to the working directory of the session.
- A hook name can not contain "/", more than one dot, or empty parts; a
  "name" omitted from "create" is auto-generated
  ("unnamed-<pid>.oneshot").
- "create" rejects events that are not registered; an event name can not
  contain empty segments ("state..enter" is invalid).
- "list" without arguments lists all installed hooks; glob arguments
  filter by the "event/name.type" path.
