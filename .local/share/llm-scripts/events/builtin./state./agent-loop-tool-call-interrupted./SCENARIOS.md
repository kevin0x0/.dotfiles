# Scenarios: agent-loop-tool-call-interrupted

The user interrupted during a tool call. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: tell the user about the interruption. The partial tool
  result was already appended to llm_chat_this_turn, before the leave
  event of agent-loop-tool-call.
- enter: clean up state your own earlier hook created, e.g. under
  your own state directory (llmcc_hook_get_my_state_dir).
- leave: no additional information; the partial result is already
  available at enter.
