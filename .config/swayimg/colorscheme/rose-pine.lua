return function()
  -- Text overlay configuration
  swayimg.text.color = 0xffe0def4           -- foreground text color
  swayimg.text.background = 0xc0191724      -- text background color
  swayimg.text.shadow = 0xff000000           -- text shadow color

  -- Image viewer mode
  swayimg.viewer.set_window_background(0x00000000) -- window background color
  swayimg.viewer.set_image_chessboard(20, 0xff1f1d2e, 0xff26233a) -- chessboard
  swayimg.viewer.mark_color = 0xff9ccfd8           -- mark icon color

  -- Gallery mode
  swayimg.gallery.border_color = 0xffc4a7e7           -- border color for selected thumbnail
  swayimg.gallery.selected_color = 0xff1f1d2e         -- background color for selected thumbnail
  swayimg.gallery.unselected_color = 0xa0191724       -- background color for unselected thumbnail
  swayimg.gallery.window_color = 0x00000000           -- window background color
end
