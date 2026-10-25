extends Node2D
const Iso=preload("res://src/world/iso.gd")
var sim
var tiles: Dictionary={}

func _draw() -> void:
 if sim==null:return
 var border=Iso.footprint()
 var drop=Vector2(0,12)
 draw_colored_polygon(PackedVector2Array([border[3],border[2],border[2]+drop,border[3]+drop]),Color("424e4b"))
 draw_colored_polygon(PackedVector2Array([border[2],border[1],border[1]+drop,border[2]+drop]),Color("58625a"))
 draw_polyline(PackedVector2Array([border[3]+drop,border[2]+drop,border[1]+drop]),Color("182328"),2)
 for x in range(32):
  for y in range(32):
   var cell=Vector2i(x,y)
   var kind=sim.terrain[cell]
   if kind=="tree":kind="grass"
   if kind=="grass":kind=["grass","grass_1","grass_2","grass_3"][(x*7+y*13)%4]
   if abs(x-15)<=1 and abs(y-15)<=1 and sim.terrain[cell]!="water":kind="plaza"
   draw_texture(tiles[kind],Iso.project(Vector2(cell))-Iso.TILE_ORIGIN)
