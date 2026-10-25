extends Node2D
const Iso=preload("res://src/world/iso.gd")
const Ground=preload("res://src/rendering/ground_layer.gd")
const FX=preload("res://src/rendering/environment_fx.gd")
const Professions=preload("res://src/entities/professions.gd")
var sim
var people: Array=[]
var tiles: Dictionary={}
var characters: Array=[]
var animated: Dictionary={}
var horse: Texture2D
var hovered: Vector2i=Vector2i(-1,-1)
var build_kind: String=""
var selected_person: int=-1
var selected_building: int=-1
var phase: float=0
var camera: Camera2D
var ground
var static_objects: Array=[]
var water_cells: Array=[]
var seen_revision: int=-1
var animate: bool=true
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var names=sim.Catalog.DATA.keys()+["grass","grass_1","grass_2","grass_3","tree","water","road","plaza"]
 for kind in names:tiles[kind]=load("res://assets/tilesets/"+kind+".png")
 for i in range(24):characters.append(load("res://assets/characters/"+str(i)+".png"))
 for kind in ["mill","tower"]:animated[kind]=load("res://assets/buildings/"+kind+"_animation.png")
 horse=load("res://assets/horses/horse.png")
 ground=Ground.new();ground.sim=sim;ground.tiles=tiles;ground.show_behind_parent=true;add_child(ground)
 refresh()
func refresh() -> void:
 people=sim.people;static_objects.clear();water_cells.clear()
 for cell in sim.terrain:
  if sim.terrain[cell]=="tree":static_objects.append({"y":Iso.project(Vector2(cell)).y,"type":0,"cell":cell})
  elif sim.terrain[cell]=="water":water_cells.append(cell)
 for i in range(sim.buildings.size()):
  var b=sim.buildings[i];static_objects.append({"y":Iso.project(Vector2(b.x,b.y)).y,"type":1,"index":i})
 seen_revision=sim.revision;ground.sim=sim;ground.queue_redraw()
func _process(delta: float) -> void:
 if animate:phase+=delta
 if seen_revision!=sim.revision or people!=sim.people:refresh()
 var daylight=clampf((sim.hour()-5.0)/2.0,0,1)*clampf((22.0-sim.hour())/3.0,0,1)
 modulate=Color("8e9ab2").lerp(Color.WHITE,daylight)
 queue_redraw()
func visible_point(p: Vector2) -> bool:
 if camera==null:return true
 var extent=get_viewport_rect().size/camera.zoom/2.0+Vector2(100,100)
 return absf(p.x-camera.position.x)<extent.x and absf(p.y-camera.position.y)<extent.y
func draw_tile(kind: String,cell: Vector2i,tint: Color=Color.WHITE) -> void:
 var point=Iso.project(Vector2(cell))
 if not visible_point(point):return
 if kind in animated:
  draw_texture_rect_region(animated[kind],Rect2(point-Vector2(32,48),Vector2(64,64)),Rect2(int(phase*(5 if kind=="mill" else 7))%4*64,0,64,64),tint)
 else:draw_texture(tiles[kind],point-Vector2(32,48),tint)
func person_point(c) -> Vector2:
 var alpha=clampf(sim.elapsed/sim.STEP,0,1) if animate else 1.0
 return Iso.project(c.previous.lerp(c.position,alpha)).round()
func diamond(cell: Vector2i,colour: Color,width: float=1) -> void:
 var p=Iso.project(Vector2(cell))
 draw_polyline(PackedVector2Array([p+Vector2(0,-16),p+Vector2(32,0),p+Vector2(0,16),p+Vector2(-32,0),p+Vector2(0,-16)]),colour,width)
