extends Node2D
const Sim=preload("res://src/economy/simulation.gd")
const World=preload("res://src/rendering/world_view.gd")
const HUD=preload("res://src/ui/hud.gd")
const CameraRig=preload("res://src/rendering/camera_controller.gd")
const Backdrop=preload("res://src/rendering/table_backdrop.gd")
const CompanyPanel=preload("res://src/ui/company_panel.gd")
var company_panel
var camera_rig
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
var sim=Sim.new()
var people: Array=[]
var world
var hud
var camera: Camera2D
var paused: bool=true
var dragging: bool=false
var drag_origin: Vector2
var selected: int=-1
var selected_building: int=-1
var autosave_clock: float=0
var hud_clock: float=0
var speed: float=1
var routes_pinned: bool=false
func _ready() -> void:
 people=sim.people
 add_child(Backdrop.new())
 world=World.new();world.sim=sim;world.people=people;add_child(world)
 camera=Camera2D.new();camera.position=Iso.project(Vector2(15.5,15.5));add_child(camera);world.camera=camera
 hud=HUD.new();add_child(hud)
 hud.build_selected.connect(func(kind):world.build_kind=kind)
 hud.pause_requested.connect(toggle_pause);hud.save_requested.connect(save_game);hud.load_requested.connect(load_game);hud.new_requested.connect(new_game)
 hud.speed_changed.connect(set_speed);hud.profession_changed.connect(change_profession);hud.citizen_selected.connect(func(index):select_person(index);focus_selection())
 hud.building_selected.connect(func(index):select_building(index);focus_selection())
 hud.command.connect(run_command);hud.navigate.connect(func(point):camera_rig.move_to(point))
 get_window().focus_exited.connect(func():dragging=false)
 company_panel=CompanyPanel.new();company_panel.game=self;hud.add_child(company_panel)
 hud.update_resources(sim);world.animate=false
 camera_rig=CameraRig.new(camera);hud.layout_changed.connect(update_camera_layout);update_camera_layout()
 if "--company-smoke" in OS.get_cmdline_user_args():
  paused=false;autosave_clock=-100000;hud.menu.hide();select_person(7);company_panel.open()
  var signed=load("res://src/entities/company.gd").recruit(sim,"hector")
  people[7].equipment={"coat":2,"color":4,"armor":true,"banner":true,"gait":2}
  get_tree().create_timer(2.0).timeout.connect(func():
   var ok=signed and world.cavalry.coat.size()==5 and world.cavalry.banner.size()==6 and FileAccess.file_exists("res://assets/portraits/kit/kit.json")
   var error=get_viewport().get_texture().get_image().save_png("user://export-company.png")
   print("EXPORTED_COMPANY_OK=",ok," capture=",error)
   get_tree().quit(0 if ok and error==OK else 1))
 if "--smoke" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide()
  get_tree().create_timer(5.0).timeout.connect(func():print("SMOKE_OK version=",ProjectSettings.get_setting("application/config/version")," ticks=",sim.tick_count," people=",sim.people.size()," buildings=",sim.buildings.size());get_tree().quit())
 if "--capture" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide();sim.tick(18);select_person(16);get_tree().create_timer(2.0).timeout.connect(capture)
 if "--capture-night" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide();sim.seconds=145;sim.tick(8);get_tree().create_timer(2.0).timeout.connect(capture)
func update_camera_layout() -> void:
 if camera_rig!=null:camera_rig.configure(get_viewport_rect().size,hud.useful_map_rect())
func capture() -> void:
 var path="user://gameplay-v0.2.1.png" if OS.has_feature("template") else "res://docs/visual-validation/v0.2.1/Camera_Default.png"
 if "--capture-night" in OS.get_cmdline_user_args():path="res://docs/visual-validation/v0.2.1/Night.png"
 var error=get_viewport().get_texture().get_image().save_png(path);print("CAPTURE_RESULT ",error," ",path);get_tree().quit()
func new_game(settings: Dictionary={}) -> void:
 sim=Sim.new(settings);people=sim.people;world.sim=sim;world.people=people;world.refresh();camera_rig.move_to(Iso.project(Vector2(15.5,15.5)));selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1;hud.selection_kind="overview";company_panel.hide();autosave_clock=0;paused=false;hud.menu.hide();hud.roster_panel.hide();hud.update_resources(sim)
 hud.notify(sim.realm_name()+" foi fundada"+(" · semente %d"%sim.world.seed if not sim.world.is_empty() else " · mapa clássico"))
func toggle_pause() -> void:
 if company_panel.visible:company_panel.hide();return
 if hud.roster_panel.visible:hud.roster_panel.hide();return
 if hud.help_panel.visible:hud.help_panel.hide();return
 if not world.build_kind.is_empty():world.build_kind="";return
 paused=not paused
 if paused:hud.menu.open("pause")
 else:hud.menu.hide()
# Menu-bar commands from the HUD.
func run_command(name: String) -> void:
 match name:
  "save":save_game()
  "load":load_game()
  "new_world":
   if not paused:toggle_pause()
   hud.menu.show_setup()
  "main_menu":
   if not paused:toggle_pause()
  "quit":get_tree().quit()
  "company":company_panel.open()
  "speed1","speed2","speed4":set_speed(float(name.right(1)))
  "center":camera_rig.move_to(Iso.project(Vector2(15.5,15.5)))
  "zoom":camera_rig.set_step(2)
  "routes":routes_pinned=not routes_pinned;hud.notify("Rotas fixadas no mapa" if routes_pinned else "Rotas só com Shift")
func set_speed(value: float) -> void:
 speed=value;hud.set_speed(int(value))
