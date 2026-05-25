
-- General config
swayimg.set_mode("viewer")                -- mode at startup
swayimg.enable_antialiasing(true)         -- anti-aliasing
swayimg.enable_decoration(true)           -- window title/buttons/borders
swayimg.enable_overlay(true)             -- window overlay mode
swayimg.enable_exif_orientation(true)     -- image orientation by EXIF
swayimg.set_dnd_button("MouseRight")      -- drag-and-drop mouse button

-- Image list configuration
swayimg.imagelist.set_order("alpha")      -- list order
swayimg.imagelist.enable_reverse(false)   -- reverse order
swayimg.imagelist.enable_recursive(false) -- recursive directory reading
swayimg.imagelist.enable_adjacent(false)  -- add adjacent files from same dir
swayimg.imagelist.enable_fsmon(true)      -- enable file system monitoring

-- Text overlay configuration
swayimg.text.set_font("monospace")        -- font name
swayimg.text.set_size(16)                 -- font size in pixels
swayimg.text.set_spacing(0)               -- line spacing
swayimg.text.set_padding(10)              -- padding from window edge
swayimg.text.set_foreground(0xff4ca491)   -- foreground text color
swayimg.text.set_background(0xa0000000)   -- text background color
swayimg.text.set_shadow(0xff000000)       -- text shadow color
swayimg.text.set_timeout(5)               -- layer hide timeout
swayimg.text.set_status_timeout(3)        -- status message hide timeout

-- Image viewer mode
swayimg.viewer.set_default_scale("optimal")      -- default image scale
swayimg.viewer.set_default_position("center")    -- default image position
swayimg.viewer.set_drag_button("MouseLeft")      -- mouse button to drag image
swayimg.viewer.set_window_background(0x00000000) -- window background color
swayimg.viewer.set_image_chessboard(20, 0xff333333, 0xff4c4c4c) -- chessboard
swayimg.viewer.enable_centering(true)            -- enable automatic centering
swayimg.viewer.enable_loop(true)                 -- enable image list loop mode
swayimg.viewer.limit_preload(1)                  -- number of images to preload
swayimg.viewer.limit_history(1)                  -- number of the history cache
swayimg.viewer.set_mark_color(0xff808080)        -- mark icon color
swayimg.viewer.set_pinch_factor(1.0)             -- pinch gesture factor
swayimg.viewer.set_text("topleft", {             -- top left text block scheme
  "File: {name}",
  "Format: {format}",
  "File size: {sizehr}",
  "File time: {time}",
  "EXIF date: {meta.Exif.Photo.DateTimeOriginal}",
  "EXIF camera: {meta.Exif.Image.Model}"
})
swayimg.viewer.set_text("topright", {            -- top right text block scheme
  "Image: {list.index} of {list.total}",
  "Frame: {frame.index} of {frame.total}",
  "Size: {frame.width}x{frame.height}"
})
swayimg.viewer.set_text("bottomleft", {          -- bottom left text block scheme
  "Scale: {scale}"
})

-- helper function
local function toggle_info()
  if swayimg.text.visible() then
    swayimg.text.hide()
  else
    swayimg.text.show()
  end
end

local function move_image(dir)
  local wnd = swayimg.get_window_size()
  local pos = swayimg.viewer.get_position()
  local new_x, new_y = pos.x, pos.y
  if dir == "left" then
    new_x = new_x + wnd.width / 10
  elseif dir == "right" then
    new_x = new_x - wnd.width / 10
  elseif dir == "up" then
    new_y = new_y + wnd.width / 10
  elseif dir == "down" then
    new_y = new_y - wnd.width / 10
  end
  new_x = math.floor(new_x)
  new_y = math.floor(new_y)
  swayimg.viewer.set_abs_position(new_x, new_y)
end

local function zoom(step)
  local scale = swayimg.viewer.get_scale()
  scale = scale + step * scale
  swayimg.viewer.set_abs_scale(scale);
end

local function zoom_at_mouse(step)
  local pos = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.get_scale()
  scale = scale + step * scale
  swayimg.viewer.set_abs_scale(scale, pos.x, pos.y);
end

local toggle_anti_aliasing = (function()
  local enabled = true
  return function()
    swayimg.enable_antialiasing(not enabled)
    enabled = not enabled
  end
end)()

local function delete()
  local image = swayimg.slideshow.get_image()
  os.remove(image.path)
  swayimg.text.set_status("File "..image.path.." removed")
