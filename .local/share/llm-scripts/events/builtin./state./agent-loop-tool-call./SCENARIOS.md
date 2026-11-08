# Scenarios: agent-loop-tool-call

A tool call returned by the model is being executed. The scenarios
below are examples of common uses, not a limit on what hooks can do.

- enter: observe tool usage, e.g. log which tool is being called.
- leave: inspect the tool's output (llm_chat_tool_output) and react
  to particular results.
