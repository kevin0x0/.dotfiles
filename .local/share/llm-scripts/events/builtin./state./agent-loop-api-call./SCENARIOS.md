# Scenarios: agent-loop-api-call

An API call to the model is being made. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: observe when a request starts, e.g. for timing. At enter,
  llm_chat_response_output still holds the previous call's output
  (empty before the first call).
- leave: inspect the response (llm_chat_response_output), e.g. for a
  refusal or to keep a record of it; the usage and model of the call
  are in llm_chat_response_extra_info_output, which is empty when the
  call failed or was interrupted.
- leave: react to the outcome, told by llm_chat_next_state:
  agent-loop-tool-call (completed), agent-loop-api-call-interrupted
  (interrupted), or read-loop (failed).
