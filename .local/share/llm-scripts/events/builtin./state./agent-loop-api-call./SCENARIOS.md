# Scenarios: agent-loop-api-call

An API call to the model is being made. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: observe when a request starts, e.g. for timing.
- leave: inspect the response, which is now in llm_chat_pending_items
  (the output items converted to input items), e.g. for a refusal or
  to keep a record of it; the usage, model, error and
  incomplete_details of the call are in
  llm_chat_response_extra_info_output.
- leave: react to the outcome, told by llm_chat_next_state:
  agent-loop-tool-call (completed), agent-loop-interrupted
  (interrupted), or agent-loop-failure (failed).
