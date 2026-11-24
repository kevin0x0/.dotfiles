# Execution environment

Hooks of the builtin state events run in the chat session, in a
subshell of it: changes to shell variables do not affect the session.
A hook influences the session through the input channel and the
exposed functions below; it can also modify the files described
below, at its own risk. Its standard
output goes to the user's terminal; its
standard error is appended to the hook log. A hook that does not
finish blocks the session (there is no timeout). Some sensitive
variables
are unset before the hook runs; the documented symbols below and the
symbols they depend on are not. The hook's exit status is ignored by
the session; a nonzero status is recorded in the hook log as an ERROR
entry.

## Names

- Names starting with "llm" or "opt" are reserved for the session:
  hooks must not define or modify any of them. Besides the inherited
  standard environment and working directory, hooks may rely only on
  the names the session exposes to every hook (llmcc_event,
  llmcc_hook_script, llmcc_hook_log, llmcc_hook_get_my_state_dir,
  llmcc_hook_dump_vars, llmcc_hook_get_shared_state_dir,
  llmcc_hook_undump_vars, llmcc_hook_source_runtime_config,
  llmcc_hook_get_runtime_config),
  described in the manage_hooks documentation, and on the documented
  "llm_chat_" symbols below.
- Names starting with "llm_chat_" form the exposed interface. The
  symbols documented in this file are stable; the other "llm_chat_"
  names are dependencies of the exposed functions and must not be used
  directly.

## Variables

- llm_chat_state: the state the event belongs to ("read-loop",
  "agent-loop-api-call", ...). There is no variable naming the reason
  a state was entered; a hook can record
  such facts in its own state directory
  (llmcc_hook_get_my_state_dir), which belongs to that hook in this
  session, is removed with the hook, and for a oneshot hook
  disappears after it runs.
- llm_chat_prev_state: the state the session was in before entering
  the current one; it has this value on both the enter and the leave
  events. At session start, read-loop's events see "end" (nothing
  precedes them; no other state is entered from "end").
- llm_chat_next_state: on leave events it is the state the session
  will enter next, except at end.leave, where it holds no meaningful
  value (do not rely on it there); on enter events it is the state
  being entered (equal to llm_chat_state), not the upcoming next
  state.
- llm_chat_color_ansi: whether the session renders its output in
  color: "1" when enabled, empty when not. Hooks run in a subshell,
  so changing it does not affect the session.
- llm_chat_last_total_tokens: an estimate of the number of tokens in
  llm_chat_conversation. It is 0 at session start (the initial
  conversation is not counted) and is corrected from the API usage
  after the first API call; hooks must always treat it as an estimate,
  never as an exact count. It is saved and restored with the session.
- llm_chat_last_status: the outcome of the last agent turn: "success",
  "failure", "interrupted", or "unknown" (before the first turn). It
  is set in the terminal states agent-loop-success, agent-loop-failure
  and agent-loop-interrupted.
- llm_chat_last_error_state: the state that failed in the last turn,
  set by agent-loop-failure to the state it was entered from; it is
  empty when the last turn did not fail. The retry command returns to
  this state.

## Files

Each entry below names a variable holding a file pathname. The files
are owned by the session; do not modify them unless necessary. Most
hold JSON Lines (one JSON value per line); the exceptions are noted.
Every JSON value in them is complete.
jq is always available to hooks; it is the intended tool for reading
these files.

- llm_chat_conversation: the committed conversation items (messages,
  tool calls, tool results), one per line, in the Responses API input
  item format.
- llm_chat_pending_items: the session's uncommitted items, one per
  line, in the Responses API input item format. Its content changes
  at these points of the agent loop:
  - the user's input message is appended before read-loop.leave, when
    input is sent;
  - during agent-loop-api-call the model's response, its output items
    converted to input items, replaces the content;
  - on agent-loop-tool-call success or interruption, the response is
    committed to llm_chat_conversation and the tool results become the
    new content;
  - the remaining content is committed to llm_chat_conversation at
    agent-loop-api-call-prepare (before each API call) and at
    agent-loop-success or agent-loop-interrupted, after which the file
    is empty.
  A failed API call leaves it empty (the input was already committed
  and no response arrived); a failed tool call leaves the uncommitted
  response here, committed at a later successful commit or left here
  if the session ends first.
- llm_chat_tool_output: the item(s) of the most recent tool call
  result in the session, one per line, in the Responses API input item
  format, restricted to the tool-output item types. The file is
  rewritten at each agent-loop-tool-call visit: when the response had
  several tool calls, it holds one item per executed call, in order,
  and it is empty when the response had no tool call. On
  agent-loop-tool-call success or interruption, its content is copied
  to llm_chat_pending_items before the leave event of
  agent-loop-tool-call. A failed visit leaves the file with no
  guaranteed content.
