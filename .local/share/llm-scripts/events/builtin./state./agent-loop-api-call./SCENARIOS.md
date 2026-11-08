# Scenarios: agent-loop-api-call

An API call to the model is being made. The scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: observe when a request starts, e.g. for timing.
- leave: inspect the response (llm_chat_response_output), e.g. for
  cost, a refusal, or to keep a record of it.
- leave: detect that the call failed (the session goes back to
  read-loop) and react to it.
