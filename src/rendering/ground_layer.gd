extends Node2D
const Iso=preload("res://src/world/iso.gd")
var sim
var tiles: Dictionary={}

func _draw() -> void:
 if sim==null:return
 for x in range(32):
  for y in range(32):
   var cell=Vector2i(x,y)
   var kind=sim.terrain[cell]
   if kind=="tree":kind="grass"
   if kind=="grass":kind=["grass","grass_1","grass_2","grass_3"][(x*7+y*13)%4]
   if abs(x-15)<=1 and abs(y-15)<=1 and sim.terrain[cell]!="water":kind="plaza"
   draw_texture(tiles[kind],Iso.project(Vector2(cell))-Vector2(32,48))
