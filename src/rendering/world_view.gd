extends Node2D
const Iso=preload("res://src/world/iso.gd")
const Ground=preload("res://src/rendering/ground_layer.gd")
const FX=preload("res://src/rendering/environment_fx.gd")
const Policy=preload("res://src/rendering/render_policy.gd")
const BuildingArt=preload("res://src/rendering/building_art.gd")
var building_art=BuildingArt.new()
const Professions=preload("res://src/entities/professions.gd")
var sim
var people: Array=[]
var tiles: Dictionary={}
var characters: Array=[]
var animated: Dictionary={}
var cavalry: Dictionary={}
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
var show_routes: bool=false
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var names=sim.Catalog.DATA.keys()+["grass","grass_1","grass_2","grass_3","tree","water","road","plaza"]
 for kind in names:tiles[kind]=load(BuildingArt.DIRECTORY+kind+".png" if kind in sim.Catalog.DATA else "res://assets/tilesets/visual_v021/"+kind+".png")
 for i in range(24):characters.append(load("res://assets/characters/native/"+str(i)+".png"))
 for kind in ["tree"]:animated[kind]=load("res://assets/buildings/visual_v021/"+kind+"_animation.png")
 horse=load("res://assets/horses/horse_native_v021.png")
 for family in ["coat","cloth","armor","banner","rider_armor"]:
  cavalry[family]=[]
  for n in range(5 if family=="coat" else (1 if family in ["armor","rider_armor"] else 6)):cavalry[family].append(load("res://assets/horses/cavalry/"+family+"_"+str(n)+".png"))
 ground=Ground.new();ground.sim=sim;ground.tiles=tiles;ground.show_behind_parent=true;add_child(ground)
 refresh()
func refresh() -> void:
 people=sim.people;static_objects.clear();water_cells.clear()
 for cell in sim.terrain:
  if sim.terrain[cell]=="tree":static_objects.append({"y":Iso.project(Vector2(cell)).y,"type":0,"cell":cell,"order":cell.x*32+cell.y})
  elif sim.terrain[cell]=="water":water_cells.append(cell)
 for i in range(sim.buildings.size()):
  var b=sim.buildings[i];static_objects.append({"y":Iso.project(Vector2(b.x,b.y)).y,"type":1,"index":i,"order":i})
 static_objects.sort_custom(Policy.before)
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
func draw_tile(kind: String,cell: Vector2i,tint: Color=Color.WHITE,live: bool=true) -> void:
 var point=Iso.project(Vector2(cell))
 if not visible_point(point):return
 if kind in building_art.data:
  draw_texture_rect_region(building_art.textures[kind],Rect2(point-Iso.TILE_ORIGIN,Vector2(64,64)),Rect2(building_frame(kind,cell,live)*64,0,64,64),tint,false,false)
 elif kind in animated:
  draw_texture_rect_region(animated[kind],Rect2(point-Iso.TILE_ORIGIN,Vector2(64,64)),Rect2(int(phase*2)%4*64,0,64,64),tint)
 else:draw_texture(tiles[kind],point-Iso.TILE_ORIGIN,tint)
func building_frame(kind: String,cell: Vector2i,live: bool=true) -> int:
 var clock=phase+float((cell.x*17+cell.y*31)%23)*0.13 if live else 0.0
 return building_art.frame_index(kind,clock)
