# Scenarios: agent-loop-interrupted

The user interrupted during an API call or a tool call. The scenarios
below are examples of common uses, not a limit on what hooks can do.

- enter: llm_chat_last_status is "interrupted". When
  llm_chat_prev_state is agent-loop-api-call, the interrupted tool
  call is handled (call_tool -I) and the remaining pending items are
  committed here.
- leave: the turn goes to agent-loop-end, or to agent-loop-failure
  when handling the interrupted tool call failed.
