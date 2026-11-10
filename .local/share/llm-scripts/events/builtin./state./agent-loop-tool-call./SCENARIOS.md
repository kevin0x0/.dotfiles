# Scenarios: agent-loop-tool-call

The session executes the model's tool calls, if the response has any.
The state is entered once per completed response, and its enter and
leave events fire even when the response has no tool-call item. The
scenarios below are
examples of common uses, not a limit on what hooks can do.

- enter: observe tool usage, e.g. log which tools are being called.
  The response's tool-call items, if any, are in
  llm_chat_response_output. Timing
  includes the time spent waiting for the user's approval of a tool;
  a rejected approval becomes a tool result (rejected) sent back like
  any other, with llm_chat_next_state agent-loop-api-call, not
  read-loop.
- leave: inspect the tool's output (llm_chat_tool_output) and react
  to particular results. The file holds the most recent tool result
  in the session: on a visit without a tool call it is stale. At
  leave, llm_chat_next_state tells what happened: agent-loop-api-call
  (the result was sent back), agent-loop-end (the response had no
  tool-call item), read-loop (a tool call failed), or
  agent-loop-tool-call-interrupted (a tool call was interrupted).
