# manage_tools

Supplementary reference for managing the session tool sets and
exploring the tool system. The tool description covers the operations
and the tool sets; this document explains the interface details and
shows example results.

# Operations

The examples pair a call with the result it returns; the tool names in
them are fictitious. Empty results are usually empty lists.

## describe

- When a tool's signature is a stub, retrieve the full one with
  "describe" before calling the tool.
- Each returned tool carries a tool signature. "name" and "description"
  are present for "function" and "custom" tools: "name" is the tool's
  name, "description" explains what the tool does and how to call it
  (it may be empty). A "function" tool additionally has a "parameters"
  field holding the JSON schema of its arguments; a "custom" tool has
  no "parameters" field. A builtin tool ("_builtin_*") has only a
  "type" field holding its kind, e.g. "web_search": no "name",
  "description" or "parameters".

Fields: "described" (the number of entries in "tools"), "tools" (the
tool signatures, sorted by name).

For {"operation":"describe","pattern":"some_*"}:

    {"described":2,"tools":[
      {"type":"function","name":"some_helper","description":"...","parameters":{...}},
      {"type":"function","name":"some_tool","description":"...","parameters":{...}}
    ]}

No matching tool:

    {"described":0,"tools":[]}

A tool without a parameters schema:

    {"described":1,"tools":[{"type":"custom","name":"bare_tool","description":"..."}]}

A builtin tool:

    {"described":1,"tools":[{"type":"web_search"}]}

## list

- With "enabled": the enabled tool set (the default and the extra set
  together); "pattern" does not apply.
- Paging: see Pagination.

Fields: "list" (the entries of this page; each entry has a "name" or a
"path", plus a "summary" when requested), "total" (the number of all
matching entries, independent of paging), "start_index" (the offset of
this page), "count" (the number of entries in this page).

For {"operation":"list","pattern":"some_*","with_summary":true}:

    {"list":[{"name":"some_helper","summary":"..."},{"name":"some_tool","summary":"..."}],"total":2,"start_index":0,"count":2}

A tree-mode match (paths in the tool tree; directory entries end
with "/"):

For {"operation":"list","pattern":"category/*"}:

    {"list":[{"path":"category/sub/"},{"path":"category/some_tool"}],"total":2,"start_index":0,"count":2}

A tree-mode match with summaries:

For {"operation":"list","pattern":"category/*","with_summary":true}:

    {"list":[{"path":"category/sub/","summary":"..."},{"path":"category/some_tool","summary":"..."}],"total":2,"start_index":0,"count":2}

No matching tool, or an empty extra tool set:

    {"list":[],"total":0,"start_index":0,"count":0}

The enabled tool set:

For {"operation":"list","enabled":true,"with_summary":true}:

    {"list":[{"name":"some_default","summary":"..."},{"name":"some_helper","summary":"..."}],"total":2,"start_index":0,"count":2}

## doc

- Paths naming a directory are silently omitted as well.

Fields: "toolname" (the named tool), "docs" (the found documents; each
entry has "docpath" and "content").

For {"operation":"doc","toolname":"some_tool","docpaths":["README.md","reference/usage.md"]}:

    {"toolname":"some_tool","docs":[
      {"docpath":"README.md","content":"# some_tool\n\n..."},
      {"docpath":"reference/usage.md","content":"..."}
    ]}

All requested documents missing:

    {"toolname":"some_tool","docs":[]}

## listdoc

- The documents of a tool live in a directory of their own; the listed
  paths are relative to that directory.
- The list is sorted and deduplicated.

Fields: "toolname" (the named tool), "doclist" (the listed document
paths).

For {"operation":"listdoc","toolname":"some_tool"}:

    {"toolname":"some_tool","doclist":["README.md","reference/usage.md"]}

A tool without documents, or no matching document:

    {"toolname":"some_tool","doclist":[]}

## enable / disable

They adjust the session's extra tool set; their semantics, the
approval requirement and the constraint on using them are in the tool
description.

Fields: "added_tools"/"removed_tools" (the tools that were added or
removed) and "count" (their number).

For {"operation":"enable","pattern":"some_*"}:

    {"added_tools":["some_helper","some_tool"],"count":2}

For {"operation":"disable","pattern":"some_*"}:

    {"removed_tools":["some_helper","some_tool"],"count":2}

Ignored tools (do not exist, or the operation has no effect on them):

    {"added_tools":[],"count":0}

- The default tool set is not affected by enable or disable.
- After enabling a tool, use "describe" to retrieve its full signature
  when the session loads extra tools as stubs.

# Patterns

The pattern semantics are in the tool description. A pattern that is
only whitespace matches nothing. Presets are referenced by name in
patterns; they can not be enumerated with this tool. The preset names
come mainly from the user, or from other tools that expose them. When
you do not know of any preset, do not worry about presets: there is
nothing to do with them.

Recipes:

- "/*"          top level of the tool tree
- "builtin/*"   entries directly under the builtin category
- "cat1/*/"     category directories under cat1 (ends with "/")
- "manage_*"    tools whose name starts with "manage_"
- "manage_* builtin/*"  name mode and tree mode mixed in one list; an
  entry matches when it matches either
- "m?"          tools whose name has two characters and starts with "m"
- "[a-z]*"      tools whose name starts with a lowercase letter
- "[!m]*"       tools whose name does not start with "m"
- "[![:alnum:]]*"  tools whose name does not start with an alphanumeric
  character
- "shell"       the exact tool name
- "*"           all tools (name mode)
- "@default"    the tools of a named preset; can be mixed with other words

# Pagination

Only "list" is paginated; describe, doc, listdoc, enable and disable
return their complete results. "list" returns at most "count" items
(default 20) starting at "start_index" (default 0); "count" has no
upper bound. "total" is the size of the full result. The order of the
full result is stable, so
successive pages are consistent slices of it. The page is clamped to
the result: a "start_index" beyond "total" returns an empty page, and a
"count" beyond the remaining items returns only the rest; the returned
"start_index" and "count" report the clamped page. A "count" of 0
returns an empty page; negative values return an error. To obtain
everything at once, request as many
items as the "total" reported by a previous result; page only when the
result is large.

# Errors and edge cases

- On failure (invalid arguments, or the operation could not be
  performed), the result is {"error":"<reason>"}, e.g. from "enable" or
  "disable" without a "pattern":
  {"error":"bad argument: pattern is not given or is empty"}.
- Glob patterns can not match dot-prefixed (hidden) names; such
  patterns are rejected.
