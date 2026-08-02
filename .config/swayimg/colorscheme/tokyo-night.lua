return function()
  -- Text overlay configuration
  swayimg.text.color = 0xffc0caf5           -- foreground text color
  swayimg.text.background = 0xc01a1b26      -- text background color
  swayimg.text.shadow = 0xff000000           -- text shadow color

  -- Image viewer mode
  swayimg.viewer.set_window_background(0x00000000) -- window background color
  swayimg.viewer.set_image_chessboard(20, 0xff3b4261, 0xff565f89) -- chessboard
  swayimg.viewer.mark_color = 0xff7dcfff           -- mark icon color

  -- Gallery mode
  swayimg.gallery.border_color = 0xff7aa2f7           -- border color for selected thumbnail
  swayimg.gallery.selected_color = 0xff3b4261         -- background color for selected thumbnail
  swayimg.gallery.unselected_color = 0xa01a1b26       -- background color for unselected thumbnail
  swayimg.gallery.window_color = 0x00000000           -- window background color
end
