extends SceneTree
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
const PortraitView=preload("res://src/ui/portrait_view.gd")
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
 var wheel=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.pressed=true;wheel.position=game.camera_rig.useful.get_center();game._unhandled_input(wheel)
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
 check(game.camera_rig.useful.has_point(screen),"forge click lies inside real map viewport")
 Input.warp_mouse(screen);await process_frame
 var count=game.sim.buildings.size();var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=screen
 Input.parse_input_event(click)
 var release=click.duplicate();release.pressed=false;Input.parse_input_event(release)
 await process_frame
 check(game.sim.buildings.size()==count+1 and game.sim.buildings.back().kind=="forge","mouse builds forge through actual input dispatch")
 game.hud.category="Moradia";game.hud.populate_builds();await process_frame
 for button in game.hud.build_list.get_children():
  if not button.is_queued_for_deletion() and button.text.begins_with("Casa"):button.pressed.emit()
 cell=Vector2i(14,13);screen=game.get_viewport().get_canvas_transform()*Iso.project(Vector2(cell))
 check(game.camera_rig.useful.has_point(screen),"house click lies inside real map viewport")
 Input.warp_mouse(screen);await process_frame;count=game.sim.buildings.size()
 click.position=screen;Input.parse_input_event(click);release.position=screen;Input.parse_input_event(release)
 await process_frame
 check(game.sim.buildings.size()==count+1 and game.sim.buildings.back().kind=="house","mouse builds house through actual input dispatch")
 game.hud.build_selected.emit("")
 # Release over a consuming UI control must terminate a map drag.
 var middle=InputEventMouseButton.new();middle.button_index=MOUSE_BUTTON_MIDDLE;middle.pressed=true;middle.position=game.camera_rig.useful.get_center()
 Input.warp_mouse(middle.position);Input.parse_input_event(middle);await process_frame
 check(game.dragging,"real middle press starts drag")
 middle.pressed=false;middle.position=(game.hud.build_panel.position+Vector2(20,20))*game.hud.scale
 Input.warp_mouse(middle.position);Input.parse_input_event(middle);await process_frame
 check(not game.dragging,"release over GUI stops real drag")
 # Gallery button selects a real villager and sets the corresponding portrait.
 game.hud.toggle_roster();await process_frame
 check(game.hud.roster_grid.get_child_count()==24,"24 portraits in roster")
 game.hud.roster_grid.get_child(16).get_child(0).pressed.emit()
 check(game.selected==16 and game.hud.portrait.texture!=null and not game.hud.roster_panel.visible,"roster selection")
 # Portraits resolve through the manifest and are drawn only at whole-number nearest-neighbour scales.
 check(game.hud.portrait.texture==game.hud.registry.texture(16) and game.hud.portrait.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"portrait from manifest, nearest filter")
 check(game.hud.portrait.display_scale()==1 and game.hud.portrait_note.visible==not game.hud.registry.is_final(16),"legacy portrait native scale and pending note")
 var probe=PortraitView.new();probe.size=Vector2(130,130);probe.texture=ImageTexture.create_from_image(Image.create(64,64,false,Image.FORMAT_RGBA8))
 check(probe.display_scale()==2,"64x64 approved art shown at integer 2x");probe.size=Vector2(100,100);check(probe.display_scale()==1,"never fractional");probe.free()
 # Village registry: sortable villager/building tables, building selection and message history.
 game.hud.toggle_roster();await process_frame
 game.hud.registry_tab=1;game.hud.refresh_registry();await process_frame
 check(game.hud.ledger_list.get_child_count()==25 and not game.hud.roster_grid.visible,"villager table lists 24 rows plus header")
 game.hud.ledger_list.get_child(5).pressed.emit();await process_frame
 check(game.selected==4 and not game.hud.roster_panel.visible,"villager row selects that villager")
 game.hud.toggle_roster();game.hud.registry_tab=2;game.hud.refresh_registry();await process_frame
 check(game.hud.ledger_list.get_child_count()==game.sim.buildings.size()+1,"building table lists every building")
 var spot_b=Iso.project(Vector2(game.sim.buildings[2].x,game.sim.buildings[2].y));var gap=game.camera_rig.focus.distance_to(spot_b)
 game.hud.ledger_list.get_child(3).pressed.emit();await process_frame
 check(game.selected_building==2 and game.selected==-1 and game.hud.selection_kind=="building","building row selects that building")
 check(gap<1.0 or game.camera_rig.focus.distance_to(spot_b)<gap,"building row focuses camera")
 game.hud.notify("Mensagem de teste");check(game.hud.messages.latest()=="Mensagem de teste" and game.hud.messages.get_child_count()>=1,"notice shown over the map")
 game.hud.toggle_roster();game.hud.registry_tab=3;game.hud.refresh_registry();await process_frame
 check(game.hud.ledger_list.get_child(0).get_child(1).text=="Mensagem de teste","message history in registry")
 game.hud.toggle_roster();game.hud.registry_tab=0
 game.hud.quick_info(game.sim,4,-1,Vector2(400,300));check(game.hud.quick.visible and game.hud.quick.text.text.contains(game.sim.people[4].citizen_name),"Ctrl quick-info card")
 game.hud.quick_info(game.sim,-1,-1,Vector2(400,300));check(not game.hud.quick.visible,"quick-info hides over empty ground")
 # Middle click without drag centres the map; Ctrl+middle restores default zoom.
 game.camera_rig.set_step(4);var spot=game.camera_rig.useful.get_center()+Vector2(60,40);var target=game.camera_rig.screen_to_world(spot)
 var tap=InputEventMouseButton.new();tap.button_index=MOUSE_BUTTON_MIDDLE;tap.pressed=true;tap.position=spot
 Input.warp_mouse(spot);await process_frame;await process_frame;target=game.camera_rig.screen_to_world(spot);Input.parse_input_event(tap);await process_frame
 tap=tap.duplicate();tap.pressed=false;target=game.camera_rig.screen_to_world(spot);Input.parse_input_event(tap);await process_frame
 check(game.camera_rig.focus.distance_to(target)<1.0 and not game.dragging,"middle click centres the map")
 tap=tap.duplicate();tap.pressed=true;tap.ctrl_pressed=true;Input.parse_input_event(tap);await process_frame
 tap=tap.duplicate();tap.pressed=false;Input.parse_input_event(tap);await process_frame
 check(game.camera_rig.step==maxi(2,game.camera_rig.minimum_step),"ctrl+middle click restores default zoom")
 game.select_person(16)
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
