# Scenarios: agent-loop-end

The agent turn is finished; the turn is committed to the conversation
between the enter and leave events. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: tell the user the turn is done; the hook's standard output
  goes to the user's terminal.
- enter: add a message to the conversation, e.g. a summary note for
  the model.
- leave: keep a record, e.g. count turns or append to a file.
