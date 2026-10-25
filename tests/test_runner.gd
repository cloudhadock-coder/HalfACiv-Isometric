extends SceneTree
const Sim=preload("res://src/economy/simulation.gd")
const Iso=preload("res://src/world/iso.gd")
const Nav=preload("res://src/world/navigation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Citizen=preload("res://src/entities/citizen.gd")
var checks: int=0
var failures: int=0
func check(value: bool,label: String) -> void:
 checks+=1
 if not value:failures+=1;push_error("FAIL: "+label)
func _init() -> void:
 for x in range(32):
  for y in range(32):check(Iso.tile(Iso.project(Vector2(x,y)))==Vector2i(x,y),"iso roundtrip")
 var s=Sim.new();var food=s.resources.food;s.tick();check(s.resources.food>food,"production minus consumption")
 var wood=s.resources.wood
 check(s.build("house",Vector2i(19,14)),"construct valid")
 check(s.resources.wood==wood-25,"deduct cost once")
 check(not s.build("house",Vector2i(19,14)),"reject overlap")
 check(not s.build("house",Vector2i(26,20)),"reject water")
 s.tick(8);check(s.buildings.back().remaining==0,"finish construction")
 s.tick();check(s.population==16,"population grows after house")
 s.resources.wood=0;check(not s.build("house",Vector2i(20,14)),"reject unaffordable")
 var nav=Nav.new();nav.rebuild(s)
 var path=nav.path(Vector2i(14,12),Vector2i(16,18));check(not path.is_empty(),"find route")
 for c in path:check(not s.blocked(c),"route avoids obstacles")
 var citizen=Citizen.new(2,Vector2i(14,12))
 for i in range(1800):
  citizen.update(1.0/60.0,nav)
  check(not s.blocked(Vector2i(citizen.position.round())),"moving citizen avoids obstacle")
 var a=Sim.new();var b=Sim.new();a.apply_offline(100000);check(a.offline_seconds==7200,"offline cap")
 for i in range(7200):b.tick()
 check(a.resources==b.resources,"offline deterministic")
 var timed=Sim.new();timed.advance(0.3);timed.advance(0.7);check(timed.tick_count==1,"delta accumulator")
 var starving=Sim.new();starving.buildings.clear();starving.resources.food=0;starving.tick();check(starving.resources.food==0,"food never negative")
 Store.PATH="res://tests/realm-test.json"
 check(Store.save_game(s,[])==OK,"save atomic")
 var loaded=Sim.new();var data=Store.load_game(loaded)
 check(not data.is_empty(),"load schema")
 check(loaded.buildings.size()==s.buildings.size(),"save buildings")
 var f=FileAccess.open(Store.PATH,FileAccess.WRITE);f.store_string("{broken");f.close()
 check(Store.load_game(loaded).is_empty(),"reject corrupted save")
 var invalid=Sim.new()
 var invalid_file=FileAccess.open(Store.PATH,FileAccess.WRITE)
 invalid_file.store_string(JSON.stringify({"schema":1,"resources":invalid.resources,"buildings":[{"kind":"house","x":"bad","y":2,"remaining":0,"level":1}]}));invalid_file.close()
 check(Store.load_game(loaded).is_empty(),"reject bad building types")
 var bad_person=FileAccess.open(Store.PATH,FileAccess.WRITE)
 bad_person.store_string(JSON.stringify({"schema":1,"resources":invalid.resources,"buildings":[],"people":[{"x":null,"y":1}]}));bad_person.close()
 check(Store.load_game(loaded).is_empty(),"reject bad person types")
 DirAccess.remove_absolute(Store.PATH)
 for i in range(12):check(ResourceLoader.exists("res://assets/characters/"+str(i)+".png"),"character atlas")
 print("TEST_RESULT assertions=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
