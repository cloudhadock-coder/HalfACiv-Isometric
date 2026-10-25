extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Realm=preload("res://src/politics/realm.gd")
const Store=preload("res://src/persistence/save_store.gd")
const WorldGen=preload("res://src/world/world_gen.gd")
const FOLDER="res://docs/visual-validation/v0.4.1/"
var checks: int=0
var failures: int=0
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;push_error(text)
func _init() -> void:call_deferred("run")
func write(data: Dictionary) -> void:
 var f=FileAccess.open(Store.PATH,FileAccess.WRITE);f.store_string(JSON.stringify(data));f.close()
func shot(name: String) -> void:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 if "--no-save" not in OS.get_cmdline_user_args():root.get_texture().get_image().save_png(FOLDER+name+".png")
func rich(sim) -> void:
 for key in sim.resources:sim.resources[key]=10000.0
func run() -> void:
 Store.PATH="res://tests/politics-save.json";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
 var sim=Sim.new();var p=sim.politics
 check(p.stage==0 and p.legitimacy==50 and p.support.size()==4,"neutral initial politics")
 var before=p.snapshot();var resources=sim.resources.duplicate()
 check(not p.decide(sim,"unknown") and p.snapshot()==before and sim.resources==resources,"unknown decision atomic")
 sim.resources.food=0;resources=sim.resources.duplicate()
 check(not p.decide(sim,"relief") and sim.resources==resources and p.last_council_day==0,"unaffordable decision atomic")
 sim.resources.food=160
 check(p.decide(sim,"relief"),"first council decision")
 check(sim.resources.food==120 and sim.resources.gold==70 and sim.resources.influence==15,"decision exact costs and reward")
 check(p.support.peasants==62 and p.support.guilds==46 and p.support.clergy==53 and p.support.nobility==46 and p.legitimacy==55,"decision effects match preview")
 resources=sim.resources.duplicate();before=p.snapshot()
 check(not p.decide(sim,"oath") and sim.resources==resources and p.snapshot()==before,"once per day across all decisions")
 check(not p.promote(sim),"promotion requires costs")
 sim.resources.gold=80
 check(p.promote(sim) and p.stage==1 and sim.resources.gold==0 and sim.resources.influence==0,"promotion requires explicit action and consumes exact cost")
 check(not p.promote(sim),"cannot skip stages")
 rich(sim)
 check(p.enact(sim,"commons") and p.production_multiplier("food")==1.15,"promulgate available reform")
 resources=sim.resources.duplicate()
 check(not p.enact(sim,"commons") and sim.resources==resources,"reform is one-time transaction")
 check(not p.enact(sim,"parish"),"stage gates reforms")
 p.support.guilds=0;check(not p.enact(sim,"weights"),"faction gates reform")
 p.support.guilds=100;p.support.clergy=100;p.support.nobility=100;p.support.peasants=100;p.legitimacy=99
 sim.seconds=240;p.decide(sim,"oath")
 check(p.legitimacy==100 and p.support.nobility==100,"support and legitimacy clamped")
 before=p.snapshot();sim.apply_offline(7200)
 check(p.snapshot()==before,"offline never decides promotes or changes support")
 sim.tick(1);check(p.snapshot()==before,"online ticks never make political choices")
 check(p.decide(sim,"guild_charter"),"new day enables next deliberation")
 var levy=Sim.new();var old_gold=levy.resources.gold
 check(levy.politics.decide(levy,"levy") and levy.resources.gold==old_gold+45 and levy.politics.legitimacy==44 and levy.politics.support.peasants==40,"extra tax trades legitimacy and support for treasury")
 # All five tiers reachable with a controlled, developed settlement fixture.
 var developed=Sim.new();rich(developed);developed.population=48
 while developed.people.size()<49:developed.people.insert(developed.people.size()-1,developed.Citizen.new(0,Vector2i(15,15)))
 for cell in [Vector2i(7,10),Vector2i(8,10),Vector2i(9,10),Vector2i(10,10),Vector2i(11,10),Vector2i(12,10)]:developed.buildings.append(developed.Catalog.make("house",cell))
 developed.buildings.append(developed.Catalog.make("barracks",Vector2i(9,12)))
 developed.politics.legitimacy=100
 for key in Realm.FACTIONS:developed.politics.support[key]=100
 for tier in range(1,5):
  if tier==4:
   check(not developed.politics.promote(developed),"kingdom requires three reforms")
   for id in ["commons","weights","parish"]:check(developed.politics.enact(developed,id),"reform on road to kingdom "+id)
  check(developed.politics.promote(developed) and developed.politics.stage==tier,"promotion tier "+str(tier))
 check(not developed.politics.promote(developed),"kingdom is final tier")
 check(not p.promote(Sim.new()),"underdeveloped domain cannot promote")
 Store.save_game(sim);var resumed=Sim.new();Store.load_game(resumed)
 check(not resumed.politics.decide(resumed,"levy") and resumed.politics.history.size()==sim.politics.history.size(),"reload preserves council cooldown and chronicle")
 # Work and offline production both honour reforms, input rates remain unchanged.
 var plain=Sim.new();var boosted=Sim.new()
 for id in ["commons","weights","parish","assembly"]:boosted.politics.reforms.append(id)
 boosted.politics.stage=2
 var mill=plain.nearest_kind(["mill"],Vector2.ZERO);plain.work(mill,1);boosted.work(mill,1)
 check(is_equal_approx(boosted.buildings[mill].stored.food/plain.buildings[mill].stored.food,1.15),"actual food production modifier")
 var forge=plain.nearest_kind(["forge"],Vector2.ZERO);var old=plain.resources.wood
 plain.work(forge,1);boosted.work(forge,1)
 check(is_equal_approx(boosted.buildings[forge].stored.gold/plain.buildings[forge].stored.gold,1.15) and is_equal_approx(boosted.resources.wood,plain.resources.wood),"reform output bonus retains input rates")
 var gold=plain.resources.gold;var boost_gold=boosted.resources.gold
 plain.tick(0.1);boosted.tick(0.1)
 check(is_equal_approx((boosted.resources.gold-boost_gold)/(plain.resources.gold-gold),1.1),"actual population tax modifier")
 plain=Sim.new();boosted=Sim.new();boosted.politics.reforms=["commons","weights","parish","assembly"];boosted.politics.stage=2
 var baseline_influence=plain.resources.influence;var boosted_influence=boosted.resources.influence
 plain.apply_offline(1);boosted.apply_offline(1)
 check(boosted.resources.food>plain.resources.food and boosted.resources.gold>plain.resources.gold and boosted.resources.influence-boosted_influence>plain.resources.influence-baseline_influence,"offline production and taxes apply enacted reforms")
 # Current saves, older schema2 saves, seeded worlds and invalid data are tested atomically.
 check(Store.save_game(developed)==OK,"save kingdom")
 var loaded=Sim.new();check(not Store.load_game(loaded).is_empty() and loaded.politics.stage==4 and loaded.politics.reforms.size()==3,"kingdom roundtrip")
 var data=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH));data.erase("politics");write(data)
 check(not Store.load_game(loaded).is_empty() and loaded.politics.stage==0 and loaded.politics.legitimacy==50,"older saves default neutral without invented decisions")
 data.politics=developed.politics.snapshot();data.politics.support.guilds=101;write(data);var identity=loaded.people[0];var state=loaded.politics
 check(Store.load_game(loaded).is_empty() and loaded.people[0]==identity and loaded.politics==state,"invalid politics rejected without live mutation")
 for bad in [null,[],{"stage":1}, {"stage":99}]:check(Realm.restore(bad)==null,"malformed political state rejected")
 data.politics=developed.politics.snapshot();data.politics.last_council_day=1000;write(data)
 check(Store.load_game(loaded).is_empty(),"future council day rejected")
 var seeded=Sim.new(WorldGen.normalize({"seed":417,"name":"Domínio do conselho"}));seeded.politics.legitimacy=67
 Store.save_game(seeded);check(not Store.load_game(loaded).is_empty() and loaded.world.seed==417 and loaded.politics.legitimacy==67,"seeded world roundtrip with politics")
 for i in range(45):p.record(sim,"Registro "+str(i))
 check(p.history.size()==40,"chronicle bounded")
 # Real game/UI; preview and button result, small-window layout, live readiness refresh.
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame;await process_frame
 game.paused=true;game.hud.menu.hide();game.autosave_clock=-100000
 game.run_command("council");check(game.council_panel.visible,"menu command opens council")
 await shot("Council")
 check(game.council_panel.position.y>=0 and game.council_panel.position.y+game.council_panel.size.y<=game.get_viewport_rect().size.y/game.hud.scale.y+1,"first-open layout stays inside viewport")
 var button
 for child in game.council_panel.body.get_children():
  if child is Button and child.get_meta("id","")=="relief":button=child;break
 check(button!=null and not button.disabled,"affordable decision button")
 var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=button.get_global_transform_with_canvas()*(button.size/2)
 Input.warp_mouse(click.position);await process_frame;Input.parse_input_event(click)
 var release=click.duplicate();release.pressed=false;Input.parse_input_event(release);await process_frame
 check(game.sim.politics.last_council_day==1 and game.sim.resources.gold==70,"actual mouse click executes decision transaction")
 game.sim.resources.gold=200;game.council_panel.tab=2;game.council_panel.rebuild();await shot("Progression")
 game.sim.resources.gold=0;game.council_panel.update_summary();game.council_panel.update_buttons()
 check(game.council_panel.pending_label.text.contains("ouro") and game.council_panel.body.get_children().back().disabled,"live resources refresh requirements and readiness")
 game.sim.resources.gold=200;game.council_panel.update_summary();game.council_panel.update_buttons()
 game.council_panel.body.get_children().back().pressed.emit();check(game.sim.politics.stage==1,"UI promotion transaction")
 game.council_panel.tab=1;game.council_panel.rebuild();await shot("Reforms")
 root.size=Vector2i(960,540);await shot("Council_960x540")
 var panel=game.council_panel;check(panel.position.x>=0 and panel.position.y>=0 and (panel.position+panel.size).y<=game.get_viewport_rect().size.y/game.hud.scale.y+1,"small viewport fits council")
 root.size=Vector2i(1920,1080);await shot("Council_1080p")
 game.council_panel.tab=3;game.council_panel.rebuild();await shot("Chronicle")
 game.toggle_pause();check(not game.council_panel.visible and game.paused,"escape closes council without resuming")
 game.sim=developed;game.people=developed.people;game.world.sim=developed;game.world.refresh();game.hud.update_resources(developed)
 game.run_command("council");game.council_panel.tab=2;game.council_panel.rebuild();await shot("Kingdom_Fixture")
 game.new_game();check(game.sim.politics.stage==0 and not game.council_panel.visible,"new campaign resets politics and panel")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(Store.PATH+suffix))
 print("POLITICS_RESULT checks=",checks," failures=",failures);quit(1 if failures else 0)
