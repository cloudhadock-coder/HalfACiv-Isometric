extends SceneTree
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
var failures: int=0
var assertions: int=0
func check(value: bool,label: String) -> void:
 assertions+=1
 if not value:failures+=1;push_error(label)
func _init() -> void:call_deferred("run")
func run() -> void:
 Store.PATH="res://tests/integration-save.json"
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 check(game.paused and game.hud.menu.visible,"initial menu")
 game.hud.pause_requested.emit();check(not game.paused,"continue")
 var before=game.sim.resources.food
 await create_timer(1.2).timeout
 check(game.sim.tick_count>=1 and game.sim.resources.food!=before,"economy ticks while playing")
 var zoom=game.camera.zoom.x
 var wheel=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.pressed=true;game._unhandled_input(wheel)
 check(game.camera.zoom.x>zoom,"camera zoom")
 # The actual category and build button, then a real viewport mouse position.
 game.hud.category="Oficinas";game.hud.populate_builds()
 await process_frame
 var forge_button
 for child in game.hud.build_list.get_children():
  if not child.is_queued_for_deletion() and child.text.begins_with("Forja"):forge_button=child
 check(forge_button!=null,"new forge button exists")
 forge_button.pressed.emit();check(game.world.build_kind=="forge","build button selects new kind")
 var cell=Vector2i(19,17);var screen=game.get_viewport().get_canvas_transform()*Iso.project(Vector2(cell))
 Input.warp_mouse(screen);await process_frame
 var count=game.sim.buildings.size();var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=screen;game._unhandled_input(click)
 check(game.sim.buildings.size()==count+1 and game.sim.buildings.back().kind=="forge","mouse builds forge")
 game.hud.build_selected.emit("")
 # Gallery button selects a real villager and sets the corresponding portrait.
 game.hud.toggle_roster();await process_frame
 check(game.hud.roster_grid.get_child_count()==24,"24 portraits in roster")
 game.hud.roster_grid.get_child(16).get_child(0).pressed.emit()
 check(game.selected==16 and game.hud.portrait.texture!=null and not game.hud.roster_panel.visible,"roster selection")
 game.hud.profession.select(17);game.hud.profession.item_selected.emit(17)
 check(game.sim.people[16].kind==17 and game.sim.people[16].portrait_id==16,"profession dropdown preserves face")
 game.hud.speed_buttons[2].pressed.emit();check(game.speed==2,"speed button")
 game.hud.save_requested.emit();check(FileAccess.file_exists(Store.PATH),"save button")
 var saved=game.sim.resources.wood;game.sim.resources.wood=0
 game.hud.load_requested.emit();check(game.sim.resources.wood>=saved,"load inventory")
 check(game.sim.people[16].kind==17,"load preserves profession and order")
 game.toggle_pause();check(game.paused,"pause menu")
 var seconds=game.sim.seconds;var phase=game.world.phase
 await create_timer(1.1).timeout
 check(game.sim.seconds==seconds and game.world.phase==phase,"pause stops simulation and ambient animations")
 game.toggle_pause();game.sim.tick(5)
 game.select_person(2);check(game.hud.selection_kind=="person","NPC inspector")
 game.selected_building=game.sim.nearest_kind(["forge"],Vector2.ZERO);game.hud.show_building(game.sim.buildings[game.selected_building],game.selected_building)
 check(game.hud.details.text.contains("Insumos") and game.hud.details.text.contains("Postos"),"building inspector staffing and inputs")
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(Store.PATH+suffix)
 print("INTEGRATION_RESULT assertions=",assertions," failures=",failures)
 game.queue_free();quit(0 if failures==0 else 1)
