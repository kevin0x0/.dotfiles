# The functions below are used in comma streams like
#   ("" | print_strings, " | ", render_withflags(...))
# where jq parses the stream as "" | (print_strings, " | ", ...): the
# input of everything after the first comma is the empty string, so any
# "." reference inside the render_withflags arguments fails. Bind such
# values before the stream instead:
#   (.foo // ...) as $foo | ("" | print_strings, " | ", render_withflags(...; $foo ...))
def print_strings:
  "{\n",
  ":\n",
  (
    range(0;length;512) as $n | .[$n:$n+512] | "printf \"%s\" " + @sh + "\n"
  ),
  "}" ;

def render_withflags($kind; $flags):
  "sh -- " + ($libpath + "/render-" + $kind | @sh) + " " + $flags + " \"$@\"\n";

def render($kind):
  render_withflags($kind; "");
