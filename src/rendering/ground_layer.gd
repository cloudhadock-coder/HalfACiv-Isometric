extends Node2D
const Iso=preload("res://src/world/iso.gd")
const CHUNK=8
var sim
var tiles: Dictionary={}
var chunks: Array=[]
var side: int=0
var last_view: Rect2
class TerrainChunk extends Node2D:
 var cells: Array=[]
 var ground
 var bounds: Rect2
 func _draw() -> void:
  for cell in cells:
   var kind=ground.sim.terrain[cell]
   if kind=="tree":kind="grass"
   if kind=="grass":kind=["grass","grass_1","grass_2","grass_3"][(cell.x*7+cell.y*13)%4]
   var delta=cell-ground.sim.centre()
   if absi(delta.x)<=1 and absi(delta.y)<=1 and kind!="water":kind="plaza"
   draw_texture(ground.tiles[kind],Iso.project(Vector2(cell))-Iso.TILE_ORIGIN)
func refresh() -> void:
 if sim==null:return
 if side!=sim.map_size():
  for chunk in chunks:remove_child(chunk);chunk.queue_free()
  chunks.clear();side=sim.map_size()
  for x in range(0,side,CHUNK):
   for y in range(0,side,CHUNK):
    var chunk=TerrainChunk.new();chunk.ground=self
    for xx in range(x,mini(x+CHUNK,side)):
     for yy in range(y,mini(y+CHUNK,side)):chunk.cells.append(Vector2i(xx,yy))
    var points=[Iso.project(Vector2(x-0.5,y-0.5)),Iso.project(Vector2(x+7.5,y-0.5)),Iso.project(Vector2(x+7.5,y+7.5)),Iso.project(Vector2(x-0.5,y+7.5))]
    var box=Rect2(points[0],Vector2.ZERO)
    for point in points:box=box.expand(point)
    chunk.bounds=box.grow(2);chunks.append(chunk);add_child(chunk)
 for chunk in chunks:chunk.queue_redraw()
 last_view=Rect2();queue_redraw()
func update_visible(camera: Camera2D) -> void:
 if camera==null:return
 var size=get_viewport_rect().size/camera.zoom
 var view=Rect2(camera.position-size/2,size).grow(2)
 if view==last_view:return
 last_view=view
 for chunk in chunks:chunk.visible=chunk.bounds.intersects(view)
func _draw() -> void:
 if sim==null:return
 var border=Iso.footprint(sim.map_size());var drop=Vector2(0,12)
 draw_colored_polygon(PackedVector2Array([border[3],border[2],border[2]+drop,border[3]+drop]),Color("424e4b"))
 draw_colored_polygon(PackedVector2Array([border[2],border[1],border[1]+drop,border[2]+drop]),Color("58625a"))
 draw_polyline(PackedVector2Array([border[3]+drop,border[2]+drop,border[1]+drop]),Color("182328"),2)
