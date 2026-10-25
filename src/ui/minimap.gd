extends Control
# World overview at the top of the right column (where classic 4X sidebars keep theirs): terrain,
# buildings, villagers and the camera's view. Click or drag to move the camera. The new-world
# screen reuses it, non-interactive, as the preview of a seed.
signal navigate(world_point: Vector2)
const Iso=preload("res://src/world/iso.gd")
const Catalog=preload("res://src/construction/catalog.gd")
const GROUND={"grass":Color("4d7338"),"tree":Color("2b4a27"),"water":Color("35627c"),"road":Color("9c8558"),"dirt":Color("79664e"),"sand":Color("c7b781"),"stone":Color("7d8c91")}
const PLAZA=Color("b3a57f")
const ROOFS={"Moradia":Color("c4643f"),"Alimentos":Color("d8bf55"),"Oficinas":Color("b9b3a6"),"Comunidade":Color("d39a5c")}
# World-space bounds of the 32x32 diamond (Iso.footprint).
var ORIGIN=Vector2(-1024,-16)
var EXTENT=Vector2(2048,1024)
var terrain: Dictionary={}
var buildings: Array=[]
var people: Array=[]
var view: PackedVector2Array=PackedVector2Array()
var interactive: bool=true
# The terrain is baked into a texture once per world (or size), so a redraw costs one draw call.
var ground: ImageTexture
var baked_for: Array=[]
var terrain_revision: int=0
var map_size: int=32
func _init() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;clip_contents=true;mouse_default_cursor_shape=Control.CURSOR_CROSS
 resized.connect(queue_redraw)
func show_world(t: Dictionary,b: Array,p: Array=[],v: PackedVector2Array=PackedVector2Array(),revision: int=0) -> void:
 terrain=t;buildings=b;people=p;view=v;terrain_revision=revision
 map_size=int(round(sqrt(t.size()))) if not t.is_empty() else 32
 ORIGIN=Vector2(-map_size*32,-16);EXTENT=Vector2(map_size*64,map_size*32)
 queue_redraw()
func factor() -> float:
 return minf(size.x/EXTENT.x,size.y/EXTENT.y)
func to_map(point: Vector2) -> Vector2:
 return (point-ORIGIN)*factor()+(size-EXTENT*factor())*0.5
func from_map(point: Vector2) -> Vector2:
 return (point-(size-EXTENT*factor())*0.5)/factor()+ORIGIN
func cell_polygon(cell: Vector2i,half: float=0.5) -> PackedVector2Array:
 var c=Vector2(cell)
 return PackedVector2Array([to_map(Iso.project(c+Vector2(-half,-half))),to_map(Iso.project(c+Vector2(half,-half))),to_map(Iso.project(c+Vector2(half,half))),to_map(Iso.project(c+Vector2(-half,half)))])
func bake() -> void:
 var w=maxi(1,int(size.x));var h=maxi(1,int(size.y))
 var image=Image.create(w,h,false,Image.FORMAT_RGBA8);image.fill(Color("0d1416"))
 for y in range(h):
  for x in range(w):
   var cell=Iso.tile(from_map(Vector2(x,y)+Vector2(0.5,0.5)))
   if not terrain.has(cell):continue
   var colour=GROUND.get(terrain[cell],GROUND.grass)
   if absi(cell.x-(map_size/2-1))<=1 and absi(cell.y-(map_size/2-1))<=1 and terrain[cell]!="water":colour=PLAZA
   image.set_pixel(x,y,colour)
 ground=ImageTexture.create_from_image(image);baked_for=[terrain,size,terrain_revision]
func _draw() -> void:
 if terrain.is_empty():draw_rect(Rect2(Vector2.ZERO,size),Color("0d1416"));return
 if baked_for.size()!=3 or not is_same(baked_for[0],terrain) or baked_for[1]!=size or baked_for[2]!=terrain_revision:bake()
 draw_texture(ground,Vector2.ZERO)
 for b in buildings:
  var colour=ROOFS.get(Catalog.DATA[b.kind].category,Color.WHITE)
  if b.get("remaining",0)>0:colour=colour.darkened(0.45)
  draw_colored_polygon(cell_polygon(Vector2i(int(b.x),int(b.y)),0.45),colour)
 for c in people:
  draw_rect(Rect2(to_map(Iso.project(c.position)).floor()-Vector2(1,1),Vector2(2,2)),Color("8a5a36") if c.horse_only else Color("f2e8c9"))
 if view.size()==4:
  var outline=PackedVector2Array()
  for point in view:outline.append(to_map(point).floor()+Vector2(0.5,0.5))
  outline.append(outline[0]);draw_polyline(outline,Color("f2e8c9"),1.0)
func _gui_input(event: InputEvent) -> void:
 if not interactive:return
 var press=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
 var drag=event is InputEventMouseMotion and event.button_mask&MOUSE_BUTTON_MASK_LEFT
 if press or drag:navigate.emit(from_map(event.position));accept_event()
