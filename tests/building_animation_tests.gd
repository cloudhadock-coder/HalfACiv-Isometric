extends SceneTree
const Art=preload("res://src/rendering/building_art.gd")
const Iso=preload("res://src/world/iso.gd")
const FOLDER="res://docs/visual-validation/v0.4.2/"
var checks: int=0
var failures: int=0
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(text)
func _init() -> void:call_deferred("run")
func shot(name: String) -> Image:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var image=root.get_texture().get_image()
 if "--no-save" not in OS.get_cmdline_user_args():image.save_png(FOLDER+name+".png")
 return image
func run() -> void:
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 var art=Art.new()
 for kind in art.data:
  var data=art.data[kind];var count=int(data.count);var fps=float(data.fps)
  check(art.textures[kind].get_size()==Vector2(count*64,64),kind+" native atlas dimensions")
  if fps>0:
   for i in range(count):check(art.frame_index(kind,(float(i)+0.01)/fps)==i,kind+" explicit frame "+str(i))
   check(art.frame_index(kind,float(count)/fps)==0,kind+" seamless modulo wrap")
  else:check(art.frame_index(kind,12345)==0,kind+" static sprite")
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame
 game.paused=true;game.autosave_clock=-100000;game.hud.menu.hide();game.world.animate=false
 game.sim.seconds=40;game.hud.update_resources(game.sim)
 var village=await shot("Village")
 game.hud.toggle_build();game.hud.toggle_details();game.camera_rig.configure(game.get_viewport_rect().size,game.hud.useful_map_rect())
 game.sim.people=[];game.people=[];game.world.people=[];game.sim.buildings=[]
 for cell in game.sim.terrain:game.sim.terrain[cell]="grass"
 var index=0
 for kind in game.sim.Catalog.DATA:
  var cell=Vector2i(9+index%6*3,8+int(index/6)*4);game.sim.buildings.append(game.sim.Catalog.make(kind,cell));index+=1
 game.world.refresh();game.hud.update_resources(game.sim);game.camera_rig.move_to(Iso.project(Vector2(16,12)));game.camera_rig.set_step(1.5)
 await create_timer(0.25).timeout
 game.world.phase=0;var first=await shot("Buildings_Frame_A")
 check(first.get_pixel(500,16)==village.get_pixel(500,16),"atlas rendering preserves top menu pixels")
 game.world.phase=0.375;var second=await shot("Buildings_Frame_B")
 check(first.get_data()!=second.get_data(),"real viewport changes with native animation time")
 for kind in art.data:
  check(game.world.building_frame(kind,Vector2i(7,14),false)==0,kind+" construction/ghost frame stays at zero")
 var held=game.world.phase;await create_timer(0.3).timeout
 check(game.world.phase==held,"paused animation clock is stable")
 var third=await shot("Buildings_Paused");check(third.get_data()==second.get_data(),"paused rendered pixels are unchanged")
 var row=game.sim.buildings.filter(func(b):return b.kind=="chapel")[0]
 var point=Iso.project(Vector2(row.x,row.y));game.camera_rig.move_to(point);game.camera_rig.set_step(4)
 await shot("Chapel_Closeup")
 root.size=Vector2i(1920,1080);await shot("Buildings_1080p")
 check(game.world.tiles.chapel.get_image().get_data()==load(Art.DIRECTORY+"chapel.png").get_image().get_data(),"map uses supplied church crop")
 game.queue_free();await process_frame
 print("BUILDING_ANIMATION_RESULT checks=",checks," failures=",failures);quit(1 if failures else 0)
