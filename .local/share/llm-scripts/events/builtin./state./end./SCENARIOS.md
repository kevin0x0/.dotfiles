# Scenarios: end

The session is ending; "enter" fires when ending begins, "leave"
fires just before the session exits. The scenarios below are examples
of common uses, not a limit on what hooks can do.

- enter: save a copy of the session, e.g. a transcript or a summary
  file.
- leave: do final cleanup; the input channel no longer takes effect.
