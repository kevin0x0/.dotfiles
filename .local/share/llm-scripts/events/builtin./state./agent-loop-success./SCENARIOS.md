# Scenarios: agent-loop-success

The agent turn succeeded and no tool call remains; the remaining
pending items are committed here. The scenarios below are examples of
common uses, not a limit on what hooks can do.

- enter: llm_chat_last_status is "success". llm_chat_pending_items may
  still hold the last items; they are committed before leave.
- leave: the turn goes to agent-loop-end.
