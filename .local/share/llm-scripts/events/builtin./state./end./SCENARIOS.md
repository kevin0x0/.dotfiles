# Scenarios: end

The session is ending; "enter" fires when ending begins, "leave"
fires just before the session exits. The scenarios below are examples
of common uses, not a limit on what hooks can do.

- enter: save a copy of the session, e.g. a transcript or a summary
  file; read both llm_chat_conversation and llm_chat_this_turn (a
  failed or interrupted turn earlier may still be uncommitted in the
  latter).
  These events do not run when the session is killed by a termination
  signal, so keep the work here optional or recoverable.
- leave: do final cleanup. Input added by any hook in this state is
  discarded without effect.
