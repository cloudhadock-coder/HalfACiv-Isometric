extends CanvasLayer
var canvas: Node2D
func _ready() -> void:
 layer=-10;canvas=TableSurface.new();add_child(canvas)
 get_viewport().size_changed.connect(func():canvas.queue_redraw())
class TableSurface extends Node2D:
 func _draw() -> void:
  var size=get_viewport_rect().size
  draw_rect(Rect2(Vector2.ZERO,size),Color("1e282c"))
  # Subdued slate/table pattern: deliberate board backdrop, not fake terrain.
  for y in range(0,int(size.y),48):
   draw_line(Vector2(0,y),Vector2(size.x,y),Color(0.21,0.25,0.26,0.22))
  for x in range(-int(size.y),int(size.x),96):
   draw_line(Vector2(x,0),Vector2(x+size.y,size.y),Color(0.22,0.26,0.27,0.12))
