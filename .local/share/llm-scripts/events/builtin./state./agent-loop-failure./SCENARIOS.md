# Scenarios: agent-loop-failure

The agent turn failed. The scenarios below are examples of common
uses, not a limit on what hooks can do.

- enter: llm_chat_last_status is "failure"; llm_chat_last_error_state
  records the state that failed (llm_chat_prev_state). Nothing is
  committed here.
- leave: the turn goes to agent-loop-end.
