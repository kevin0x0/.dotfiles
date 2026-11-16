# Orchestration

The orchestration is a JSON Lines document: one JSON value per line,
each line describing one user turn. The session is driven by mock
components and makes no real API calls.

A line has the form:

    {
      "input": [ <input content item>, ... ],
      "output": [ <response>, ... ]
    }

- `input` is the turn's user input, an array of input content items.
- `output` is the sequence of API responses the agent loop produces
  for this turn (usually one, several when tool results are sent back
  to the model), an array of response objects.

## Input content items

- `{"type": "input_text", "text": <string>}`: a text message. The
  string may span lines.
- `{"type": "image", "path": <string>}` or
  `{"type": "file", "path": <string>}`: an image or a file. Both are
  mocked: a fake file id is used and the content is not uploaded.

## Responses

A response object:

    { "status": <string>, "output": [ <output item>, ... ] }

- `status` is optional and defaults to "completed"; the other values
  are "failed" (the API call fails) and "interrupted" (the API call is
  interrupted after producing its output).
- `output` is an array of output items (or a single item, which is
  accepted as a one-item array).

The agent loop ends when a response has no tool call in its output, or
when a response's status is "failed" or "interrupted", or when a tool
call is marked as failed or interrupted (see below). The last response
must end the loop; an orchestration whose loop does not end at its
last response is rejected.

A response may set `usage` and `model` directly; they are passed
through to the mock response. When omitted, the mock API computes the
`usage` from the orchestration's content (`input_tokens` and
`output_tokens` are the lengths of the input and output text,
`cached_tokens` is 0.9 of the input tokens (floored), and
`reasoning_tokens` is the length of the reasoning text) and uses the
session's model. Hooks that read `usage` (such as the stats hooks) see
these values.

## Output items

- `{"type": "output_text", "text": <string>}`: an assistant message.
- `{"type": "reasoning_text", "text": <string>}`: a reasoning block.
- `{"type": "tool_call", "name": <string>, ...}`: a tool call. Its
  input is `arguments` when `tool_type` is "function_call" (the
  default) and `input` when it is "custom_tool_call"; a JSON string.
  Optional fields:
  - `tool_type`: "function_call" (default) or "custom_tool_call".
  - `call_id`: defaults to an auto-generated id.
  - `tool_call_status`: "failed" or "interrupted", only meaningful when
    `call_id` starts with "mock-output-"; it makes the tool call fail
    or be interrupted respectively.
  - `tool_call_output`: for a "mock-output-" tool call, the tool's
    output (a JSON value); when absent, a default text output is used.
  - `extra_body`: extra fields merged into the tool call item, for the
    special call types (e.g. "web_search_call") whose items do not use
    `arguments`/`input`.

## Result directory layout

The returned `result_dir` holds:

- `stdout`, `stderr`: the session's terminal output and the debug
  driver's error output.
- `link-hook-log`: the hook log (the hooks' standard error and
  hook-log messages, prefixed with the event and hook name).
- `link-hooks`, `link-hook-state`, `link-hook-shared-state`: links to
  the installed hooks, their state directories and their shared state
  directories under `chat-session/`.

When `output` is "path" (or "auto" and the results are large), only
`result_dir` and `hooks` are returned; read the files with the shell
tool.

The result directory is not removed automatically; delete it with the
shell tool when its contents are no longer needed.

## Environment

The `envs` parameter sets environment variables for the debug session,
as "NAME=VALUE" strings. The hooks run in the session and see these
variables; an entry whose name is not a valid identifier
(`[A-Za-z_][A-Za-z0-9_]*`) is ignored.

# Examples

A turn that just prints a message:

    {"input":[{"type":"input_text","text":"hi"}],
     "output":[{"output":[{"type":"output_text","text":"hello"}]}]}

A turn that calls a tool, then prints a message after the tool result:

    {"input":[{"type":"input_text","text":"ls"}],
     "output":[
       {"output":[{"type":"tool_call","name":"shell",
                   "arguments":"{\"command\":\"ls\"}"}]},
       {"output":[{"type":"output_text","text":"done"}]}
     ]}

A turn whose API call fails:

    {"input":[{"type":"input_text","text":"boom"}],
     "output":[{"status":"failed","output":[]}]}

A turn whose tool call is interrupted:

    {"input":[{"type":"input_text","text":"x"}],
     "output":[{"output":[{"type":"tool_call","name":"shell",
               "call_id":"mock-output-1","tool_call_status":"interrupted",
               "arguments":"{\"command\":\"x\"}"}]}]}
