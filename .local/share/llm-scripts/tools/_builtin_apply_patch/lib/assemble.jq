"*** Begin Patch\n" +
(
  .operation |
  if .type == "create_file" then
    "*** Add File: " + .path + "\n"
  elif .type == "delete_file" then
    "*** Delete File: " + .path + "\n"
  elif .type == "update_file" then
    "*** Update File: " + .path + "\n"
  end +
  if .diff != null then
    (.diff // "" | if endswith("\n") | not then . + "\n" end)
  else
    ""
  end
) +
"*** End Patch\n"
