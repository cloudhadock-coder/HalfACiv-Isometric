extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Iso=preload("res://src/world/iso.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Citizen=preload("res://src/entities/citizen.gd")
const Professions=preload("res://src/entities/professions.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error("FAIL: "+label)
func file_json(value) -> void:
 var f=FileAccess.open(Store.PATH,FileAccess.WRITE);f.store_string(JSON.stringify(value));f.close()
func _init() -> void:
 for x in range(32):
  for y in range(32):check(Iso.tile(Iso.project(Vector2(x,y)))==Vector2i(x,y),"iso roundtrip")
 var s=Sim.new()
 check(Professions.DATA.size()==24,"24 professions")
 check(s.people.size()==25 and s.population==24,"24 villagers and horse")
 check(s.Catalog.DATA.size()==18,"18 building kinds")
 check(s.housing_capacity()==24,"housing capacity")
 var wood=s.resources.wood
 check(s.build("house",Vector2i(19,14)),"place house")
 check(s.resources.wood==wood-25,"charge exactly once")
 check(not s.build("house",Vector2i(19,14)),"reject overlap")
 check(not s.build("farm",Vector2i(26,20)),"reject water")
 check(not s.build("farm",Vector2i(15,15)),"preserve plaza")
 check(not s.build("fishery",Vector2i(10,10)),"fishery requires shoreline")
 check(s.build("fishery",Vector2i(24,8)),"fishery on shore")
 s.tick(14);check(s.buildings[s.buildings.size()-2].remaining==0,"construction completes")
 check(s.housing_capacity()==28,"completed house adds capacity")
 s.tick(7);check(s.population==25,"immigration grows population within capacity")
 s.resources.wood=0;check(not s.build("house",Vector2i(20,14)),"reject unaffordable")
 # Production requires people and delivery, not just owning a building.
 var idle=Sim.new();idle.people.clear();idle.population=0
 var initial=idle.resources.wood;idle.tick(12);check(is_equal_approx(idle.resources.wood,initial),"unoccupied lumber does not produce")
 var working=Sim.new();var worker=working.people[2];var employer=worker.employer
 check(employer>=0 and working.buildings[employer].kind=="lumber","profession assigned to compatible workplace")
 var before=working.resources.wood;check(working.work(employer,3),"staffed recipe runs")
 check(working.resources.wood==before and working.buildings[employer].stored.wood>0,"output waits in workplace")
 var cargo=working.take_cargo(employer);worker.cargo=cargo;worker.task="deliver";worker.route.clear();worker.update(0.1,working.nav,working)
 check(working.resources.wood>before and worker.delivered==1,"delivery credits inventory once")
 check(worker.cargo.is_empty(),"delivery clears cargo")
 var forge=working.nearest_kind(["forge"],Vector2.ZERO)
 working.resources.wood=0;var gold=working.buildings[forge].stored.get("gold",0)
 check(not working.work(forge,1),"forge cannot run without fuel")
 check(working.buildings[forge].stored.get("gold",0)==gold,"missing inputs cannot create output")
 check(working.set_profession(2,16),"change profession")
 check(working.people[2].kind==16 and working.people[2].portrait_id==2,"profession preserves personal appearance")
 check(not working.set_profession(24,16),"horse cannot become worker")
 check(not working.set_profession(999,16),"reject invalid citizen")
 # Follow complete village routines and check every traversed tile.
 var village=Sim.new();var delivered=false;var working_seen=false;var cargo_seen=false
 for i in range(800):
  village.tick(0.1)
  for c in village.people:
   check(not village.blocked(Vector2i(c.position.round())),"routine avoids obstacles")
   delivered=delivered or c.delivered>0
   cargo_seen=cargo_seen or not c.cargo.is_empty()
   working_seen=working_seen or c.task=="work"
 check(delivered and cargo_seen and working_seen,"work transport and delivery cycle")
 var meal=village.people[15];meal.cargo.clear();meal.route.clear();meal.position=Vector2(village.meeting_entrance(village.nav));meal.task="rest";village.seconds=60;village.tick(0.1)
 check(meal.task=="meal","midday meal")
 meal.route.clear();meal.position=Vector2(meal.home);meal.task="rest";meal.stamina=40;village.seconds=150;village.tick(0.1)
 check(meal.task=="sleep" and meal.stamina>40,"night sleep restores stamina")
 # Building across a narrow road must not trap an inhabitant.
 var corridor=Sim.new();corridor.buildings.clear()
 for cell in corridor.terrain:corridor.terrain[cell]="water"
 for x in range(5,21):corridor.terrain[Vector2i(x,15)]="road"
 corridor.people=[Citizen.new(0,Vector2i(10,15))];corridor.nav.rebuild(corridor)
 var balance=corridor.resources.wood
 check(not corridor.build("house",Vector2i(12,15)),"reject construction that isolates citizen")
 check(corridor.resources.wood==balance and corridor.buildings.is_empty(),"failed reachability check rolls back cost and obstacle")
 # Render frame rate cannot change the simulation result.
 var a=Sim.new();var b=Sim.new();a.tick(30)
 for i in range(600):b.advance(0.05)
 for key in a.resources:check(is_equal_approx(a.resources[key],b.resources[key]),"fixed step deterministic "+key)
 var offline=Sim.new();var other=Sim.new();var old_position=offline.people[2].position
 offline.apply_offline(100);other.apply_offline(100)
 check(offline.resources==other.resources,"offline deterministic")
 check(offline.people[2].position==old_position and offline.people[2].delivered==0,"offline does not simulate NPC events")
 offline.apply_offline(100000);check(offline.offline_seconds==7200,"offline cap")
 offline.apply_offline(-1);check(offline.offline_seconds==0,"future saves give no offline progress")
 for key in offline.resources:check(offline.resources[key]>=0,"resource nonnegative "+key)
 # Save schema 2 preserves stocks, identities, delivery cargo and clock.
 Store.PATH="res://tests/realm-test.json"
 var saved=Sim.new();saved.people[2].cargo={"wood":6.0};saved.people[2].stamina=57;saved.people[2].delivered=9;saved.seconds=42
 check(Store.save_game(saved)==OK,"save schema 2")
 var original_food=saved.resources.food;saved.resources.food+=3
 check(Store.save_game(saved)==OK,"replace existing save atomically")
 var backup=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH+".bak"))
 check(backup.resources.food==original_food,"backup retains previous inventory")
 var data=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH));data.saved_at=int(Time.get_unix_time_from_system())+60;file_json(data)
 var loaded=Sim.new();var result=Store.load_game(loaded)
 check(not result.is_empty() and not result.migrated,"load schema 2")
 check(loaded.people[2].cargo==saved.people[2].cargo and loaded.people[2].delivered==9,"cargo and delivery counters persist")
 check(loaded.people[2].stamina==57 and loaded.seconds==42,"stamina and time persist")
 # v0.1 migration retains the original community and bank, without granting 12 extra villagers.
 var legacy_people=[]
 for i in range(13):legacy_people.append({"x":14,"y":10+i,"kind":i%12,"horse_only":i==12})
 file_json({"schema":1,"saved_at":int(Time.get_unix_time_from_system())+60,"tick":7,"resources":saved.resources,"buildings":[{"kind":"house","x":12,"y":12,"remaining":0,"level":1}],"people":legacy_people})
 var legacy=Sim.new();result=Store.load_game(legacy)
 check(not result.is_empty() and result.migrated,"schema 1 migration")
 check(legacy.people.size()==13 and legacy.population==12,"legacy population retained")
 check(legacy.resources==saved.resources,"migration conserves resources")
 check(Store.save_game(legacy)==OK and FileAccess.file_exists(Store.PATH+".v0.1.bak"),"legacy save backup retained separately")
 var centred={"schema":1,"saved_at":int(Time.get_unix_time_from_system())+60,"tick":7,"resources":saved.resources,"buildings":[{"kind":"house","x":15,"y":15,"remaining":0,"level":1}],"people":legacy_people}
 file_json(centred)
 var centred_game=Sim.new();check(not Store.load_game(centred_game).is_empty(),"legacy building on old plaza accepted")
 check(centred_game.build("house",Vector2i(22,14)),"legacy occupied plaza does not block expansion")
 var original=loaded.resources.duplicate()
 file_json({"schema":2,"resources":saved.resources,"buildings":[{"kind":"house","x":"bad","y":2,"remaining":0,"level":1}]})
 check(Store.load_game(loaded).is_empty() and loaded.resources==original,"invalid save leaves live state untouched")
 var f=FileAccess.open(Store.PATH,FileAccess.WRITE);f.store_string("{broken");f.close();check(Store.load_game(loaded).is_empty(),"corrupted JSON rejected")
 for suffix in ["",".bak",".tmp",".v0.1.bak"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(Store.PATH+suffix)
 print("TEST_RESULT assertions=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
