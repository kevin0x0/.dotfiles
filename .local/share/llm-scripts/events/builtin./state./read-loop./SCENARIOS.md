# Scenarios: read-loop

Waiting for user input; entered on session start, after every agent
turn, and after a failure or interrupt. The scenarios below are
examples of common uses, not a limit on what hooks can do.

The events fire on every entry into this state; use a "oneshot" hook
for one-time work. This state is not a turn boundary: per-completed-
turn logic belongs at agent-loop-end (failed and interrupted turns do
not reach agent-loop-end), and llm_chat_this_turn may hold
uncommitted items of a failed or interrupted turn.

- enter: initialize once at session start. A "oneshot" hook can add
  a first message to the conversation:

      llm_chat_add_input_content text 'reminder: ...'
      llm_chat_commit_input_content

  The message is appended to the current turn's input
  (llm_chat_this_turn); it appears in llm_chat_conversation only
  once a turn is committed at agent-loop-end. It is a system message
  (the default role of a commit), for the model; it is not shown to
  the user.

- enter: keep the model's context current by adding a message or
  content to the conversation; this happens on each entry into this
  state, which may occur more than once per turn after a failure or
  interrupt.
- enter: coordinate across your installs. Each install of a hook has
  a separate private state directory; several installs of one hook,
  or several cooperating hooks, share one state through
  llmcc_hook_get_shared_state_dir, on an id they agree on (such as
  "myproj.counter").
- leave: observe the session, e.g. how long the user took to answer.
