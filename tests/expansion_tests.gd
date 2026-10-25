extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Gen=preload("res://src/world/world_gen.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
const Bounds=preload("res://src/rendering/camera_bounds.gd")
const FOLDER="res://docs/visual-validation/v0.5.0/"
var checks: int=0
var failures: int=0
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(text)
func _init() -> void:call_deferred("run")
func shot(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 if "--no-save" not in OS.get_cmdline_user_args():root.get_texture().get_image().save_png(FOLDER+name+".png")
func free_cell(sim) -> Vector2i:
 for r in range(1,8):
  for x in range(-r,r+1):
   for y in range(-r,r+1):
    var cell=sim.centre()+Vector2i(x,y)
    if sim.valid(cell) and sim.terrain[cell] in ["grass","dirt","stone","sand"] and not sim.blocked(cell) and not sim.nav.path(sim.village_anchor(),cell).is_empty():return cell
 return Vector2i(-1,-1)
func write(data) -> void:
 var f=FileAccess.open(Store.PATH,FileAccess.WRITE);f.store_string(JSON.stringify(data));f.close()
func run() -> void:
 Store.PATH="res://tests/expansion-save.json";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 for side in [32,48,64]:
  for seed in [1,17,31337]:
   var settings=Gen.normalize({"size":side,"seed":seed});var a=Gen.generate(settings);var b=Gen.generate(settings)
   check(a.terrain.size()==side*side and a.terrain==b.terrain and a.buildings==b.buildings,"deterministic size/seed")
   var sim=Sim.new(settings)
   for c in sim.people:check(not sim.blocked(Vector2i(c.position)),"spawn accessible in large world")
   check(sim.nav.grid.region.size==Vector2i(side,side),"navigation region dimensions")
   check(sim.centre()==Vector2i.ONE*(side/2-1),"translated plaza centre")
   if side>32:
    var core=Rect2i(Vector2i.ONE*((side-32)/2),Vector2i(32,32));var seen={sim.centre():true};var queue=[sim.centre()];var exterior=false
    while not queue.is_empty() and not exterior:
     var current=queue.pop_back()
     if not core.has_point(current):exterior=true;break
     for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
      var next=current+delta
      if sim.valid(next) and not seen.has(next) and not sim.blocked(next):seen[next]=true;queue.append(next)
    check(exterior,"new territory is reachable from village")
 check(not Gen.valid({"seed":1,"name":"bad","bounty":"normal","landscape":"rio","size":65}),"invalid world size rejected")
 for side in [48,64]:
  for zoom in [1.0,1.5,2.0,3.0,4.0]:
   var polygon=Bounds.polygon(Vector2(900,600),zoom,side)
   for extreme in [Vector2(0,-10000),Vector2(0,10000),Vector2(-10000,500),Vector2(10000,500)]:
    var focus=Iso.unproject(Bounds.constrain_region(extreme,polygon,side))
    check(focus.x>=-0.51 and focus.y>=-0.51 and focus.x<=side-0.49 and focus.y<=side-0.49,"all zoom levels clamp to large diamond")
 var poor=Sim.new();var unchanged=poor.terrain
 check(not poor.expand() and poor.terrain==unchanged and poor.resources.gold==90,"unaffordable expansion is atomic")
 # Expand an established classic domain twice and preserve roads, economy and political identity.
 var sim=Sim.new();var p=sim.politics;sim.resources.gold=500;sim.resources.influence=100
 p.stage=2;p.legitimacy=70.0;p.support.guilds=65.0;p.reforms.append("weights")
 var cell=free_cell(sim);var before=sim.resources.stone;var builds=sim.nav.rebuild_count;var at=sim.people[0].position
 check(sim.edit_road(cell) and sim.resources.stone==before-1 and sim.terrain[cell]=="road","road cost and placement")
 check(sim.people[0].position==at and sim.nav.rebuild_count==builds and sim.nav.incremental_count>0,"incremental navigation and no NPC teleport")
 check(not sim.edit_road(cell) and sim.resources.stone==before-1,"duplicate road no charge")
 var old=sim.terrain.duplicate();var house=Vector2i(sim.buildings[0].x,sim.buildings[0].y)
 check(not sim.edit_road(house),"cannot pave through building")
 check(sim.expand() and sim.map_size()==48 and sim.politics==p,"expand existing classic domain")
 for key in old:check(sim.terrain[key+Vector2i(8,8)]==old[key],"old land preserved after expansion")
 check(sim.people[0].position==at+Vector2(8,8) and sim.resources.gold==350 and sim.resources.influence==75,"expansion translation and exact cost")
 check(Store.save_game(sim)==OK,"save expanded classic")
 var loaded=Sim.new();check(not Store.load_game(loaded).is_empty() and loaded.map_size()==48 and loaded.terrain==sim.terrain,"load expanded classic and edits")
 check(loaded.politics.snapshot()==sim.politics.snapshot(),"expansion/save preserves established politics and reforms")
 check(loaded.terrain[cell+Vector2i(8,8)]=="road","road edit survives expansion/load")
 check(loaded.expand() and loaded.map_size()==64,"second expansion to maximum")
 Store.save_game(loaded);var restored=Sim.new();check(not Store.load_game(restored).is_empty() and restored.terrain==loaded.terrain,"64x64 expanded classic roundtrip")
 check(not restored.expand(),"maximum size prevents expansion")
 var remove=cell+Vector2i(16,16);var stone=restored.resources.stone
 check(restored.edit_road(remove,true) and restored.terrain[remove]=="dirt" and restored.resources.stone==stone,"road removal without refund")
 Store.save_game(restored);var doc=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH))
 doc.terrain_edits.append({"x":999,"y":0,"kind":"road"});write(doc);var identity=loaded.people[0]
 check(Store.load_game(loaded).is_empty() and loaded.people[0]==identity,"invalid edits rejected atomically")
 var seeded=Sim.new(Gen.normalize({"seed":17,"size":48}));seeded.resources.gold=300;seeded.resources.influence=50
 var old_seed=seeded.terrain.duplicate();check(seeded.expand(),"expand seeded 48 to64")
 for key in old_seed:check(seeded.terrain[key+Vector2i(8,8)]==old_seed[key],"seeded old territory preserved")
 Store.save_game(seeded);check(not Store.load_game(restored).is_empty() and restored.terrain==seeded.terrain,"seeded large roundtrip")
 # Road weights influence route selection and cached arrays cannot be mutated by a citizen.
 var nav=Sim.new();nav.buildings=[]
 for key in nav.terrain:nav.terrain[key]="grass"
 for x in range(5,26):nav.terrain[Vector2i(x,8)]="road"
 nav.nav.rebuild(nav)
 var route=nav.nav.path(Vector2i(5,9),Vector2i(25,9));check(route.any(func(c):return c.y==8),"AStar prefers faster road detour")
 var size=route.size();route.pop_front();check(nav.nav.path(Vector2i(5,9),Vector2i(25,9)).size()==size,"path cache returns independent arrays")
 nav.terrain[Vector2i(10,8)]="tree";nav.nav.change_cell(nav,Vector2i(10,8))
 check(Vector2i(10,8) not in nav.nav.path(Vector2i(5,9),Vector2i(15,9)),"incremental obstacle invalidates paths")
 check(nav.nav.speed_factor(Vector2i(5,8))>nav.nav.speed_factor(Vector2i(5,9)),"road affects actual movement factor")
 var legacy=Sim.new();Store.save_game(legacy);var old_doc=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH))
 old_doc.schema=1;old_doc.buildings[0].x=5;old_doc.buildings[0].y=14;write(old_doc)
 check(not Store.load_game(legacy).is_empty() and legacy.terrain_edits.get(Vector2i(5,14))=="grass","legacy cleared building tile is persisted")
 Store.save_game(legacy);check(not Store.load_game(Sim.new()).is_empty(),"legacy to current re-save remains loadable")
 # Real GUI and input; camera/minimap/tiles cover the larger map.
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame
 game.new_game({"seed":17,"size":64});game.paused=true;game.hud.menu.hide();game.autosave_clock=-100000
 check(game.camera_rig.world_size==64 and game.hud.minimap.map_size==64,"camera and minimap use dynamic size")
 await shot("World_64")
 var map_target=Iso.project(Vector2(42,42));var mini=game.hud.minimap
 check(mini.from_map(mini.to_map(map_target)).distance_to(map_target)<0.01,"large minimap coordinate roundtrip")
 var tap=InputEventMouseButton.new();tap.button_index=MOUSE_BUTTON_LEFT;tap.pressed=true;tap.position=mini.get_global_transform_with_canvas()*mini.to_map(map_target)
 Input.warp_mouse(tap.position);await process_frame;Input.parse_input_event(tap)
 var up=tap.duplicate();up.pressed=false;Input.parse_input_event(up);await process_frame
 check(game.camera_rig.focus.distance_to(map_target)<1.1,"actual minimap click navigates 64x64 world")
 var visible=0
 for chunk in game.world.ground.chunks:
  if chunk.visible:visible+=1
 check(visible>0 and visible<game.world.ground.chunks.size(),"terrain chunks culled outside camera")
 for target in [Vector2(0,-10000),Vector2(0,10000),Vector2(10000,1000),Vector2(-10000,1000)]:
  game.camera_rig.move_to(target);var grid=Iso.unproject(game.camera_rig.focus)
  check(grid.x>=-0.51 and grid.y>=-0.51 and grid.x<=63.51 and grid.y<=63.51,"64x64 diamond camera limit")
 game.camera_rig.move_to(Iso.project(Vector2(game.sim.centre())))
 for kind in ["dirt","sand","stone"]:
  var soil=Vector2i(-1,-1)
  for tile in game.sim.terrain:
   if game.sim.terrain[tile]==kind:soil=tile;break
  check(soil.x>=0,"new terrain generated: "+kind)
  if soil.x>=0:
   game.camera_rig.move_to(Iso.project(Vector2(soil)));await shot("Terrain_"+kind)
 game.camera_rig.move_to(Iso.project(Vector2(game.sim.centre())))
 game.camera_rig.set_step(3);var chosen=free_cell(game.sim);var screen=game.get_viewport().get_canvas_transform()*Iso.project(Vector2(chosen))
 check(game.hud.useful_map_rect().has_point(screen),"road target inside map viewport")
 game.paused=false;game.run_command("roads");Input.warp_mouse(screen);await process_frame
 var press=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=screen;Input.parse_input_event(press)
 var release=press.duplicate();release.pressed=false;Input.parse_input_event(release);await process_frame
 check(game.sim.terrain[chosen]=="road","actual mouse road construction")
 await shot("Road_Editing")
 game.run_command("erase_road");Input.parse_input_event(press);Input.parse_input_event(release);await process_frame
 check(game.sim.terrain[chosen]=="dirt","actual mouse road removal")
 game.paused=true
 game.new_game();game.paused=true;game.hud.menu.hide();game.sim.resources.gold=500;game.sim.resources.influence=100
 var screen_before=game.camera_rig.world_to_screen(Iso.project(Vector2(game.sim.centre())))
 game.run_command("expand")
 check(game.sim.map_size()==48 and game.camera_rig.world_size==48 and game.camera_rig.world_to_screen(Iso.project(Vector2(game.sim.centre()))).distance_to(screen_before)<1.1,"UI expansion keeps village under same screen point")
 await shot("Expanded_Existing_Realm")
 root.size=Vector2i(960,540);await shot("UI_960x540")
 game.run_command("new_world");await process_frame;check(game.hud.menu.map_size.item_count==3 and game.hud.menu.visible and game.paused and game.road_tool.is_empty(),"world setup opens over terrain tool")
 await shot("World_Setup")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp",".v0.1.bak"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(Store.PATH+suffix))
 print("EXPANSION_RESULT checks=",checks," failures=",failures);quit(1 if failures else 0)
