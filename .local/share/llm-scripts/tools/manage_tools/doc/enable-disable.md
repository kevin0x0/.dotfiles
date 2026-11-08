# enable / disable

The operations "enable" and "disable" adjust the session's extra tool
set.

Unless the user explicitly asks for it, do not use these operations,
and do not consider using them.

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
