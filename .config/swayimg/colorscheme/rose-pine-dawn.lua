return function()
  -- Text overlay configuration
  swayimg.text.color = 0xff575279           -- foreground text color
  swayimg.text.background = 0xc0faf4ed      -- text background color
  swayimg.text.shadow = 0xff000000          -- text shadow color

  -- Image viewer mode
  swayimg.viewer.set_window_background(0x00000000) -- window background color
  swayimg.viewer.set_image_chessboard(20, 0xffdfdad9, 0xfffaf4ed) -- chessboard
  swayimg.viewer.mark_color = 0xff286983           -- mark icon color

  -- Gallery mode
  swayimg.gallery.border_color = 0xff56949f           -- border color for selected thumbnail
  swayimg.gallery.selected_color = 0xfffaf4ed         -- background color for selected thumbnail
  swayimg.gallery.unselected_color = 0xa0faf4ed       -- background color for unselected thumbnail
  swayimg.gallery.window_color = 0x00000000           -- window background color
end
