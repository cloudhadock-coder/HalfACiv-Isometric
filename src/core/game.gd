extends Node2D
const Sim=preload("res://src/economy/simulation.gd")
const World=preload("res://src/rendering/world_view.gd")
const HUD=preload("res://src/ui/hud.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
var sim=Sim.new()
var people: Array=[]
var world
var hud
var camera: Camera2D
var paused: bool=true
var dragging: bool=false
var selected: int=-1
var selected_building: int=-1
var autosave_clock: float=0
var hud_clock: float=0
var speed: float=1
func _ready() -> void:
 people=sim.people
 world=World.new();world.sim=sim;world.people=people;add_child(world)
 camera=Camera2D.new();camera.position=Iso.project(Vector2(15.5,15));camera.zoom=Vector2(1.65,1.65);add_child(camera);world.camera=camera
 hud=HUD.new();add_child(hud)
 hud.build_selected.connect(func(kind):world.build_kind=kind)
 hud.pause_requested.connect(toggle_pause);hud.save_requested.connect(save_game);hud.load_requested.connect(load_game);hud.new_requested.connect(new_game)
 hud.speed_changed.connect(set_speed);hud.profession_changed.connect(change_profession);hud.citizen_selected.connect(select_person)
 hud.update_resources(sim);world.animate=false
 if "--smoke" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide()
  get_tree().create_timer(5.0).timeout.connect(func():print("SMOKE_OK version=0.2.0 ticks=",sim.tick_count," people=",sim.people.size()," buildings=",sim.buildings.size());get_tree().quit())
 if "--capture" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide();sim.tick(18);select_person(16);get_tree().create_timer(2.0).timeout.connect(capture)
 if "--capture-night" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide();sim.seconds=145;sim.tick(8);get_tree().create_timer(2.0).timeout.connect(capture)
func capture() -> void:
 var path="user://gameplay-v0.2.0.png" if OS.has_feature("template") else "res://docs/gameplay-v0.2.0.png"
 if "--capture-night" in OS.get_cmdline_user_args():path="res://docs/night-v0.2.0.png"
 var error=get_viewport().get_texture().get_image().save_png(path);print("CAPTURE_RESULT ",error," ",path);get_tree().quit()
func new_game() -> void:
 sim=Sim.new();people=sim.people;world.sim=sim;world.people=people;world.refresh();selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1;hud.selection_kind="overview";autosave_clock=0;paused=false;hud.menu.hide();hud.roster_panel.hide();hud.notify("Uma nova aldeia nasceu")
func toggle_pause() -> void:
 if hud.roster_panel.visible:hud.roster_panel.hide();return
 if not world.build_kind.is_empty():world.build_kind="";return
 paused=not paused;hud.menu.visible=paused
func set_speed(value: float) -> void:
 speed=value;hud.set_speed(int(value))
func change_profession(kind: int) -> void:
 if sim.set_profession(selected,kind):hud.notify("Ofício atualizado");hud.last_person_kind=-1;hud.show_person(people[selected])
func select_person(index: int) -> void:
 if index<0 or index>=sim.people.size():return
 selected=index;selected_building=-1;world.selected_person=index;world.selected_building=-1;hud.last_person_kind=-1;hud.show_person(sim.people[index])
func save_game() -> void:
 var error=Store.save_game(sim,sim.people);hud.notify("Domínio salvo" if error==OK else "Erro ao salvar: "+str(error))
func load_game() -> void:
 var data=Store.load_game(sim)
 if data.is_empty():hud.notify("Save ausente ou inválido");return
 people=sim.people;world.sim=sim;world.people=people;world.refresh();selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1;hud.selection_kind="overview"
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
 if not paused:camera.position+=direction.normalized()*delta*440/camera.zoom.x
 camera.position.x=clampf(camera.position.x,-800,800);camera.position.y=clampf(camera.position.y,80,950);world.hovered=Iso.tile(get_global_mouse_position())
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode in [KEY_ESCAPE,KEY_SPACE]:toggle_pause()
  elif event.keycode==KEY_F5:save_game()
  elif event.keycode in [KEY_1,KEY_2,KEY_4]:set_speed(float(event.keycode-KEY_0))
 if event is InputEventMouseButton:
  if event.button_index==MOUSE_BUTTON_MIDDLE:dragging=event.pressed
  if paused:return
  if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
   var z=clampf(camera.zoom.x*(1.12 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 0.89),0.65,3.5);camera.zoom=Vector2(z,z)
  if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:click_map()
 if event is InputEventMouseMotion and dragging and not paused:camera.position-=event.relative/camera.zoom
func click_map() -> void:
 var cell=Iso.tile(get_global_mouse_position())
 if not world.build_kind.is_empty():
  var reason=sim.placement_reason(world.build_kind,cell)
  if sim.build(world.build_kind,cell):world.refresh();hud.notify("Obra iniciada")
  else:hud.notify(reason if not reason.is_empty() else "A obra bloquearia um acesso")
  return
 selected=-1;selected_building=-1;world.selected_person=-1;world.selected_building=-1;var nearest=17.0
 for i in range(people.size()):
  var distance=get_global_mouse_position().distance_to(world.person_point(people[i])-Vector2(0,16))
  if distance<nearest:nearest=distance;selected=i
 if selected>=0:select_person(selected);return
 selected_building=sim.building_at(cell)
 if selected_building>=0:world.selected_building=selected_building;hud.show_building(sim.buildings[selected_building],selected_building)
 else:hud.selection_kind="overview";hud.show_overview(sim)
