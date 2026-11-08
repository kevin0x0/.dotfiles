# enable / disable

The operations "enable" and "disable" adjust the session's extra tool
set. They are listed in the tool schema like the other operations.

Unless the user explicitly asks for it, do not use these operations,
and do not consider using them.

# Operations

- "enable": add the tools matching "pattern" to the session's extra
  tool set. Requires "pattern".
- "disable": remove the tools matching "pattern" from the session's
  extra tool set. Requires "pattern".

# Patterns

"pattern" is a space separated glob pattern list. Patterns without "/"
match tool names; patterns containing "/" match paths in the tool tree.
A word starting with "@" names a tool preset.

# Approval

Both operations require approval on the controlling terminal; in
non-interactive sessions they are rejected unless automatic approval is
configured.

# Returns

On success: enable returns {"added_tools":[...],"count":...}; disable
returns {"removed_tools":[...],"count":...}. A tool that does not
exist is ignored, and so is a tool the operation has no effect on: for
"enable", a tool already in the enabled tool set; for "disable", a
tool that is not in the extra tool set. The result is then an empty
list, not an error. The fields are: "added_tools"/"removed_tools" (the
tools that were added or removed) and "count" (their number).

For {"operation":"enable","pattern":"some_*"}:

    {"added_tools":["some_helper","some_tool"],"count":2}

For {"operation":"disable","pattern":"some_*"}:

    {"removed_tools":["some_helper","some_tool"],"count":2}

Ignored tools (do not exist, or the operation has no effect on them):

    {"added_tools":[],"count":0}

# Notes

- The default tool set is not affected by enable or disable.
- After enabling a tool, use "describe" to retrieve its full signature
  when the session loads extra tools as stubs.
- Run "enable" and "disable" one at a time: they change the extra tool
  set.