end
-- Key and mouse bindings in viewer mode (example only, not all):

swayimg.viewer.on_key("g", function()
  swayimg.viewer.switch_image("first")
end)
swayimg.viewer.on_key("Shift+g", function()
  swayimg.viewer.switch_image("last")
end)
swayimg.viewer.on_key("p", function()
  swayimg.viewer.switch_image("prev")
end)
swayimg.viewer.on_key("n", function()
  swayimg.viewer.switch_image("next")
end)
swayimg.viewer.on_key("Space", function()
  print(swayimg.viewer.get_image().path)
  swayimg.exit()
end)
swayimg.viewer.on_key("Shift+r", function()
  swayimg.viewer.switch_image("random")
end)
swayimg.viewer.on_key("d", function()
  swayimg.viewer.switch_image("next_dir")
end)
swayimg.viewer.on_key("Shift+d", function()
  swayimg.viewer.switch_image("prev_dir")
end)
swayimg.viewer.on_key("o", swayimg.viewer.next_frame)
swayimg.viewer.on_key("Shift+o", swayimg.viewer.prev_frame)
swayimg.viewer.on_key("s", swayimg.viewer.set_animation)
swayimg.viewer.on_key("Shift+s", function()
  swayimg.set_mode("slideshow")
end)
swayimg.viewer.on_key("f", swayimg.set_fullscreen)
swayimg.viewer.on_key("Return", function()
  swayimg.set_mode("gallery")
end)

swayimg.viewer.on_key("h", function()
  move_image("left")
end)
swayimg.viewer.on_key("j", function()
  move_image("down")
end)
swayimg.viewer.on_key("k", function()
  move_image("up")
end)
swayimg.viewer.on_key("l", function()
  move_image("right")
end)

swayimg.viewer.on_key("Equal", function()
  zoom(0.05)
end)
swayimg.viewer.on_key("Shift+plus", function()
  zoom(0.2)
end)
swayimg.viewer.on_key("Minus", function()
  zoom(-0.05)
end)
swayimg.viewer.on_key("Shift+underscore", function()
  zoom(-0.2)
end)

swayimg.viewer.on_key("w", function()
  swayimg.viewer.set_fix_scale("width")
end)
swayimg.viewer.on_key("Shift+w", function()
  swayimg.viewer.set_fix_scale("height")
end)
swayimg.viewer.on_key("z", function()
  swayimg.viewer.set_fix_scale("fit")
end)
swayimg.viewer.on_key("Shift+z", function()
  swayimg.viewer.set_fix_scale("fill")
end)
swayimg.viewer.on_key("0", function()
  swayimg.viewer.set_fix_scale("real")
end)
swayimg.viewer.on_key("BackSpace", function()
  swayimg.viewer.set_fix_scale("optimal")
end)
swayimg.viewer.on_key("Alt+z", function()
  swayimg.viewer.set_fix_scale("keep")
end)

swayimg.viewer.on_key("bracketleft", function()
  swayimg.viewer.rotate(270)
end)
swayimg.viewer.on_key("bracketright", function()
  swayimg.viewer.rotate(90)
end)

swayimg.viewer.on_key("m", swayimg.viewer.flip_vertical)
swayimg.viewer.on_key("Shift+m", swayimg.viewer.flip_horizontal)

swayimg.viewer.on_key("a", toggle_anti_aliasing)

swayimg.viewer.on_key("r", swayimg.viewer.reload)
swayimg.viewer.on_key("i", toggle_info)

swayimg.viewer.on_key("Delete", delete)

swayimg.viewer.on_key("Escape", swayimg.exit)
swayimg.viewer.on_key("q", swayimg.exit)

-- bind mouse vertical scroll button with pressed Ctrl to zoom in the image at mouse pointer coordinates
swayimg.viewer.on_mouse("Ctrl-ScrollUp", function()
  zoom_at_mouse(0.1)
end)
swayimg.viewer.on_mouse("Ctrl-ScrollDown", function()
  zoom_at_mouse(-0.1)
end)


-- Slide show mode, same config as for viewer mode with the following defaults:
swayimg.slideshow.set_timeout(5)                    -- timeout to switch image
swayimg.slideshow.set_default_scale("fit")          -- default image scale
swayimg.slideshow.set_window_background("auto")     -- window background mode
swayimg.slideshow.limit_history(0)                  -- number of the history cache
swayimg.slideshow.set_text("topleft", { "{name}" }) -- top left text block scheme

