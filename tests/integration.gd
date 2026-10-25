extends SceneTree
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
var failures: int=0
func check(value: bool,label: String) -> void:
 if not value:failures+=1;push_error(label)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 Store.PATH="res://tests/integration-save.json"
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 check(game.paused,"initial menu")
 game.hud.pause_requested.emit();check(not game.paused,"menu continue")
 var before=game.sim.resources.food
 await create_timer(1.2).timeout
 check(game.sim.resources.food>before,"economy while playing")
 var zoom=game.camera.zoom.x
 var wheel=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.pressed=true;game._unhandled_input(wheel)
 check(game.camera.zoom.x>zoom,"camera zoom input")
 game.hud.build_selected.emit("farm")
 check(game.world.build_kind=="farm","build button signal")
 # Position a real mouse event over a free tile in the visible map.
 var cell=Vector2i(18,16)
 var screen=game.get_viewport().get_canvas_transform()*Iso.project(Vector2(cell))
 Input.warp_mouse(screen)
 await process_frame
 var count=game.sim.buildings.size()
 var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=screen
 game._unhandled_input(click)
 check(game.sim.buildings.size()==count+1,"mouse placement")
 game.hud.save_requested.emit();check(FileAccess.file_exists(Store.PATH),"save button")
 var saved=game.sim.resources.wood;game.sim.resources.wood=0
 game.hud.load_requested.emit();check(game.sim.resources.wood>=saved,"load button roundtrip")
 game.hud.build_selected.emit("");game.toggle_pause();check(game.paused,"pause")
 var ticks=game.sim.tick_count
 await create_timer(1.1).timeout
 check(game.sim.tick_count==ticks,"pause stops economy")
 game.hud.show_person(game.people[7]);check(game.hud.portrait.texture!=null,"portrait selection")
 DirAccess.remove_absolute(Store.PATH)
 print("INTEGRATION_RESULT failures=",failures)
 game.queue_free();quit(0 if failures==0 else 1)
