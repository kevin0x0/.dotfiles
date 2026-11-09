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
  agent-loop-tool-call -> agent-loop-api-call (the model asked for
      another tool call), agent-loop-end (no tool call, or the last
      one), agent-loop-tool-call-interrupted (interrupt), or read-loop
      (failure)
  agent-loop-api-call-interrupted / agent-loop-tool-call-interrupted
      -> read-loop
  agent-loop-end -> read-loop
  read-loop -> end (the session is closed)