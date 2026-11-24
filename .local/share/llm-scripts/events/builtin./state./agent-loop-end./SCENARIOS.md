# Scenarios: agent-loop-end

An agent turn is over. The terminal states agent-loop-success,
agent-loop-failure and agent-loop-interrupted converge here, so this
is the stable boundary where a turn has ended, whatever its outcome.
The scenarios below are examples of common uses, not a limit on what
hooks can do.

- enter: a turn just ended; llm_chat_last_status tells its outcome.
  For success and interrupted, llm_chat_pending_items is empty (the
  turn was committed); for failure it still holds the uncommitted
  items.
- enter: add a note for the model, e.g. a summary of the turn just
  finished; input added here reaches the model with the next turn's
  input.
- leave: the session goes to read-loop.
