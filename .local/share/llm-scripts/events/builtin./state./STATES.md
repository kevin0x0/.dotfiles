The chat session is a state machine: at any moment it is in exactly one
state, and it emits a "builtin.state.<state>.enter" event when it enters
a state and a "builtin.state.<state>.leave" event when it leaves it.
Hooks attached to those events run synchronously at those moments, in
the session's environment; their standard output goes to the user's
terminal.
The execution environment is described in ENVIRONMENT.md. Each state
namespace holds a SCENARIOS.md with example use cases for its enter and
leave events; they are examples, not limits.
Each state is described in the summary of its own namespace.

The transitions are:

  read-loop -> agent-loop-api-call (the input is sent; a closed session
      goes to "end" instead)
  agent-loop-api-call -> agent-loop-tool-call (any completed response,
      even one without a tool call), agent-loop-api-call-interrupted
      (interrupt), or read-loop (failure)
  agent-loop-tool-call -> agent-loop-api-call (the tool result is sent
      back to the model), agent-loop-end (the response had no
      tool-call item), agent-loop-tool-call-interrupted (interrupt),
      or read-loop (failure)
  agent-loop-api-call-interrupted / agent-loop-tool-call-interrupted
      -> read-loop
  agent-loop-end -> read-loop
  read-loop -> end (the session is closed)

The session enters "end" only from read-loop, when the session closes:
the user ends the input or interrupts it at the prompt (a normal
close: the end events run). Killing the session does not run the end
events. An interrupt means the user interrupts an in-progress API
call or tool call. "failure" means the
session reported an error performing the call; a tool's own error
output is a
result, not a failure. The agent-loop-tool-call state is entered once
per completed response; all of its tool calls are executed in that
visit.