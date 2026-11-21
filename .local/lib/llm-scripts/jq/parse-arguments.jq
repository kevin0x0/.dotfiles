def parse_simple_string:
  . // "" | tostring | gsub("\n"; " ");

def parse_string:
  . // "" | tostring |
    gsub("\\\\"; "\\\\") | gsub("'"; "\\'") | gsub("\n"; "\\n") |
    "$'" + . + "'";

def parse_string_array_with_filter(f):
  . // [] | if type != "array" then [.] end |
    map(f | parse_string) | join(" ") | if length == 0 then " " end;

def parse_string_array:
  parse_string_array_with_filter(.);

def parse_integer($default):
  if type != "number" then $default end | floor;

def parse_boolean:
  if . then "1" else " " end;
