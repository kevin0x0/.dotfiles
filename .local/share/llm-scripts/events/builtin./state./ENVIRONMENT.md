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
  llmcc_hook_dump_vars, llmcc_hook_get_shared_state_dir),
  described in the manage_hooks documentation, and on the documented
  "llm_chat_" symbols below.
- Names starting with "llm_chat_" form the exposed interface. The
  symbols documented in this file are stable; the other "llm_chat_"
  names are dependencies of the exposed functions and must not be used
  directly.

## Variables

- llm_chat_state: the state the event belongs to ("read-loop",
  "agent-loop-api-call", ...). There is no variable naming the
  previous state or the reason a state was entered; a hook can record
  such facts in its own state directory
  (llmcc_hook_get_my_state_dir), which belongs to that hook in this
  session, is removed with the hook, and for a oneshot hook
  disappears after it runs.
- llm_chat_next_state: on leave events it is the state the session
  will enter next, except at end.leave, where it holds no meaningful
  value (do not rely on it there); on enter events it is the state
  being entered (equal to llm_chat_state), not the upcoming next
  state.

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
- llm_chat_this_turn: the current turn's items in the same format, not
  yet committed. The user's input message is appended here when input
  is sent, before read-loop.leave. At agent-loop-end.enter the turn
  is still here; it is committed to llm_chat_conversation while the
  session processes the agent-loop-end state (between its enter and
  leave events), after which this file is empty. A failed or
  interrupted turn is not committed at that moment: an interrupted
  API response or tool result is appended here before the leave event
  of the state during which the interruption occurred
  (agent-loop-api-call or agent-loop-tool-call; the response part may
  be empty, if none arrived), while a failed call appends nothing.
  Such a turn's items remain at the end of the file, and input
  committed later is appended after them; they are all sent together
  when a later turn is committed at its agent-loop-end, or left
  uncommitted here if the session ends first.
- llm_chat_tool_output: the item(s) of the most recent tool call
  result in the session, one per line, in the Responses API input item
  format, restricted to the tool-output item types. The file is
  rewritten at each agent-loop-tool-call visit: when the response had
  several tool calls, it holds one item per executed call, in order.
  It is empty when
  no tool call has produced a result yet, and is not cleared between
  visits otherwise: on a visit without a tool call it holds the
  previous visit's result. When a tool call is interrupted, the
  partial result is written here and appended to llm_chat_this_turn
  before the leave event of
  agent-loop-tool-call; the turn is then not committed until a later
  agent-loop-end. A failed visit appends nothing and leaves the file
  with no guaranteed content.
- llm_chat_response_output: the output items of the last API call, one
  per line, in the Responses API output item format. The file is
  rewritten by each call; it may be empty,
  or hold only part of the output items, when the call failed or was
  interrupted.
- llm_chat_response_extra_info_output: the "usage" and "model" fields
  of the last API call, extracted verbatim from the response: a JSON
  object with both keys, each possibly null. The file holds either
  exactly one such object or nothing; it is empty when the call failed
  or was interrupted.
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