- llm_chat_response_extra_info_output: the "usage", "model", "error"
  and "incomplete_details" fields of the last API call, extracted
  verbatim from the response: a single JSON object with those four
  keys, each possibly null. The file holds exactly one such object
  after every call; "error" is set when the call failed,
  "incomplete_details" when it was incomplete, and all four are null
  when it was interrupted.
- llm_chat_tool_list: the tool definitions the session sends to the
  API: a single JSON array of function objects on one line.
- llm_chat_default_tool_set, llm_chat_extra_tool_set: newline lists of
  tool names (not JSON).
- llm_chat_volatile_fileids, llm_chat_persistent_fileids: JSONL records
  of the uploaded files (Files API file objects; volatile: expiring).

## Functions

- llm_chat_add_input_content <type> [<word>...]: append an input content
  item of the given type; the words after the type form one shell word
  list (it may be empty). "text" takes the text itself: each word
  becomes one text item of the message (the words are not joined; an
  empty list adds nothing). "image" and "file" take a
  pathname or a URI;
  "text-from-file" takes a pathname and reads the file's content;
  "text-from-command" takes one or more commands and reads their
  output: each word after the type is one shell command of arbitrary
  form (compound commands, redirections and variable assignments
  included), executed when
  the input is read; each produces one output item. An
  unknown type is an error, reported in the hook log.
- llm_chat_commit_input_content [<role>]: append the pending content
  items as one message of the given role (user, developer, system,
  assistant; system by default) to the turn's input; the model is not
  called until input is sent.
- llm_chat_gen_tool_list: regenerate the session's tool list from the
  tool sets. The regenerated list is used by the next API call; a
  hook on agent-loop-api-call.enter regenerates in time for the call
  about to start. To change the extra tool set from a hook, edit the
  file named by llm_chat_extra_tool_set (a newline list of tool
  names) and call this function; both set files are read. The
  llm_chat_tool_list file is derived and is overwritten by
  regeneration.
- llm_chat_conversation_slice [<begin> [<end>]]: print a slice of
  conversation items. It reads the items from its standard input and
  prints the selected ones, one JSON value per line, in their input
  order; it has no default input, so feed it a file
  (llm_chat_conversation, llm_chat_pending_items or a pipe). The items
  are grouped into exchanges: an exchange starts at a prompt message
  (system, developer or user) and takes everything that follows it
  (assistant messages, tool calls, tool results) until the next
  prompt message; consecutive prompt messages of the same role form
  one exchange, and the very first item starts one. <begin> and
  <end> (integers) select exchanges by position as a half-open range:
  negative numbers count from the end, an omitted bound is the start
  or the end, and a range holding no exchange prints nothing. For
  example, to print the last exchange of the session:

      llm_chat_conversation_slice -1 <"$llm_chat_conversation"

## Input channel

The input functions queue the content; after
the hook, the session consumes it on its next input read. They take
effect on the session's next input read, not inside the hook (for a
read-loop.enter hook, that is the input read of the same visit; for
hooks on any other event, including read-loop.leave, the next
read-loop visit: a read-loop.leave hook can no longer affect the
input read that just happened): the content items
are then appended in order and a commit appends them as one message
to the turn's input; the model is not called until input is sent.
Each commit takes the content added since the previous commit, so a
hook may add and commit several times, producing several messages in
order. Anything
that is only evaluated at that time (the "text-from-command" command,
the pathnames of the file types) must therefore be self-contained: it
can not rely on symbols defined inside the hook, which no longer exist
then. Such a command runs in the session, not in the hook, when the input
is read; relative pathnames are resolved against the
session's working directory at that time. A failure at that time (a
missing file, a failing command) is reported by the session then, not
by the hook. Items added by different hooks on the same event have no
defined relative order; when the order matters, add them from a
single hook.

Content added without a commit remains pending and is merged into the
next message the session sends. Input committed when the session no
longer reads input (in the end state) is discarded, as is any pending
content added earlier but not yet read.

## Examples

Each snippet is the body of a hook; the input functions take effect on
the session's next input read.

Send a note to the model as a system message:

    llm_chat_add_input_content text 'the previous turn just ended'
    llm_chat_commit_input_content

Send the output of a command:

    llm_chat_add_input_content text-from-command date
    llm_chat_commit_input_content system

Send the content of a file:

    llm_chat_add_input_content text-from-file notes.md
    llm_chat_commit_input_content

Add an image, merged into the next message the session sends:

    llm_chat_add_input_content image ./screenshot.png

Add text without a commit, merged into that message as well:

    llm_chat_add_input_content text 'reminder: keep it short'

Regenerate the tool list after changing the extra tool set:

    printf '%s\n' view_image >"$llm_chat_extra_tool_set"
    llm_chat_gen_tool_list
