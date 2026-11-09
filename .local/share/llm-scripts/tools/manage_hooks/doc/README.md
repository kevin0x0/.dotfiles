# manage_hooks

Supplementary reference for managing session hooks. The tool description
covers the operations; this document explains the interface details and
shows example results.

# Hooks

- "remove", "hook-dump" and "hook-source" identify the hook by its
  full name, including the type suffix: removing "notify.always" as
  "notify.oneshot" fails.
- "hook-dump" writes the hook's script content to "output_file"; the
  hook's location is never revealed. For a "symlink" hook, the content
  of the file it links to is dumped.
- A hook is a POSIX sh script run by the session: it is sourced by
  the session's shell (no shebang is needed), and its content is
  provided according to the create mode ("command" text with a
  trailing newline added, a copied file, or a linked file).
  Each hook runs in a subshell of its own: changes to variables and
  the working directory do not leak into other hooks or into the
  session.
  It runs synchronously
  and has no timeout: the session waits for it to finish, so keep
  hooks short; a hook that does not finish blocks the session.
- Hooks never run concurrently: the session runs them one at a time,
  event by event. The relative order of several hooks on the same
  event is unspecified.
- The hook inherits the session's execution environment and working
  directory. It receives no arguments; its standard input is /dev/null.
- Hooks are not re-entered: one hook's run never directly triggers
  another hook's run.
- The hook's exit status is ignored by the session. When the document
  of the relevant event describes the exit status handling, that
  description takes precedence.
- Three names describe the run to the hook: llmcc_event holds the
  event name, llmcc_hook_script the hook's own pathname (if relative,
  it is relative to the current working directory), and
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
- A hook stays installed if its event is later uninstalled; it does
  not run while the event is uninstalled (the session only runs hooks
  for the events it emits), and it runs again if the event is
  reinstalled and emitted.
- Hooks exist only within the current session; there is no limit on
  the number of hooks. The hook log has no size limit; read the dump
  with tail or grep.

# Operations

The examples pair a call with the result it returns; the hook names in
them are fictitious. The results never reveal the hook locations.

## create

Fields: "created"/"appended" (the hook as "event/base.type").

For {"operation":"create","event":"builtin.state.read-loop.enter","mode":"command","source":"echo hi","name":"notify.always"}:

    {"created":"builtin.state.read-loop.enter/notify.always"}

Appending to the same hook ("append": true):

For {"operation":"create","event":"builtin.state.read-loop.enter","mode":"command","source":"echo bye","append":true,"name":"notify.always"}:

    {"appended":"builtin.state.read-loop.enter/notify.always"}

Copying a file ("copy": a snapshot taken at creation time):

For {"operation":"create","event":"builtin.state.read-loop.enter","mode":"copy","source":"/home/user/scripts/notify.sh","name":"notify.always"}:

    {"created":"builtin.state.read-loop.enter/notify.always"}

Linking a file ("symlink": the hook follows later changes):

For {"operation":"create","event":"builtin.state.read-loop.enter","mode":"symlink","source":"/home/user/scripts/notify.sh","name":"notify.always"}:

    {"created":"builtin.state.read-loop.enter/notify.always"}

Without a "name", an auto-generated "oneshot" name is used:

    {"created":"builtin.state.read-loop.enter/unnamed-<number>.oneshot"}

## remove

For {"operation":"remove","event":"builtin.state.read-loop.enter","name":"notify.always"}:

    {"removed":"builtin.state.read-loop.enter/notify.always"}

## list

- The entries carry no summary; "list-events" with "with_summary"
  provides the summaries of the events and namespaces.

Fields: "hooks" (the installed hooks as "event/base.type" paths, each
with "kind": "regular" or "symlink").

For {"operation":"list"}:

    {"hooks":[{"kind":"regular","rel":"builtin.state.end.leave/cleanup.oneshot"},{"kind":"symlink","rel":"builtin.state.read-loop.enter/notify.always"}]}

