return function()
  -- Text overlay configuration
  swayimg.text.color = 0xffdcd7ba           -- foreground text color
  swayimg.text.background = 0xc01f1f28      -- text background color
  swayimg.text.shadow = 0xff000000           -- text shadow color

  -- Image viewer mode
  swayimg.viewer.set_window_background(0x00000000) -- window background color
  swayimg.viewer.set_image_chessboard(20, 0xff2a2a37, 0xff727169) -- chessboard
  swayimg.viewer.mark_color = 0xff7fb4ca           -- mark icon color

  -- Gallery mode
  swayimg.gallery.border_color = 0xff7e9cd8           -- border color for selected thumbnail
  swayimg.gallery.selected_color = 0xff2a2a37         -- background color for selected thumbnail
  swayimg.gallery.unselected_color = 0xa01f1f28       -- background color for unselected thumbnail
  swayimg.gallery.window_color = 0x00000000           -- window background color
end
