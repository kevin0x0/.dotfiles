# Scenarios: agent-loop-api-call-interrupted

The user interrupted during an API call. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: tell the user about the interruption. If a partial response
  arrived, it was already appended to llm_chat_this_turn, before the
  leave event of agent-loop-api-call.
- enter: clean up state your own earlier hook created, e.g. under
  your own state directory (llmcc_hook_get_my_state_dir).
- leave: no additional information; the partial output is already
  available at enter.
