return function()
  -- Text overlay configuration
  swayimg.text.color = 0xff657b83           -- foreground text color
  swayimg.text.background = 0xc0eee8d5      -- text background color
  swayimg.text.shadow = 0xff000000          -- text shadow color

  -- Image viewer mode
  swayimg.viewer.set_window_background(0x00000000) -- window background color
  swayimg.viewer.set_image_chessboard(20, 0xfffdf6e3, 0xffeee8d5) -- chessboard
  swayimg.viewer.mark_color = 0xff2aa198           -- mark icon color

  -- Gallery mode
  swayimg.gallery.border_color = 0xff268bd2           -- border color for selected thumbnail
  swayimg.gallery.selected_color = 0xffeee8d5         -- background color for selected thumbnail
  swayimg.gallery.unselected_color = 0xa0eee8d5       -- background color for unselected thumbnail
  swayimg.gallery.window_color = 0x00000000           -- window background color
end
