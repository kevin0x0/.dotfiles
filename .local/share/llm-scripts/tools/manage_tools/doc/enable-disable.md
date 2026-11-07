# enable / disable

The operations "enable" and "disable" adjust the session's extra tool
set. They are not listed in the tool schema, but this tool accepts them
when they are needed.

Unless the user explicitly asks for it, do not use these operations.

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
returns {"removed_tools":[...],"count":...}. Enabling an already
enabled tool, or disabling one that is not enabled, is a no-op: the
result is an empty list, not an error.

# Notes

- The default tool set is not affected by enable or disable.
- After enabling a tool, use "describe" to retrieve its full signature
  when the session loads extra tools as stubs.
