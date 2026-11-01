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
