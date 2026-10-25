extends Control

# Draws a portrait at the largest whole number of *screen* pixels per texture pixel that fits,
# centred and snapped to the screen grid, nearest-neighbour. Compensates the HUD and window
# stretch so pixel art is never resampled at fractional scales nor cropped.
var texture: Texture2D:
 set(value):
  texture=value;queue_redraw()
func _init() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;mouse_filter=Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw);item_rect_changed.connect(queue_redraw)
func to_screen() -> Transform2D:
 # canvas_items window stretch lives in the viewport's final transform, not the canvas transform.
 return get_viewport().get_final_transform()*get_global_transform_with_canvas() if is_inside_tree() else Transform2D.IDENTITY
func screen_factor() -> float:
 return to_screen().get_scale().x
func display_scale() -> int:
 if texture==null:return 1
 var s=texture.get_size()/screen_factor();return maxi(1,int(min(floor(size.x/s.x),floor(size.y/s.y))))
func _draw() -> void:
 if texture==null:return
 var g=screen_factor();var shown=texture.get_size()*display_scale()
 var origin=to_screen().origin
 var offset=((origin+(size*g-shown)/2).floor()-origin)/g
 draw_texture_rect(texture,Rect2(offset,shown/g),false)
