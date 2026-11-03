# manage_tools

Supplementary reference for managing the session tool set and exploring
the tool system. The tool description covers the operations; this document
explains the interface details.

# Patterns

"pattern" is a space separated list of glob patterns. Patterns without
"/" match tool names across all tools; patterns containing "/" match
paths in the tool tree (tree mode).

Recipes:

- "/*"          top level of the tool tree
- "builtin/*"   entries directly under the builtin category
- "cat1/*/"     category directories under cat1 (ends with "/")
- "manage_*"    tools whose name starts with "manage_"
- "shell"       the exact tool name
- "*"           all tools (name mode)

In tree mode, entries are paths: the last segment of a file entry is the
tool name, and directory entries are categories and end with "/". A
pattern ending with "/" matches only directories; otherwise files and
directories are matched alike. A file directly under the tree root is a
general-purpose tool that belongs to no category.

# Pagination

"list" returns at most "count" items (default 20) starting at
"start_index"; "total" is the size of the full result. "count" has no
upper bound: set it to "total" to get everything in one call; page only
when the result is large.

# Errors and edge cases

- "list" with "enabled" true takes no "pattern": combining them is an
  error.
- "enable" and "disable" also accept tree paths: patterns containing "/"
  are matched against the tool tree and the matched tools are
  enabled/disabled by name; directory entries are ignored.
- Glob patterns can not match dot-prefixed (hidden) names; such patterns
  are rejected.
