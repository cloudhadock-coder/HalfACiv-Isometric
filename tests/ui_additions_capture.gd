extends SceneTree
# Captures the Civ2-UI-Additions-inspired HUD features at 1280x720 into docs/visual-validation/ui-additions/.
const FOLDER="res://docs/visual-validation/ui-additions/"
var game
var failures: int=0
func check(ok: bool,message: String) -> void:
 if not ok:failures+=1;push_error("FAIL: "+message)
func _init() -> void:call_deferred("run")
func shot(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var image=root.get_texture().get_image()
 check(not image.is_empty(),"real GPU viewport "+name)
 if "--no-save" not in OS.get_cmdline_user_args():check(image.save_png(FOLDER+name+".png")==OK,"capture "+name)
func key(code: int,down: bool) -> void:
 var e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;Input.parse_input_event(e)
func run() -> void:
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 root.size=Vector2i(1280,720)
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 game.autosave_clock=-100000;game.paused=false;game.hud.menu.hide();game.set_speed(4)
 game.sim.tick(18);game.hud.notify("Domínio carregado · Offline: 0s");game.hud.notify("Obra iniciada")
 await create_timer(3.0).timeout
 game.set_speed(1)
 check(game.hud.resources.text.contains("/h"),"resource trends visible")
 await shot("Overview_Trends_Messages")
 game.hud.toggle_roster();game.hud.registry_tab=1;game.hud.citizen_sort=["state",false];game.hud.refresh_registry()
 await shot("Registry_Villagers")
 game.hud.registry_tab=2;game.hud.building_sort=["status",false];game.hud.refresh_registry()
 await shot("Registry_Buildings")
 game.hud.registry_tab=0;game.hud.refresh_registry()
 await shot("Registry_Portraits")
 game.hud.roster_panel.hide()
 # Shift with no selection: every cargo route.
 game.selected=-1;game.world.selected_person=-1;game.selected_building=-1;game.world.selected_building=-1
 key(KEY_SHIFT,true);await shot("Routes_Cargo");check(game.world.show_routes,"shift enables routes")
 var walker=-1
 for i in range(game.people.size()):
  if game.people[i].route.size()>=4 and not game.people[i].horse_only:walker=i;break
 if walker>=0:
  game.select_person(walker);game.focus_selection()
  var screen=game.get_viewport().get_canvas_transform()*(game.world.person_point(game.people[walker])-Vector2(0,16))
  Input.warp_mouse(screen);await process_frame
  key(KEY_CTRL,true);await shot("Routes_Selected_QuickInfo")
  check(game.hud.quick.visible,"ctrl quick info visible over villager")
  key(KEY_CTRL,false)
 key(KEY_SHIFT,false)
 print("UI_ADDITIONS_CAPTURE failures=",failures)
 game.queue_free();quit(0 if failures==0 else 1)
