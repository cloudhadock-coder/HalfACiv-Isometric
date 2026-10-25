extends Node2D
const Iso=preload("res://src/world/iso.gd")
var sim
var people: Array=[]
var tiles: Dictionary={}
var characters: Array=[]
var horse: Texture2D
var hovered: Vector2i=Vector2i(-1,-1)
var build_kind: String=""
var selected_person: int=-1
var phase: float=0
var camera: Camera2D
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 for kind in ["grass","house","farm","lumber","quarry","market","chapel","mill","barracks","tower","wall","tree","water","road"]:tiles[kind]=load("res://assets/tilesets/"+kind+".png")
 for i in range(12):characters.append(load("res://assets/characters/"+str(i)+".png"))
 horse=load("res://assets/horses/horse.png")
func _process(delta: float) -> void:
 phase+=delta
 queue_redraw()
func visible_point(p: Vector2) -> bool:
 if camera==null:return true
 var extent=get_viewport_rect().size/camera.zoom/2.0+Vector2(100,100)
 return absf(p.x-camera.position.x)<extent.x and absf(p.y-camera.position.y)<extent.y
func draw_tile(kind: String,cell: Vector2i,tint: Color=Color.WHITE) -> void:
 var point=Iso.project(Vector2(cell))
 if visible_point(point):draw_texture(tiles[kind],point-Vector2(32,48),tint)
func _draw() -> void:
 if sim==null or tiles.is_empty():return
 for x in range(32):
  for y in range(32):
   var cell=Vector2i(x,y)
   var t=sim.terrain[cell]
   draw_tile("grass" if t=="tree" else t,cell)
   if t=="water" and visible_point(Iso.project(Vector2(cell))):
    var p=Iso.project(Vector2(cell))
    draw_line(p+Vector2(-12+sin(phase*2+x)*3,0),p+Vector2(6+sin(phase*2+x)*3,0),Color(0.6,0.9,0.9,0.35))
 var objects: Array=[]
 for cell in sim.terrain:
  if sim.terrain[cell]=="tree":objects.append({"y":Iso.project(Vector2(cell)).y,"type":0,"cell":cell})
 for b in sim.buildings:objects.append({"y":Iso.project(Vector2(b.x,b.y)).y,"type":1,"b":b})
 for i in range(people.size()):objects.append({"y":Iso.project(people[i].position).y,"type":2,"i":i})
 objects.sort_custom(func(a,b):return a.y<b.y)
 for obj in objects:
  if obj.type==0:draw_tile("tree",obj.cell)
  elif obj.type==1:
   var b=obj.b
   var cell=Vector2i(int(b.x),int(b.y))
   draw_tile(b.kind,cell,Color(1,1,1,0.55) if b.remaining>0 else Color.WHITE)
   var p=Iso.project(Vector2(cell))
   if b.remaining>0:
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38,3)),Color("252c32"))
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38*(1-b.remaining/float(sim.Catalog.DATA[b.kind].time)),3)),Color("ddbb72"))
   elif b.kind=="house":
    for j in range(3):
     var age=fmod(phase*0.5+j*0.32,1.0)
     draw_circle(p+Vector2(-11+sin(age*4)*3,-42-age*18),1+age*2,Color(0.8,0.8,0.7,(1-age)*0.35))
  else:
   var c=people[obj.i]
   var p=Iso.project(c.position)
   if not visible_point(p):continue
   var moving=not c.route.is_empty()
   var frame=int(c.clock*(7 if c.mounted else (8 if moving else 4)))% (8 if moving else 5)
   if selected_person==obj.i:draw_arc(p+Vector2(0,2),10,0,TAU,20,Color("e3c77e"),1)
   if c.mounted or c.horse_only:
    draw_texture_rect_region(horse,Rect2(p-Vector2(24,36),Vector2(48,48)),Rect2(int(c.clock*7)%8*64,64 if moving else 0,64,64))
   if not c.horse_only:
    if c.mounted:
     var bob=[0,0,-1,-1,0,0,1,1][int(c.clock*7)%8]*0.75
     draw_texture_rect_region(characters[c.kind],Rect2(p-Vector2(13,43-bob),Vector2(30,25)),Rect2(frame*48,56 if moving else 0,48,40))
     draw_line(p+Vector2(5,-18+bob),p+Vector2(10,-12+bob),Color("535e75"),3)
     draw_line(p+Vector2(10,-12+bob),p+Vector2(8,-4+bob),Color("302d32"),3)
    else:
     draw_texture_rect_region(characters[c.kind],Rect2(p-Vector2(15,33),Vector2(30,35)),Rect2(frame*48,56 if moving else 0,48,56))
 if sim.valid(hovered):
  var p=Iso.project(Vector2(hovered))
  var col=Color("e7ca88") if build_kind.is_empty() or sim.can_build(build_kind,hovered) else Color("e17765")
  var points=PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0),p+Vector2(0,-16)])
  draw_polyline(points,col,1.5)
  if not build_kind.is_empty():draw_tile(build_kind,hovered,Color(1,1,1,0.55))