func change_profession(kind: int) -> void:
 if sim.set_profession(selected,kind):hud.notify("Ofício atualizado");hud.last_person_kind=-1;hud.show_person(people[selected])
func select_person(index: int) -> void:
 if index<0 or index>=sim.people.size():return
 selected=index;selected_building=-1;world.selected_person=index;world.selected_building=-1;hud.last_person_kind=-1;hud.show_person(sim.people[index])
func select_building(index: int) -> void:
 if index<0 or index>=sim.buildings.size():return
 selected=-1;selected_building=index;world.selected_person=-1;world.selected_building=index;hud.show_building(sim.buildings[index],index)
func focus_selection() -> void:
 if selected>=0 and selected<people.size():camera_rig.move_to(Iso.project(people[selected].position))
 elif selected_building>=0 and selected_building<sim.buildings.size():camera_rig.move_to(Iso.project(Vector2(sim.buildings[selected_building].x,sim.buildings[selected_building].y)))
func person_at(point: Vector2) -> int:
 var found=-1;var nearest=17.0
 for i in range(people.size()):
  var distance=point.distance_to(world.person_point(people[i])-Vector2(0,16))
  if distance<nearest:nearest=distance;found=i
 return found
func save_game() -> void:
 var error=Store.save_game(sim,sim.people);hud.notify("Domínio salvo" if error==OK else "Erro ao salvar: "+str(error))
func load_game() -> void:
 var data=Store.load_game(sim)
 if data.is_empty():hud.notify("Save ausente ou inválido");return
 people=sim.people;world.sim=sim;world.people=people;world.refresh();camera_rig.move_to(Iso.project(Vector2(15.5,15.5)));selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1;hud.selection_kind="overview"
 company_panel.hide()
 paused=false;hud.menu.hide();hud.notify(("Save v0.1 migrado · " if data.migrated else "Domínio carregado · ")+"Offline: %ds"%sim.offline_seconds)
func _process(delta: float) -> void:
 world.animate=not paused
 if not paused:
  var selected_identity=people[selected] if selected>=0 and selected<people.size() else null
  sim.advance(delta*speed);people=sim.people;world.people=people
  if selected_identity!=null:selected=people.find(selected_identity);world.selected_person=selected
  autosave_clock+=delta
  if autosave_clock>=60:autosave_clock=0;Store.save_game(sim,people)
 hud_clock+=delta
 if hud_clock>=0.15:
  hud.update_resources(sim,hud_clock);hud_clock=0
  if hud.selection_kind=="person" and selected>=0 and selected<people.size():hud.show_person(people[selected])
  elif hud.selection_kind=="building" and selected_building>=0 and selected_building<sim.buildings.size():hud.show_building(sim.buildings[selected_building],selected_building)
 var direction=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if not paused:camera_rig.pan_screen(direction.normalized()*delta*440)
 var mouse=get_global_mouse_position();world.hovered=Iso.tile(mouse)
 # Shift traces routes and Ctrl shows a quick-info card, as in Civ2-UI-Additions.
 world.show_routes=not paused and (routes_pinned or Input.is_key_pressed(KEY_SHIFT))
 var area=hud.useful_map_rect()
 hud.camera_view=PackedVector2Array([camera_rig.screen_to_world(area.position),camera_rig.screen_to_world(Vector2(area.end.x,area.position.y)),camera_rig.screen_to_world(area.end),camera_rig.screen_to_world(Vector2(area.position.x,area.end.y))])
 var screen=get_viewport().get_mouse_position()
 if not paused and Input.is_key_pressed(KEY_CTRL) and hud.useful_map_rect().has_point(screen):hud.quick_info(sim,person_at(mouse),sim.building_at(world.hovered),screen)
 else:hud.quick.hide()
func _input(event: InputEvent) -> void:
 # GUI controls may consume the release, so it cannot be handled only as unhandled input.
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_MIDDLE and not event.pressed:
  # A middle click without dragging centres the map there; with Ctrl it restores the default zoom.
  if dragging and event.position.distance_to(drag_origin)<4 and not paused and hud.useful_map_rect().has_point(event.position):
   if event.ctrl_pressed:camera_rig.set_step(2)
   else:camera_rig.move_to(camera_rig.screen_to_world(event.position))
  dragging=false
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode in [KEY_ESCAPE,KEY_SPACE]:toggle_pause()
  elif event.keycode==KEY_F5:save_game()
  elif event.keycode==KEY_R:company_panel.open()
  elif event.keycode==KEY_H:hud.toggle_roster()
  elif event.keycode==KEY_B:hud.toggle_build()
  elif event.keycode==KEY_I:hud.toggle_details()
  elif event.keycode==KEY_C:run_command("center")
  elif event.keycode in [KEY_1,KEY_2,KEY_4]:set_speed(float(event.keycode-KEY_0))
 if event is InputEventMouseButton:
  if event.button_index==MOUSE_BUTTON_MIDDLE:dragging=event.pressed;drag_origin=event.position
  if paused:return
  if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
   camera_rig.zoom_at(1 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -1,event.position)
  if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:click_map()
 if event is InputEventMouseMotion and dragging and not paused:camera_rig.pan_screen(-event.relative)
func click_map() -> void:
 var cell=Iso.tile(get_global_mouse_position())
 if not world.build_kind.is_empty():
  var reason=sim.placement_reason(world.build_kind,cell)
  if sim.build(world.build_kind,cell):world.refresh();hud.notify("Obra iniciada")
  else:hud.notify(reason if not reason.is_empty() else "A obra bloquearia um acesso")
  return
 selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1
 var person=person_at(get_global_mouse_position())
 if person>=0:select_person(person);return
 if sim.building_at(cell)>=0:select_building(sim.building_at(cell))
 else:hud.selection_kind="overview";hud.show_overview(sim)
