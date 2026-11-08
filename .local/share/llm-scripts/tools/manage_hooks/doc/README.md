# manage_hooks

Supplementary reference for managing session hooks. The tool description
covers the operations; this document explains the interface details.

# Events

A hookable event is a lowercase dot-separated name (e.g.
"state.read-loop.enter"). A hook can only be attached to an installed
event; "create" requires the event to be installed (a namespace can
not hold a hook), while "list", "remove" and "hook-dump" only validate
the name syntactically.

The events form a namespace tree: entries ending with "." are
namespaces and other entries are events. An event or namespace entry
may hold a "SUMMARY" file whose content is its summary; "list-events"
with "with_summary" includes it (empty when missing).

# Documents

A document path has the form "<entry name>/<doc path relative to the
entry>", e.g. "builtin.state./STATES.md". "list-docs" collects the
documents of the given entry (an event or a namespace) and of all its
ancestors; the optional "pattern" is an ERE filtering the paths.
"doc" reads the documents at the given paths; paths that do not exist
are silently omitted. An entry that is not installed is an error
("entry not installed").

# Hooks

- A hook name has the form "<name>.<type>" with exactly one dot: the
  type suffix selects the run policy. "oneshot" runs once and is then
  removed; "always" runs every time.
- "remove", "hook-dump" and "hook-source" identify the hook by its
  full name, including the type suffix: removing "notify.always" as
  "notify.oneshot" fails.
- "hook-dump" writes the hook's script content to "output_file", which
  must not exist yet; the hook's location is never revealed. For a
  "symlink" hook, the content of the file it links to is dumped.
- A hook is a POSIX sh script run by the session. It runs synchronously
  and has no timeout: the session waits for it to finish, so keep
  hooks short.
- Hooks never run concurrently: the session runs them one at a time,
  event by event. The relative order of several hooks on the same
  event is unspecified.
- The hook inherits the session's execution environment and working
  directory. It receives no arguments.
- Three names describe the run to the hook: llmcc_event holds the
  event name, llmcc_hook_script the hook's own pathname, and
  llmcc_hook_log is the logging function.
- Its standard output goes to the user's terminal; it is not seen by
  the model. Its standard error is appended to the hook log; each
  line is prefixed with "[<event>/<hook name>] " (the full hook name,
  including the type suffix).
- llmcc_hook_log <level> <message>... writes "[<level>] <time>:
  <message>" lines to the hook log, one per line of a multi-line
  message. <level> is any word; INFO and ERROR are conventional. These
  are standard error lines, so each also gets the "[<event>/<hook
  name>] " prefix.
- When the document of the relevant event describes the execution
  environment explicitly, that description takes precedence.
- Hooks exist only within the current session; there is no limit on
  the number of hooks.

# Hook log

- The hook log is a session file; each standard error line of a hook is
  appended to it prefixed with "[<event>/<hook name>] ".
- "log-dump" writes the log lines matching "pattern" to "output_file".
  "pattern" is an ERE matched against the "[<event>/<hook name>]" line
  prefix; all lines are dumped when it is omitted. "output_file" must
  not exist yet; no matching lines produce an empty dump, not an error.
- The log grows with each hook run and has no size limit; read the
  dump with tail or grep.

# Operations

The examples pair a call with the result it returns; the hook names in
them are fictitious. The results never reveal the hook locations.

## create

Fields: "created"/"appended" (the hook as "event/name.type").

For {"operation":"create","event":"builtin.state.read-loop.enter","mode":"command","source":"echo hi","name":"notify.always"}:

    {"created":"builtin.state.read-loop.enter/notify.always"}

Appending to the same hook ("append": true):

    {"appended":"builtin.state.read-loop.enter/notify.always"}

Without a "name", an auto-generated "oneshot" name is used:

    {"created":"builtin.state.read-loop.enter/unnamed-<number>.oneshot"}

## remove

