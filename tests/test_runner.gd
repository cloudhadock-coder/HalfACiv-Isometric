extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Iso=preload("res://src/world/iso.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Citizen=preload("res://src/entities/citizen.gd")
const Professions=preload("res://src/entities/professions.gd")
const PortraitKit=preload("res://src/ui/portrait_kit.gd")
const Ledger=preload("res://src/ui/village_ledger.gd")
const WorldGen=preload("res://src/world/world_gen.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error("FAIL: "+label)
func sha(bytes: PackedByteArray) -> String:
 var ctx=HashingContext.new();ctx.start(HashingContext.HASH_SHA256);ctx.update(bytes);return ctx.finish().hex_encode()
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
 s.people[0].position=Vector2(15.25,8.125)
 var positions=[]
 for person in s.people:positions.append(person.position)
 var wood=s.resources.wood
 check(s.build("house",Vector2i(19,14)),"place house")
 check(s.resources.wood==wood-25,"charge exactly once")
 for i in range(s.people.size()):check(s.people[i].position==positions[i],"construction does not teleport villagers")
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
 working.people[2].position=Vector2(15.25,8.125)
 var exact_position=working.people[2].position
 check(working.set_profession(2,16),"change profession")
 check(working.people[2].position==exact_position,"profession change does not teleport to a tile centre")
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
 var saved=Sim.new();saved.people[2].cargo={"wood":6.0};saved.people[2].stamina=57;saved.people[2].delivered=9;saved.seconds=42;saved.people[2].position=Vector2(15.25,8.125);saved.people[3].appearance=PortraitKit.recipe(99)
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
 check(loaded.people[2].position.distance_to(saved.people[2].position)<0.001,"save load preserves fractional feet position")
 check(not loaded.people[3].appearance.is_empty() and loaded.people[3].appearance==saved.people[3].appearance,"generated appearance persists")
 data.people[3].appearance={"head":42};file_json(data);var tampered=Sim.new();check(Store.load_game(tampered).is_empty(),"malformed appearance rejected")
 # Parts kit: same seed, same villager; layers combine exactly as tools/portrait_pipeline/kit.py does.
 check(PortraitKit.recipe(31)==PortraitKit.recipe(31) and PortraitKit.recipe(31)!=PortraitKit.recipe(32),"kit recipe deterministic per seed")
 var probe={"head":"head_02","clothing":"clothing_jerkin","beard":"beard_full","hair":"hair_short","hat":"","skin":"#87563e","hair_color":"#29252b","cloth":"#536e97"}
 var drafts=PortraitKit.new(false);var face=drafts.compose(probe)
 check(face!=null and face.get_size()==Vector2i(64,64),"kit composes 64x64 portrait")
 # Pinned in tests/test_assets.py too: GDScript and Python composers must agree byte for byte.
 check(face!=null and sha(face.get_data())=="b246898b2d41ea72a07d425760c8212519e1f898012d8a1862b0d4acb2f15cb7","kit composition matches Python baker")
 var approved_count=0
 for part in PortraitKit.kit().parts:approved_count+=int(part.status=="approved")
 if approved_count==0:check(PortraitKit.new().compose(probe)==null,"unreviewed kit parts never reach the game")
 var newcomer=Sim.new();newcomer.immigration_elapsed=19.95;newcomer.resources.food=999
 for i in range(2):newcomer.build("house",Vector2i(19+i*3,14))
 newcomer.tick(30);check(newcomer.people[newcomer.people.size()-2].appearance.has("head"),"immigrant beyond founders gets a kit appearance")
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
 # Village registry helpers: stable sorting, attitude colours, shortfalls and resource trends.
 var town=Sim.new();var rows=Ledger.citizen_rows(town.people)
 check(rows.size()==24 and rows==range(24),"registry lists villagers in order without the horse")
 var by_name=Ledger.citizen_rows(town.people,"name")
 var names_sorted=true
 for i in range(by_name.size()-1):names_sorted=names_sorted and town.people[by_name[i]].citizen_name.to_lower()<=town.people[by_name[i+1]].citizen_name.to_lower()
 check(names_sorted and by_name.size()==24,"registry sorts by name")
 town.people[3].stamina=5;town.people[8].stamina=99
 var by_vigour=Ledger.citizen_rows(town.people,"stamina",true);check(town.people[by_vigour.back()].stamina==5 and by_vigour.size()==24,"registry sorts by vigour descending")
 town.people[2].state="Sem posto de trabalho";town.people[5].state="Trabalhando";town.people[6].state="Dormindo"
 check(Ledger.mood(town.people[2])=="problem" and Ledger.mood(town.people[5])=="work" and Ledger.mood(town.people[6])=="rest","attitude moods")
 check(town.people[Ledger.citizen_rows(town.people,"state")[0]].state=="Sem posto de trabalho","problems sort first by state")
 check(Ledger.period(7)=="Trabalho" and Ledger.period(12.5)=="Refeição" and Ledger.period(21)=="Descanso","day periods")
 check(Ledger.missing({"wood":25,"stone":5},{"wood":10,"stone":9}).contains("15.0 madeira") and Ledger.missing({"wood":5},{"wood":9}).is_empty(),"build shortfall text")
 town.build("house",Vector2i(19,14));var site=town.buildings.size()-1
 check(Ledger.building_status(town,site)[0].begins_with("Em obra") and Ledger.building_status(town,site)[1]=="move","construction site status")
 var ranks=[]
 for i in Ledger.building_rows(town,"status"):ranks.append(Ledger.MOOD_RANK[Ledger.building_status(town,i)[1]])
 var ordered=ranks.duplicate();ordered.sort();check(ranks==ordered,"buildings sort by status severity")
 check(Ledger.building_rows(town).size()==town.buildings.size(),"building rows cover every building")
 check(Ledger.building_card(town,site).contains("Casa") and Ledger.citizen_card(town,town.people[5]).contains(town.people[5].citizen_name),"quick-info cards")
 var trend=[];Ledger.push_sample(trend,0,{"wood":100.0});Ledger.push_sample(trend,0.5,{"wood":101.0});check(trend.size()==1,"samples are spaced by a second")
 Ledger.push_sample(trend,10,{"wood":110.0});check(absf(Ledger.rates(trend,240).wood-10.0)<0.001,"trend is change per game hour")
 for t in range(11,80):Ledger.push_sample(trend,t,{"wood":110.0})
 check(trend.back()[0]-trend.front()[0]<=Ledger.TREND_WINDOW+1,"trend window is bounded")
 Ledger.push_sample(trend,2,{"wood":0.0});check(trend.size()==1,"trend resets when time goes backwards")
 # Seeded worlds: deterministic, varied, and every starting building reachable on any seed.
 var first=Sim.new({"seed":4242});var again=Sim.new({"seed":4242});var neighbour=Sim.new({"seed":4243})
 check(first.terrain==again.terrain and str(first.buildings)==str(again.buildings) and first.world==again.world,"same seed, same world")
 check(first.terrain!=neighbour.terrain,"different seeds differ")
 check(Sim.new().world.is_empty() and Sim.new().realm_name()=="Vale da Aurora","empty settings keep the classic map")
 check(WorldGen.normalize({"seed":5}).landscape==WorldGen.normalize({"seed":5}).landscape and WorldGen.normalize({"seed":5}).name==WorldGen.name_for(5),"bare seed derives landscape and name")
 check(WorldGen.seed_from_text("123")==123 and WorldGen.seed_from_text("vale")==WorldGen.seed_from_text("vale") and WorldGen.seed_from_text("vale")>=1,"text seeds")
 check(Sim.new({"seed":9,"bounty":"escasso"}).resources.wood==round(180*0.6) and Sim.new({"seed":9,"bounty":"farto"}).resources.gold==round(90*1.6),"starting bounty")
 var fisheries=0;var worlds=0
 for seed in range(1,91):
  var w=Sim.new({"seed":seed*7919,"landscape":WorldGen.LANDSCAPES[seed%3]});worlds+=1
  var ok=w.buildings.size()>=21 and w.village_anchor()==WorldGen.CENTRE and w.people.size()==25
  var water=0
  for cell in w.terrain:
   if w.terrain[cell]=="water":water+=1;ok=ok and WorldGen.ring(cell)>WorldGen.SAFE
  ok=ok and water>=8
  for i in range(w.buildings.size()):
   var site_b=w.buildings[i];var cell=Vector2i(site_b.x,site_b.y)
   ok=ok and w.terrain[cell]=="grass" and w.entrance(i,Vector2(15,15),w.nav).x>=0
   if site_b.kind=="fishery":
    fisheries+=1;var shore=false
    for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:shore=shore or w.terrain.get(cell+offset,"")=="water"
    ok=ok and shore
  for c in w.people:ok=ok and not w.blocked(Vector2i(c.position.round())) and (Vector2i(c.position.round())==WorldGen.CENTRE or not w.nav.path(Vector2i(c.position.round()),WorldGen.CENTRE).is_empty())
  check(ok,"seeded world %d is valid and reachable"%seed)
 check(fisheries>=worlds-2,"fishery finds a shore on nearly every seed (%d/%d)"%[fisheries,worlds])
 var seeded=Sim.new({"seed":777,"landscape":"rio","bounty":"farto","name":"Vale de Teste"});seeded.tick(3)
 check(Store.save_game(seeded)==OK,"save seeded world")
 var reloaded=Sim.new();check(not Store.load_game(reloaded).is_empty(),"load seeded world")
 check(reloaded.terrain==seeded.terrain and reloaded.world==seeded.world and reloaded.realm_name()=="Vale de Teste" and reloaded.buildings.size()==seeded.buildings.size(),"seeded world survives save and load")
 check(Store.summary().name=="Vale de Teste" and Store.summary().seed==777 and Store.summary().population==24,"save summary for the main menu")
 var stored=JSON.parse_string(FileAccess.get_file_as_string(Store.PATH));stored.world.landscape="vulcão";file_json(stored)
 check(Store.load_game(Sim.new()).is_empty(),"invalid world settings rejected")
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(Store.PATH+suffix):DirAccess.remove_absolute(Store.PATH+suffix)
 print("TEST_RESULT assertions=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
