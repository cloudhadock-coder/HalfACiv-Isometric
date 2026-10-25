extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Company=preload("res://src/entities/company.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks: int=0
var failures: int=0
const FOLDER="res://docs/visual-validation/v0.3.0/"
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(message)
func _init() -> void:call_deferred("run")
func shot(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 if "--no-save" not in OS.get_cmdline_user_args():root.get_texture().get_image().save_png(FOLDER+name+".png")
func run() -> void:
 Store.PATH="res://tests/company-save.json"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 var sim=Sim.new();var count=sim.people.size();var gold=sim.resources.gold
 check(not Company.recruit(sim,"missing"),"unknown contract rejected")
 check(Company.recruit(sim,"hector"),"hire knight")
 check(sim.people.size()==count and sim.resources.gold==gold-55,"unique existing identity and exact cost")
 check(not Company.recruit(sim,"hector") and sim.resources.gold==gold-55,"no duplicate billing")
 check(not Company.recruit(sim,"ulric"),"insufficient gold rejected")
 var rider=sim.people[7];check(Company.bonus(rider)==0.2,"knight movement bonus")
 rider.equipment={"coat":4,"color":5,"armor":true,"banner":true,"gait":2}
 check(Store.save_game(sim)==OK,"save equipment and contracts")
 var restored=Sim.new();check(not Store.load_game(restored).is_empty(),"reload current save")
 check(restored.people[7].equipment==rider.equipment and restored.people[7].specialist=="hector","equipment and contract roundtrip")
 var data=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH))
 for entry in data.people:entry.erase("equipment");entry.erase("specialist")
 var file=FileAccess.open(Store.PATH,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
 check(not Store.load_game(restored).is_empty() and restored.people[7].equipment.gait==0,"old schema2 save default equipment")
 var identity=restored.people[0]
 data.people[0].equipment={"color":99};file=FileAccess.open(Store.PATH,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
 check(Store.load_game(restored).is_empty() and restored.people[0]==identity,"malformed equipment rejected atomically")
 check(not Company.valid_equipment({"armor":1}) and not Company.valid_equipment({"coat":1.2}),"strict equipment validation")
 var start=Vector2(15,15)
 rider.position=start;rider.route.clear();rider.route.append(Vector2i(15,16));rider.equipment.gait=0;rider.update(0.1,sim.nav,sim)
 var walk_distance=start.distance_to(rider.position)
 rider.position=start;rider.route.clear();rider.route.append(Vector2i(15,16));rider.equipment.gait=2;rider.update(0.1,sim.nav,sim)
 check(is_equal_approx(start.distance_to(rider.position)/walk_distance,1.65),"gait changes actual navigation speed")
 var missing=Sim.new();missing.people.remove_at(7);missing.population-=1
 check(Company.recruit(missing,"hector") and missing.people.size()==25,"absent founder recruited as new resident")
 var no_stable=Sim.new();no_stable.buildings=no_stable.buildings.filter(func(entry):return entry.kind!="stable")
 check(not Company.recruit(no_stable,"hector"),"knight requires completed stable")
 sim.resources.gold=500
 check(Company.recruit(sim,"ulric"),"hire production specialist")
 var smith=sim.people[16];var index=smith.employer;var wood=sim.resources.wood;var b=sim.buildings[index]
 sim.work(index,1+Company.bonus(smith))
 check(is_equal_approx(sim.resources.wood,wood-float(sim.Catalog.DATA[b.kind].inputs.wood)*1.25/float(sim.Catalog.DATA[b.kind].slots)),"specialist inputs scale with output")
 sim.set_profession(16,0);check(Company.bonus(smith)==0,"bonus limited to contracted profession")
 var offline=Sim.new();var baseline=Sim.new();offline.resources.gold=500;baseline.resources.gold=455
 Company.recruit(offline,"ulric");var old=offline.resources.wood
 offline.apply_offline(1);baseline.apply_offline(1)
 check(offline.resources.wood<baseline.resources.wood and offline.resources.gold>baseline.resources.gold,"offline production contract scales inputs and output")
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame;await process_frame
 game.paused=true;game.hud.menu.hide();game.world.animate=false;game.select_person(7)
 game.company_panel.open();await shot("Recruitment")
 check(game.company_panel.visible,"company panel opens")
 var offers=game.company_panel.content.get_child(2).get_child(0)
 offers.get_child(1).get_child(1).get_child(2).pressed.emit()
 check(game.people[7].specialist=="hector" and game.sim.resources.gold==35,"actual recruitment button signs contract")
 game.company_panel.tab=1;game.company_panel.rebuild();await process_frame
 var list=game.company_panel.content.get_child(2).get_child(0)
 var select=list.get_child(2).get_child(1);select.select(2);select.item_selected.emit(2)
 check(game.people[7].equipment.coat==2,"actual equipment option signal")
 game.people[7].equipment.armor=true;game.people[7].equipment.banner=true
 await shot("Equipment")
 root.size=Vector2i(960,540);await shot("Equipment_960x540")
 check(game.company_panel.position.x>=0 and (game.company_panel.position.y+game.company_panel.size.y)*game.hud.scale.y<=game.get_viewport_rect().size.y,"equipment panel fits small viewport")
 root.size=Vector2i(1280,720);game.company_panel.hide();game.hud.toggle_build();game.hud.toggle_details()
 game.camera_rig.configure(game.get_viewport_rect().size,game.hud.useful_map_rect());game.camera_rig.move_to(Vector2(0,480))
 game.people[7].position=Vector2(15,15);game.people[7].previous=game.people[7].position
 for i in range(6):
  var actor=game.sim.Citizen.new(7,Vector2i(12+i,15));actor.equipment.color=i;actor.equipment.coat=i%5;actor.equipment.armor=true;actor.equipment.banner=true;game.people.append(actor)
 game.world.people=game.people;await shot("Heraldry")
 game.paused=false;game.hud.menu.hide();var clock=game.people[7].clock
 await create_timer(1.0).timeout;check(game.people[7].clock>clock,"animations continue")
 await shot("Village")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(Store.PATH+suffix))
 print("COMPANY_RESULT checks=",checks," failures=",failures)
 quit(1 if failures else 0)
