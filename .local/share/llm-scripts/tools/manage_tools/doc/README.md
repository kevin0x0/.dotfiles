# manage_tools

Supplementary reference for managing the session tool sets and exploring
the tool system. The tool description covers the operations; this document
explains the interface details.

# Tool sets

- The default tool set is loaded with full signatures when the session
  starts. It is configured by the user at session start and is usually
  small.
- The extra tool set is loaded with stub signatures; call "describe" to
  retrieve the full signature of one of its tools before calling it.
- The enabled tool set is the union of the two, and is exactly the set
  of tools visible to you in the session: every tool you can see in
  your tool list is in either the default or the extra tool set, and a
  tool that is not in your tool list is in neither of them and can not
  be called, no matter what "list" reports. "list" with
  "ignore_extra_set" can list the whole catalog, including tools that
  are not available in this session. The hidden "enable" and "disable"
  operations adjust the extra tool set; see "enable-disable.md".

# Patterns

"pattern" is a space separated list of glob patterns. Patterns without
"/" match tool names across all tools; patterns containing "/" match
paths in the tool tree (tree mode). A word starting with "@" expands a
tool preset in place: a named list of patterns stored by the user.

Recipes:

- "/*"          top level of the tool tree
- "builtin/*"   entries directly under the builtin category
- "cat1/*/"     category directories under cat1 (ends with "/")
- "manage_*"    tools whose name starts with "manage_"
- "shell"       the exact tool name
- "*"           all tools (name mode)
- "@default"    the tools of a named preset; can be mixed with other words

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

- "describe" only describes tools of the extra tool set, and skips tools
  already described in this session; with no "pattern" it describes
  nothing.
- "list" without "ignore_extra_set" lists only the extra tool set.
- Glob patterns can not match dot-prefixed (hidden) names; such patterns
  are rejected.