swayimg.slideshow.on_key("g", function()
  swayimg.slideshow.switch_image("first")
end)
swayimg.slideshow.on_key("Shift+g", function()
  swayimg.slideshow.switch_image("last")
end)
swayimg.slideshow.on_key("p", function()
  swayimg.slideshow.switch_image("prev")
end)
swayimg.slideshow.on_key("n", function()
  swayimg.slideshow.switch_image("next")
end)
swayimg.slideshow.on_key("Shift+r", function()
  swayimg.slideshow.switch_image("random")
end)
swayimg.slideshow.on_key("d", function()
  swayimg.slideshow.switch_image("next_dir")
end)
swayimg.slideshow.on_key("i", toggle_info)
swayimg.slideshow.on_key("f", swayimg.set_fullscreen)
swayimg.slideshow.on_key("Return", function()
  swayimg.set_mode("gallery")
end)
swayimg.slideshow.on_key("Escape", swayimg.exit)
swayimg.slideshow.on_key("q", swayimg.exit)

-- Gallery mode
swayimg.gallery.set_aspect("fill")                  -- thumbnail aspect ratio
swayimg.gallery.set_thumb_size(200)                 -- thumbnail size in pixels
swayimg.gallery.set_padding_size(5)                 -- padding between thumbnails
swayimg.gallery.set_border_size(5)                  -- border size for selected thumbnail
swayimg.gallery.set_border_color(0xffaaaaaa)        -- border color for selected thumbnail
swayimg.gallery.set_selected_scale(1.15)            -- scale for selected thumbnail
swayimg.gallery.set_selected_color(0xff404040)      -- background color for selected thumbnail
swayimg.gallery.set_unselected_color(0xa0202020)    -- background color for unselected thumbnail
swayimg.gallery.set_window_color(0x00000000)        -- window background color
swayimg.gallery.set_pinch_factor(100.0)             -- pinch gesture factor
swayimg.gallery.limit_cache(100)                    -- number of thumbnails stored in memory
swayimg.gallery.enable_preload(false)               -- preloading invisible thumbnails
swayimg.gallery.enable_pstore(false)                -- enable persistent storage for thumbnails
swayimg.gallery.set_text("topleft", {               -- top left text block scheme
  "File: {name}"
})
swayimg.gallery.set_text("topright", {              -- top right text block scheme
  "{list.index} of {list.total}"
})

-- Key and mouse bindings in gallery mode (example only, not all):

-- bind Enter key to open image in viewer
swayimg.gallery.on_key("Return", function()
  swayimg.set_mode("viewer")
end)

swayimg.gallery.on_key("g", function()
  swayimg.gallery.switch_image("first")
end)
swayimg.gallery.on_key("Shift+g", function()
  swayimg.gallery.switch_image("last")
end)
swayimg.gallery.on_key("h", function()
  swayimg.gallery.switch_image("left")
end)
swayimg.gallery.on_key("j", function()
  swayimg.gallery.switch_image("down")
end)
swayimg.gallery.on_key("k", function()
  swayimg.gallery.switch_image("up")
end)
swayimg.gallery.on_key("l", function()
  swayimg.gallery.switch_image("right")
end)
swayimg.gallery.on_key("p", function()
  swayimg.gallery.switch_image("pgup")
end)
swayimg.gallery.on_key("n", function()
  swayimg.gallery.switch_image("pgdown")
end)
swayimg.gallery.on_key("Shift+s", function()
  swayimg.set_mode("slideshow")
end)
swayimg.gallery.on_key("f", swayimg.set_fullscreen)
swayimg.gallery.on_key("a", toggle_anti_aliasing)
swayimg.gallery.on_key("i", toggle_info)
swayimg.gallery.on_key("Space", function()
  print(swayimg.gallery.get_image().path)
  swayimg.exit()
end)
swayimg.gallery.on_key("Delete", delete)
swayimg.gallery.on_key("Escape", swayimg.exit)
swayimg.gallery.on_key("q", swayimg.exit)

--
-- Other configuration examples
--

-- force set scale mode on window resize (useful for tiling compositors)
swayimg.on_window_resize(function()
  if swayimg.get_mode() == "viewer" then
    swayimg.viewer.set_fix_scale("optimal")
  end
end)

-- set a custom window title in gallery mode
swayimg.gallery.on_image_change(function()
  local image = swayimg.gallery.get_image()
  swayimg.set_title("Gallery: "..image.path)
end)