For {"operation":"remove","event":"builtin.state.read-loop.enter","name":"notify.always"}:

    {"removed":"builtin.state.read-loop.enter/notify.always"}

## list

Fields: "hooks" (the installed hooks as "event/name.type" paths, each
with "kind": "regular" or "symlink").

For {"operation":"list"}:

    {"hooks":[{"kind":"regular","rel":"builtin.state.end.leave/cleanup.oneshot"},{"kind":"symlink","rel":"builtin.state.read-loop.enter/notify.always"}]}

No installed hook:

    {"hooks":[]}

## list-events

- "pattern" is an ERE matching the full listed names, including the
  trailing "." of namespaces.

Fields: "events" (the matching events and namespaces, each with "name"
and a "summary" when "with_summary" is true).

For {"operation":"list-events","with_summary":true,"pattern":"^builtin\\.state\\.agent-loop-end"}:

    {"events":[{"name":"builtin.state.agent-loop-end.","summary":"The agent turn is finished and is committed.\n"},{"name":"builtin.state.agent-loop-end.enter","summary":""},{"name":"builtin.state.agent-loop-end.leave","summary":""}]}

No matching event:

    {"events":[]}

## list-docs

Fields: "entry" (the given entry name), "doclist" (the document paths
as "<entry name>/<path relative to the entry>", collected from the
entry and its ancestors).

For {"operation":"list-docs","event":"builtin.state.read-loop."}:

    {"entry":"builtin.state.read-loop.","doclist":["builtin.state./ENVIRONMENT.md","builtin.state.read-loop./SCENARIOS.md","builtin.state.read-loop./SUMMARY","builtin.state./STATES.md","builtin.state./SUMMARY","builtin./SUMMARY"]}

An entry without documents:

    {"entry":"builtin.state.read-loop.","doclist":[]}

## doc

Fields: "docs" (the found documents, each with "path" and "content").

For {"operation":"doc","docpaths":["builtin.state./STATES.md","builtin.state./ENVIRONMENT.md"]}:

    {"docs":[{"path":"builtin.state./STATES.md","content":"..."},{"path":"builtin.state./ENVIRONMENT.md","content":"..."}]}

All requested documents missing:

    {"docs":[]}

## hook-dump

- "output_file" must not exist yet; its directory must exist.

Fields: "dump" ("path": the file the script was written to, "count":
its line count).

For {"operation":"hook-dump","event":"builtin.state.read-loop.enter","name":"notify.always","output_file":"/tmp/hook.sh"}:

    {"dump":{"path":"/tmp/hook.sh","count":2}}

## hook-source

- Only for "symlink" hooks; a regular hook is an error.

Fields: "source" (the file the hook links to).

For {"operation":"hook-source","event":"builtin.state.read-loop.enter","name":"linked.always"}:

    {"source":"/home/user/scripts/notify.sh"}

## log-dump

- "output_file" must not exist yet; its directory must exist.

For {"operation":"log-dump","pattern":"^\\[builtin\\.state\\.agent-loop-end\\.","output_file":"/tmp/hook.log"}:

    {"dump":{"path":"/tmp/hook.log","count":12}}

No matching line:

    {"dump":{"path":"/tmp/hook.log","count":0}}

# Edge cases

- Creating a hook with a name that already exists fails
  ("hook already exists") unless "append" is true; with "append", a
  hook that does not exist yet is created.
- "append" requires "name" and can not be used with mode "symlink", nor
  on a hook installed as a symlink; in "copy" mode, "append" appends
  the source file's content.
- In "copy" and "symlink" modes, the source pathname is resolved
  relative to the working directory of the session.
- A hook name can not contain "/", more than one dot, or empty parts; a
  "name" omitted from "create" is auto-generated
  ("unnamed-<number>.oneshot").
- "create" rejects events that are not registered; an event name can not
  contain empty segments ("state..enter" is invalid).
- "list" without arguments lists all installed hooks; glob arguments
  filter by the "event/name.type" path.
