The chat session is a state machine: at any moment it is in exactly one
state, and it emits a "builtin.state.<state>.enter" event when it enters
a state and a "builtin.state.<state>.leave" event when it leaves it.
Hooks attached to those events run synchronously at those moments, in
the session's environment; their standard output goes to the user's
terminal.
The execution environment is described in ENVIRONMENT.md.
Each state is described in the summary of its own namespace.

A normal turn cycles through:

  read-loop -> agent-loop-api-call -> agent-loop-tool-call
      ^             |                      |
      |             |                      +--> agent-loop-end
      |             |                                |
      +-------------+--------------------------------+

An interrupt during an API call or a tool call moves the session to the
corresponding interrupted state instead, which returns to read-loop.
The session enters the "end" state when it is about to close.