No installed hook:

    {"hooks":[]}

## list-events

Fields: "events" (the matching events and namespaces, each with "name"
and a "summary" when "with_summary" is true).

For {"operation":"list-events","with_summary":true,"pattern":"agent-loop-end"}:

    {"events":[{"name":"builtin.state.agent-loop-end.","summary":"The agent turn is finished and is committed.\n"},{"name":"builtin.state.agent-loop-end.enter","summary":""},{"name":"builtin.state.agent-loop-end.leave","summary":""}]}

No matching event:

    {"events":[]}

## list-docs

Fields: "entry" (the given entry name), "doclist" (the document paths
as "<entry name>/<path relative to the entry>", collected from the
entry and its ancestors).

For {"operation":"list-docs","entry":"builtin.state.read-loop."}:

    {"entry":"builtin.state.read-loop.","doclist":["builtin.state./ENVIRONMENT.md","builtin.state.read-loop./SCENARIOS.md","builtin.state.read-loop./SUMMARY","builtin.state./STATES.md","builtin.state./SUMMARY","builtin./SUMMARY"]}

An entry without documents gives an empty "doclist", not an error.

Filtered by "pattern" (an unanchored ERE searched within the full
listed paths, including the ancestors):

For {"operation":"list-docs","entry":"builtin.state.read-loop.","pattern":"SUMMARY"}:

    {"entry":"builtin.state.read-loop.","doclist":["builtin.state.read-loop./SUMMARY","builtin.state./SUMMARY","builtin./SUMMARY"]}

## doc

- Paths naming a directory are silently omitted as well.

Fields: "docs" (the found documents, each with "path" and "content").

For {"operation":"doc","docpaths":["builtin.state./STATES.md","builtin.state./ENVIRONMENT.md"]}:

    {"docs":[{"path":"builtin.state./STATES.md","content":"..."},{"path":"builtin.state./ENVIRONMENT.md","content":"..."}]}

All requested documents missing:

    {"docs":[]}

Some documents missing (the found ones are returned, the missing ones
silently omitted):

For {"operation":"doc","docpaths":["builtin.state./STATES.md","no_such.md"]}:

    {"docs":[{"path":"builtin.state./STATES.md","content":"..."}]}

## hook-dump

- The script ends with a newline for "command" and "copy" hooks; a
  "symlink" hook dumps the current target content, which may not end
  with a newline if the target changed after creation.

Fields: "dump" ("path": the file the script was written to, "count":
its line count).

For {"operation":"hook-dump","event":"builtin.state.read-loop.enter","name":"notify.always","output_file":"/tmp/hook.sh"}:

    {"dump":{"path":"/tmp/hook.sh","count":2}}

## hook-source

Fields: "source" (the file the hook links to; an absolute pathname).

For {"operation":"hook-source","event":"builtin.state.read-loop.enter","name":"linked.always"}:

    {"source":"/home/user/scripts/notify.sh"}

## log-dump

For {"operation":"log-dump","pattern":"agent-loop-end","output_file":"/tmp/hook.log"}:

    {"dump":{"path":"/tmp/hook.log","count":12}}

No matching line:

    {"dump":{"path":"/tmp/hook.log","count":0}}

# Edge cases

- "append" can not be used on a hook installed as a symlink; in
  "command" mode it appends the new script text, and in "copy" mode
  the source file's content.
- In "copy" and "symlink" modes, the source pathname is resolved
  relative to the working directory of the session, and must be a
  readable regular file ending with a newline; otherwise the create
  fails ("'<path>' doesn't exist or not a file", or "no newline at end
  of file: <path>"). In "command" mode, the text is stored with a
  trailing newline added.
- A hook name may only contain letters, digits, "_", "." and "-", with
  exactly one dot and no empty parts (the auto-naming form ".<type>"
  is the exception); there is no length limit.
- An event name can not contain empty segments ("state..enter" is
  invalid).