func _draw() -> void:
 if sim==null or tiles.is_empty():return
 for cell in water_cells:
  var p=Iso.project(Vector2(cell))
  if visible_point(p) and (cell.x+cell.y)%3==0:
   var ripple=round(sin(phase*1.5+cell.y)*4)
   draw_line(p+Vector2(-9+ripple,0),p+Vector2(5+ripple,0),Color(0.67,0.83,0.8,0.25))
 var objects=static_objects.duplicate()
 for i in range(people.size()):objects.append({"y":Iso.project(people[i].position).y,"type":2,"i":i})
 objects.sort_custom(func(a,b):return a.y<b.y if a.y!=b.y else a.type<b.type)
 for obj in objects:
  if obj.type==0:
   var p=Iso.project(Vector2(obj.cell))
   if visible_point(p):
    var sway=round(sin(phase*1.6+obj.cell.x*0.7+obj.cell.y)*0.8)
    draw_texture_rect_region(tiles.tree,Rect2(p-Vector2(32,6),Vector2(64,22)),Rect2(0,42,64,22))
    draw_texture_rect_region(tiles.tree,Rect2(p-Vector2(32-sway,48),Vector2(64,42)),Rect2(0,0,64,42))
  elif obj.type==1:
   var b=sim.buildings[obj.index];var cell=Vector2i(int(b.x),int(b.y));var p=Iso.project(Vector2(cell))
   if not visible_point(p):continue
   if selected_building==obj.index:diamond(cell,Color("e5c582"),1.5)
   draw_tile(b.kind,cell,Color(1,1,1,0.52) if b.remaining>0 else Color.WHITE)
   if b.remaining>0:
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38,3)),Color("252c32"))
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38*(1-b.remaining/float(sim.Catalog.DATA[b.kind].time)),3)),Color("ddbb72"))
   else:
    if b.kind in ["house","bakery","tavern","forge"]:FX.smoke(self,p+Vector2(-10,-34),phase+obj.index)
    if b.kind=="forge":FX.fire(self,p+Vector2(-1,-5),phase)
    if b.kind in ["tavern","chapel"] and (sim.hour()>18 or sim.hour()<7):
     draw_rect(Rect2(p+Vector2(5,-14),Vector2(3,4)),Color("e2b264"))
  else:
   var c=people[obj.i];var p=person_point(c)
   if not visible_point(p):continue
   var moving=not c.route.is_empty();var working=c.task in ["work","build","collect"] and not moving
   var row=1 if moving else (2 if working and c.kind==c.portrait_id else 0)
   var frame=int(c.clock*(7 if c.mounted else (8 if moving else 5)))%(8 if moving or working else 5)
   draw_ellipse_shadow(p)
   if selected_person==obj.i:draw_arc(p+Vector2(0,2),10,0,TAU,20,Color("e3c77e"),1)
   if c.mounted or c.horse_only:
    draw_texture_rect_region(horse,Rect2(p-Vector2(24,36),Vector2(48,48)),Rect2(int(c.clock*7)%8*64,64 if moving else 0,64,64))
   if not c.horse_only:
    if c.mounted:
     var bob=[0,0,-1,-1,0,0,1,1][int(c.clock*7)%8]*0.75
     draw_texture_rect_region(characters[c.portrait_id],Rect2(p-Vector2(13,43-bob),Vector2(30,25)),Rect2(frame*48,56 if moving else 0,48,40))
     draw_line(p+Vector2(5,-18+bob),p+Vector2(10,-12+bob),Color("535e75"),3);draw_line(p+Vector2(10,-12+bob),p+Vector2(8,-4+bob),Color("302d32"),3)
    else:draw_texture_rect_region(characters[c.portrait_id],Rect2(p-Vector2(15,33),Vector2(30,35)),Rect2(frame*48,row*56,48,56))
    if working:
     FX.work_effect(self,p,phase,Professions.DATA[c.kind].tool)
     if c.kind!=c.portrait_id:FX.held_tool(self,p,phase,Professions.DATA[c.kind].tool)
    if not c.cargo.is_empty():FX.cargo(self,p,c.cargo)
    if c.task=="sleep":
     draw_rect(Rect2(p+Vector2(5,-32),Vector2(3,1)),Color("b7c3d0"))
     draw_rect(Rect2(p+Vector2(7,-35),Vector2(2,1)),Color("b7c3d0"))
 if sim.valid(hovered):
  var colour=Color("e7ca88") if build_kind.is_empty() or sim.can_build(build_kind,hovered) else Color("d57d69")
  diamond(hovered,colour,1.5)
  if not build_kind.is_empty():draw_tile(build_kind,hovered,Color(1,1,1,0.55))
func draw_ellipse_shadow(p: Vector2) -> void:
 draw_colored_polygon(PackedVector2Array([p+Vector2(-7,0),p+Vector2(-3,-2),p+Vector2(5,-2),p+Vector2(8,0),p+Vector2(4,2),p+Vector2(-4,2)]),Color(0.07,0.13,0.13,0.23))
