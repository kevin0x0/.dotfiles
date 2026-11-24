# Scenarios: agent-loop-api-call-prepare

The session prepares an API call: it refreshes expiring file ids and
commits the pending items to the conversation. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: the pending items (llm_chat_pending_items) are still
  uncommitted; this is the last point before they are merged into
  llm_chat_conversation. On the first visit of a turn, llm_chat_prev_state
  is read-loop; on later visits (after a tool call) it is
  agent-loop-tool-call.
- leave: llm_chat_pending_items has been committed to
  llm_chat_conversation and is empty. llm_chat_next_state is
  agent-loop-api-call when the preparation succeeded, or read-loop
  when refreshing a file id failed.
