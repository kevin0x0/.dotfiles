# manage_tools

Supplementary reference for managing the session tool sets and
exploring the tool system. The tool description covers the operations;
this document explains the interface details and shows example
results.

# Tool sets

- The default tool set is loaded with full signatures when the session
  starts. It is configured by the user at session start and is usually
  small.
- The extra tool set is loaded with stub signatures: each tool has a
  placeholder description (such as "[deferred]") and empty parameters,
  which do not describe the tool. Call "describe" to retrieve the full
  signature of an extra-set tool before calling it.
- The enabled tool set is the union of the two, and is exactly the set
  of tools visible to you in the session: every tool you can see in
  your tool list is in either the default or the extra tool set, and a
  tool that is not in your tool list is in neither of them and can not
  be called, no matter what "list" reports. "list" with
  "ignore_extra_set" can list the whole catalog, including tools that
  are not available in this session. Do not set "ignore_extra_set" on
  your own unless the user asks for it or the user's request needs it.
  The "enable" and "disable" operations adjust the extra tool set; use
  them only when the user explicitly asks; see "enable-disable.md".

# Operations

The examples pair a call with the result it returns; the tool names in
them are fictitious. Empty results are usually empty lists. The
read-only operations (describe, list, doc, listdoc) can be issued in
parallel; "enable" and "disable" change the extra tool set and must
run one at a time.

## describe

- Scope: the extra tool set only, filtered by "pattern"; with no
  "pattern", nothing is described.
- A stub signature has a placeholder description (such as
  "[deferred]") and empty parameters. When a tool's description looks
  like a placeholder rather than a description of the tool, retrieve
  the full signature with "describe" before calling the tool.

For {"operation":"describe","pattern":"some_tool"}:

    {"described":1,"tools":[{"type":"function","name":"some_tool","description":"...","parameters":{...}}]}

No matching tool:

    {"described":0,"tools":[]}

## list

- Default: the extra tool set; without "pattern", all of its tools are
  listed. With "ignore_extra_set": the whole catalog, including tools
  not available in this session (see the caution in Tool sets).
- "pattern" filters the listed tools; "with_summary" adds each tool's
  short summary. Paging: see Pagination.
- Each item has either a "name" (matched by name) or a "path" (matched
  in the tool tree).

For {"operation":"list","pattern":"some_tool","with_summary":true}:

    {"list":[{"name":"some_tool","summary":"..."}],"total":1,"start_index":0,"count":1}

An empty extra tool set:

    {"list":[],"total":0,"start_index":0,"count":0}

## doc

- "toolname" names the tool. "docpaths" lists the documents to read:
  paths relative to the tool's doc directory, "README.md" by default;
  several documents can be read in one call.
- The paths are literal: glob patterns are not expanded. The docpaths
  to pass are the file paths reported by "listdoc" (not its directory
  entries).
- Documents that do not exist are silently omitted; the result lists
  only the found ones. A "toolname" that names no installed tool is
  silently ignored as well: the result is then an empty list, not an
  error.
- The documents of a tool are organized freely; by convention
  "README.md" is the main entry point.

For {"operation":"doc","toolname":"some_tool","docpaths":["README.md"]}:

    {"toolname":"some_tool","docs":[{"docpath":"README.md","content":"# some_tool\n\n..."}]}

All requested documents missing:

    {"toolname":"some_tool","docs":[]}

## listdoc

- "toolname" names the tool. "pattern" filters the listed document
  paths with globs; without it, all documents are listed.
- Directory entries are listed with a trailing "/"; the list is sorted
  and deduplicated.
- A "toolname" that names no installed tool is silently ignored: the
  result is an empty list, not an error.

For {"operation":"listdoc","toolname":"some_tool"}:

    {"toolname":"some_tool","doclist":["README.md","reference/usage.md"]}

A tool without documents:

    {"toolname":"some_tool","doclist":[]}

## enable / disable

They adjust the session's extra tool set, require approval, and must
only be used when the user explicitly asks; see "enable-disable.md"
for their interface and result examples. Run them one at a time.

# Patterns

"pattern" is a space separated list of glob patterns. Patterns without
"/" match tool names across all tools; patterns containing "/" match
paths in the tool tree (tree mode). Glob matching follows the
semantics of POSIX pathname expansion. A word starting with "@" expands
a tool preset in place: a named list of patterns stored by the user.
Presets are referenced by name in patterns; they can not be enumerated
with this tool. The preset names come mainly from the user, or from
other tools that expose them. When you do not know of any preset, do
not worry about presets: there is nothing to do with them.

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

- On failure (invalid arguments, or the operation could not be
  performed), the result is {"error":"<reason>"}, e.g.
  {"error":"bad argument: pattern is not given or is empty"}.
- When the user rejects the approval request of "enable" or "disable",
  the result is {"rejected":"<reason>"}. No other operation asks for
  approval, and no other operation returns "rejected".
- Glob patterns can not match dot-prefixed (hidden) names; such
  patterns are rejected.
