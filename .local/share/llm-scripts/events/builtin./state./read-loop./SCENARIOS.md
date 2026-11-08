# Scenarios: read-loop

Waiting for user input; entered on session start and after every
agent turn. The scenarios below are examples of common uses, not a
limit on what hooks can do.

- enter: initialize once at session start. A "oneshot" hook can add
  a first message to the conversation:

      llm_chat_add_input_content text 'reminder: ...'
      llm_chat_commit_input_content

  The message is added to the conversation for the model; it is not
  shown to the user.

- enter: keep the model's context current each turn by adding a
  message or content to the conversation.
- leave: observe the session, e.g. how long the user took to answer.