func person_point(c) -> Vector2:
 var alpha=clampf(sim.elapsed/sim.STEP,0,1) if animate else 1.0
 var point=Iso.project(c.previous.lerp(c.position,alpha))
 var transform=get_viewport().get_canvas_transform()
 return transform.affine_inverse()*(transform*point).round()
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
 var actors: Array=[]
 for i in range(people.size()):
  var point=person_point(people[i]);actors.append({"y":point.y,"type":2,"i":i,"point":point,"order":i})
 actors.sort_custom(Policy.before)
 var objects: Array=[];var fixed=0;var actor_index=0
 while fixed<static_objects.size() or actor_index<actors.size():
  if actor_index>=actors.size() or (fixed<static_objects.size() and Policy.before(static_objects[fixed],actors[actor_index])):
   objects.append(static_objects[fixed]);fixed+=1
  else:objects.append(actors[actor_index]);actor_index+=1
 # All shadows and ground rings precede objects, so a hidden unit cannot paint over a wall.
 for object in objects:
  if object.type==2 and visible_point(object.point):
   draw_ellipse_shadow(object.point)
   if selected_person==object.i:draw_arc(object.point+Vector2(0,1),10,0,TAU,20,Color("e3c77e"),1)
 if selected_building>=0 and selected_building<sim.buildings.size():
  var selected=sim.buildings[selected_building];diamond(Vector2i(selected.x,selected.y),Color("e5c582"),1.5)
 if show_routes:draw_routes()
 if sim.valid(hovered):diamond(hovered,Color("e7ca88") if build_kind.is_empty() or sim.can_build(build_kind,hovered) else Color("d57d69"),1.5)
 for obj in objects:
  if obj.type==0:
   draw_tile("tree",obj.cell)
  elif obj.type==1:
   var b=sim.buildings[obj.index];var cell=Vector2i(int(b.x),int(b.y));var p=Iso.project(Vector2(cell))
   if not visible_point(p):continue
   draw_tile(b.kind,cell,Color(1,1,1,0.52) if b.remaining>0 else Color.WHITE,b.remaining<=0)
   if b.remaining>0:
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38,3)),Color("252c32"))
    draw_rect(Rect2(p+Vector2(-19,-42),Vector2(38*(1-b.remaining/float(sim.Catalog.DATA[b.kind].time)),3)),Color("ddbb72"))
   else:
    if b.kind in ["house","bakery","tavern"] and not building_art.has_native_smoke(b.kind):FX.smoke(self,p+Vector2(2,-26),phase+obj.index)
    if b.kind=="forge":FX.smoke(self,p+Vector2(-1,-20),phase+obj.index)
    if b.kind=="forge":FX.fire(self,p+Vector2(-1,3),phase)
    if b.kind in ["tavern","chapel"] and (sim.hour()>18 or sim.hour()<7):
     draw_rect(Rect2(p+Vector2(5,-6),Vector2(3,4)),Color("e2b264"))
  else:
   var c=people[obj.i];var p=obj.point
   if not visible_point(p):continue
   var moving=not c.route.is_empty();var working=c.task in ["work","build","collect"] and not moving
   var row=1 if moving else (2 if working and c.kind==c.portrait_id else 0)
   var frame=int(c.clock*(7 if c.mounted else (8 if moving else 5)))%(8 if moving or working else 5)
   if c.mounted or c.horse_only:
    draw_mount(c,p,moving)
   if not c.horse_only:
    if c.mounted:
     var rate=[7,10,14][c.equipment.gait] if moving else 7
     var bob=([0,0,-1,-1,0,0,1,1] if moving else [0,0,0,-1,-1,0,0,0])[int(c.clock*rate)%8]
     frame=int(c.clock*rate)%(8 if moving else 5)
     draw_texture_rect_region(characters[c.portrait_id],Rect2(p-Vector2(13,45-round(bob)),Vector2(30,25)),Rect2(frame*30,35 if moving else 0,30,25))
     draw_line(p+Vector2(5,-18+bob),p+Vector2(10,-12+bob),Color("535e75"),3);draw_line(p+Vector2(10,-12+bob),p+Vector2(8,-4+bob),Color("302d32"),3)
    else:draw_texture_rect_region(characters[c.portrait_id],Rect2(p-Policy.CHARACTER_PIVOT,Policy.CHARACTER_FRAME),Rect2(frame*30,row*35,30,35))
    if c.mounted and c.equipment.armor:draw_mount_layer(cavalry.rider_armor[0],c,p,moving)
    if c.mounted and c.equipment.banner:draw_mount_layer(cavalry.banner[c.equipment.color],c,p,moving)
    if working:
     FX.work_effect(self,p,phase,Professions.DATA[c.kind].tool)
     if c.kind!=c.portrait_id:FX.held_tool(self,p,phase,Professions.DATA[c.kind].tool)
    if not c.cargo.is_empty():FX.cargo(self,p,c.cargo)
    if c.task=="sleep":
     draw_rect(Rect2(p+Vector2(5,-32),Vector2(3,1)),Color("b7c3d0"))
     draw_rect(Rect2(p+Vector2(7,-35),Vector2(2,1)),Color("b7c3d0"))
 if sim.valid(hovered):
  if not build_kind.is_empty():draw_tile(build_kind,hovered,Color(1,1,1,0.55),false)
# Shift overlay: the selected villager's path, a building's staff links, or every cargo route.
func draw_routes() -> void:
 if selected_person>=0 and selected_person<people.size():
  draw_route(people[selected_person],Color("e3c77e"))
 elif selected_building>=0 and selected_building<sim.buildings.size():
  var b=sim.buildings[selected_building];var anchor=Iso.project(Vector2(b.x,b.y))
  for c in people:
   if c.employer!=selected_building:continue
   draw_dashed_line(anchor,person_point(c),Color(0.65,0.73,0.53,0.8),1.0,3.0)
   draw_route(c,Color("a6bb87"))
 else:
  for c in people:
   if not c.cargo.is_empty():draw_route(c,Color("8fb4c9"))
func draw_route(c,colour: Color) -> void:
 if c.route.is_empty():return
 var from=person_point(c)
 for cell in c.route:
  var to=Iso.project(Vector2(cell));draw_dashed_line(from,to,colour,1.0,4.0);from=to
 diamond(c.route.back(),colour,1)
func draw_ellipse_shadow(p: Vector2) -> void:
 draw_colored_polygon(PackedVector2Array([p+Vector2(-7,0),p+Vector2(-3,-2),p+Vector2(5,-2),p+Vector2(8,0),p+Vector2(4,2),p+Vector2(-4,2)]),Color(0.07,0.13,0.13,0.23))

func draw_mount_layer(texture: Texture2D,c,p: Vector2,moving: bool) -> void:
 var rate=[7,10,14][c.equipment.gait] if moving else 7
 draw_texture_rect_region(texture,Rect2(p-Policy.HORSE_PIVOT,Policy.HORSE_FRAME),Rect2(int(c.clock*rate)%8*48,48 if moving else 0,48,48))
func draw_mount(c,p: Vector2,moving: bool) -> void:
 draw_mount_layer(cavalry.coat[c.equipment.coat],c,p,moving)
 if c.mounted:
  draw_mount_layer(cavalry.cloth[c.equipment.color],c,p,moving)
  if c.equipment.armor:draw_mount_layer(cavalry.armor[0],c,p,moving)
 elif c.equipment.banner:draw_mount_layer(cavalry.banner[c.equipment.color],c,p,moving)
