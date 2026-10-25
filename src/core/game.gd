extends Node2D
const Sim=preload("res://src/economy/simulation.gd")
const Navigation=preload("res://src/world/navigation.gd")
const Citizen=preload("res://src/entities/citizen.gd")
const World=preload("res://src/rendering/world_view.gd")
const HUD=preload("res://src/ui/hud.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Iso=preload("res://src/world/iso.gd")
var sim=Sim.new()
var nav=Navigation.new()
var people: Array=[]
var world
var hud
var camera: Camera2D
var paused: bool=true
var dragging: bool=false
var selected: int=-1
var autosave_clock: float=0
func _ready() -> void:
 nav.rebuild(sim);spawn_people()
 world=World.new();world.sim=sim;world.people=people;add_child(world)
 camera=Camera2D.new();camera.position=Iso.project(Vector2(15,15));camera.zoom=Vector2(1.6,1.6);add_child(camera);world.camera=camera
 hud=HUD.new();add_child(hud)
 hud.build_selected.connect(func(kind):world.build_kind=kind)
 hud.pause_requested.connect(toggle_pause);hud.save_requested.connect(save_game);hud.load_requested.connect(load_game);hud.new_requested.connect(new_game);hud.update_resources(sim)
 if "--smoke" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide()
  get_tree().create_timer(4.0).timeout.connect(func():print("SMOKE_OK ticks=",sim.tick_count," people=",people.size());get_tree().quit())
 if "--capture" in OS.get_cmdline_user_args():
  paused=false;hud.menu.hide();selected=7;world.selected_person=7;hud.show_person(people[7]);get_tree().create_timer(3.0).timeout.connect(capture)
func capture() -> void:
 var img=get_viewport().get_texture().get_image();img.save_png("res://docs/gameplay.png");print("CAPTURE_OK");get_tree().quit()
func spawn_people() -> void:
 people.clear()
 for i in range(13):people.append(Citizen.new(i,Vector2i(14+(i%2),10+i)))
func new_game() -> void:
 sim=Sim.new();nav.rebuild(sim);spawn_people();world.sim=sim;world.people=people;world.selected_person=-1;selected=-1;paused=false;hud.menu.hide()
func toggle_pause() -> void:
 if not world.build_kind.is_empty():world.build_kind="";return
 paused=not paused;hud.menu.visible=paused
func save_game() -> void:
 var err=Store.save_game(sim,people);hud.details.text="Dominio salvo." if err==OK else "Erro ao salvar: "+str(err)
func load_game() -> void:
 var data=Store.load_game(sim)
 if data.is_empty():hud.details.text="Save ausente ou invalido.";return
 nav.rebuild(sim);spawn_people()
 var entries=data.get("people",[])
 for i in range(mini(entries.size(),people.size())):
  var p=entries[i];var cell=Vector2i(roundi(float(p.x)),roundi(float(p.y)))
  if not sim.blocked(cell):people[i].position=Vector2(cell)
 paused=false;hud.menu.hide();hud.details.text="Dominio carregado. Progresso offline: %ds (limite 2h)."%sim.offline_seconds
func _process(delta: float) -> void:
 if not paused:
  sim.advance(delta)
  for c in people:c.update(delta,nav)
  autosave_clock+=delta
  if autosave_clock>=60:autosave_clock=0;Store.save_game(sim,people)
  if selected>=0 and selected<people.size():hud.show_person(people[selected])
 hud.update_resources(sim)
 var direction=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if not paused:camera.position+=direction.normalized()*delta*440/camera.zoom.x
 camera.position.x=clampf(camera.position.x,-800,800);camera.position.y=clampf(camera.position.y,80,950);world.hovered=Iso.tile(get_global_mouse_position())
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed:
  if event.keycode==KEY_ESCAPE:toggle_pause()
  elif event.keycode==KEY_F5:save_game()
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
  for c in people:
   if Vector2i(c.position.round())==cell or Vector2i(c.position.floor())==cell or Vector2i(c.position.ceil())==cell:hud.details.text="Aguarde a passagem do habitante.";return
  if sim.build(world.build_kind,cell):
   nav.rebuild(sim)
   for c in people:
    c.position=c.position.round()
    c.route.clear()
   hud.details.text="Construcao iniciada."
  else:hud.details.text="Local bloqueado ou recursos insuficientes."
  return
 selected=-1;world.selected_person=-1;var nearest=24.0
 for i in range(people.size()):
  var distance=get_global_mouse_position().distance_to(Iso.project(people[i].position)-Vector2(0,18))
  if distance<nearest:nearest=distance;selected=i
 if selected>=0:world.selected_person=selected;hud.show_person(people[selected]);return
 var index=sim.building_at(cell)
 if index>=0:hud.show_building(sim.buildings[index])
