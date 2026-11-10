# Scenarios: agent-loop-end

The agent turn is finished; the turn is committed to the conversation
between the enter and leave events. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: tell the user the turn is done; the hook's standard output
  goes to the user's terminal.
- enter: add a note for the model, e.g. a summary of the turn just
  finished; input added here reaches the model with the next turn's
  input (the current turn is committed between enter and leave). At
  enter, llm_chat_this_turn may also hold uncommitted items of a
  failed or interrupted turn earlier; only at leave is it empty.
- leave: keep a record, e.g. count turns or append to a file; the
  turn is now committed and llm_chat_this_turn is empty.
