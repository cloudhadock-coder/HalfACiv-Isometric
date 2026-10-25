extends SceneTree
# Captures the main menu, the world setup page and seeded villages under the classic-4X layout
# into docs/visual-validation/interface/, at 1280x720, 1920x1080 and 960x540.
const FOLDER="res://docs/visual-validation/interface/"
const Store=preload("res://src/persistence/save_store.gd")
var game
var failures: int=0
func check(ok: bool,message: String) -> void:
 if not ok:failures+=1;push_error("FAIL: "+message)
func _init() -> void:call_deferred("run")
func shot(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(FOLDER+name+".png")==OK,"capture "+name)
func fits(control: Control,label: String) -> void:
 var s=game.hud.scale.x;var view=root.get_visible_rect().size
 var r=Rect2(control.position*s,control.size*s)
 check(r.position.x>=-1 and r.position.y>=-1 and r.end.x<=view.x+1 and r.end.y<=view.y+1,label+" fits the window "+str(r)+" in "+str(view))
func run() -> void:
 Store.PATH="user://interface-capture.json"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 root.size=Vector2i(1280,720)
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 game.autosave_clock=-100000
 check(game.paused and game.hud.menu.visible,"starts on the main menu")
 await shot("Menu_Start")
 game.hud.menu.show_setup();game.hud.menu.seed_edit.text="2026";game.hud.menu.refresh_preview()
 check(game.hud.menu.preview.terrain.size()==1024,"setup preview shows a generated world")
 await shot("Menu_World_Setup")
 var settings=game.hud.menu.settings()
 game.hud.menu.world_requested.emit(settings)
 check(not game.paused and not game.hud.menu.visible and game.sim.world.seed==2026,"setup starts the seeded world")
 game.set_speed(4);await create_timer(2.5).timeout;game.set_speed(1)
 game.paused=true;game.world.animate=false
 for p in [game.hud.menu_bar,game.hud.minimap_panel,game.hud.status_panel,game.hud.detail_panel,game.hud.build_panel]:fits(p,"720p panel")
 check(game.hud.scale.x==1.0,"1x HUD at 720p")
 var crisp=func():return absf(fmod(game.hud.scale.x*root.get_final_transform().get_scale().x+0.0005,1.0))<0.002
 await shot("Village_720p")
 game.select_person(9);await shot("Village_Selected_720p")
 game.hud.run("help");await shot("Help_720p");game.hud.help_panel.hide()
 game.paused=false;game.toggle_pause();check(game.hud.menu.visible and game.hud.menu.mode=="pause","Esc opens the pause menu")
 await shot("Menu_Pause")
 game.toggle_pause()
 for size in [Vector2i(1920,1080),Vector2i(960,540)]:
  root.size=size;await process_frame;await process_frame
  game.paused=true
  for p in [game.hud.menu_bar,game.hud.minimap_panel,game.hud.status_panel,game.hud.detail_panel,game.hud.build_panel]:fits(p,"%dx%d panel"%[size.x,size.y])
  if size.x>=1280:check(crisp.call(),"HUD lands on whole screen pixels at %dx%d"%[size.x,size.y])
  await shot("Village_%dx%d"%[size.x,size.y])
 root.size=Vector2i(1280,720)
 for name in ["rio","costa","lagos"]:
  game.new_game({"seed":31337,"landscape":name});game.paused=true;game.world.animate=false
  await shot("World_%s"%name)
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(Store.PATH+suffix)
 print("INTERFACE_CAPTURE failures=",failures)
 game.queue_free();quit(0 if failures==0 else 1)
