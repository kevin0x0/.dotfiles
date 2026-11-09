# Execution environment

Hooks of the builtin state events run in the llm-chat session, in a
subshell of it: changes to shell variables do not affect the session.
A hook influences the session through its output, the input channel,
the exposed functions, and the files described below. Its standard
output goes to the user's terminal; its
standard error is appended to the hook log. Some sensitive variables
are unset before the hook runs; the documented symbols below and the
symbols they depend on are not. The hook's exit status is ignored by
the session; a nonzero status is recorded in the hook log as an ERROR
entry.

## Names

- Names starting with "llm" or "opt" are reserved for the session:
  hooks must not define or modify them, and must not rely on them,
  except for the names the hook runner exposes to every hook
  (llmcc_event, llmcc_hook_script, llmcc_hook_log), described in the
  manage_hooks documentation, and the documented "llm_chat_" symbols
  below.
- Names starting with "llm_chat_" form the exposed interface. The
  symbols documented in this file are stable; the other "llm_chat_"
  names are dependencies of the exposed functions and must not be used
  directly.

## Variables

- llm_chat_state: the state the event belongs to ("read-loop",
  "agent-loop-api-call", ...).
- llm_chat_next_state: the state the session will enter next.

## Files

Each entry below names a variable holding a file pathname. The files
are owned by the session; do not modify them unless necessary.

- llm_chat_conversation: JSONL of the committed conversation messages.
- llm_chat_this_turn: JSONL of the current turn's messages (input,
  responses, tool calls), not yet committed to the conversation.
- llm_chat_response_output: raw JSONL output of the last API call.
- llm_chat_tool_output: raw JSONL output of the last tool call.
- llm_chat_tool_list: the tool list (JSON array) the session sends to
  the API.
- llm_chat_default_tool_set, llm_chat_extra_tool_set: newline lists of
  the tool names in the default and the extra tool set.
- llm_chat_volatile_fileids, llm_chat_persistent_fileids: JSONL records
  of the uploaded files (volatile: expiring).

## Functions

- llm_chat_add_input_content <type> [<word>...]: append an input content
  item of the given type; the words after the type form one shell word
  list, the item's value (it may be empty). "text" takes the text
  itself; "image" and "file" take a pathname or a URI;
  "text-from-file" takes a pathname and reads the file's content;
  "text-from-command" takes a command and reads its output. The
  command of "text-from-command" is executed as a simple command: the
  words are the command name and the arguments, and it can not contain
  redirections or variable assignments; to run more complex shell, use
  `eval '<shell text>'` as the command.
- llm_chat_commit_input_content [<role>]: send the pending content
  items as one message of the given role (user, developer, system,
  assistant; system by default), and continue reading input.
- llm_chat_gen_tool_list: regenerate the session's tool list from the
  tool sets.

## Input channel

The input functions append command lines to an internal file; after
the hook, the session prepends them to its pending input. They take
effect on the session's next input read, not inside the hook (for a
read-loop.enter hook, that is the input read of the same visit; for
hooks on other states, the next read-loop visit): the content items
are then appended in order and a commit sends them as one message. Anything
that is only evaluated at that time (the "text-from-command" command,
the pathnames of the file types) must therefore be self-contained: it
can not rely on symbols defined inside the hook, which no longer exist
then.

Content added without a commit remains pending and is merged into the
next message the input loop sends. Input committed when the session no
longer reads input (e.g. in the end state) is discarded.

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

Add an image, merged into the next message the input loop sends:

    llm_chat_add_input_content image ./screenshot.png

Add text without a commit, merged into that message as well:

    llm_chat_add_input_content text 'reminder: keep it short'

Regenerate the tool list after changing a tool:

    llm_chat_gen_tool_list
