extends RefCounted
const Sim=preload("res://src/economy/simulation.gd")
const Citizen=preload("res://src/entities/citizen.gd")
static var PATH: String="user://realm.json"
static func save_game(sim,citizens: Array=[]) -> Error:
 var entries=[]
 var source=sim.people if citizens.is_empty() else citizens
 for c in source:
  entries.append({"x":c.position.x,"y":c.position.y,"kind":c.kind,"portrait":c.portrait_id,"name":c.citizen_name,"horse_only":c.horse_only,"cargo":c.cargo,"stamina":c.stamina,"work_elapsed":c.work_elapsed,"delivered":c.delivered})
 var data={"schema":2,"version":"0.2.0","saved_at":int(Time.get_unix_time_from_system()),"resources":sim.resources,"buildings":sim.buildings,"people":entries,"seconds":sim.seconds,"tick":sim.tick_count,"immigration_elapsed":sim.immigration_elapsed}
 var file=FileAccess.open(PATH+".tmp",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(data));file.close()
 if FileAccess.file_exists(PATH):
  var previous=JSON.new()
  if previous.parse(FileAccess.get_file_as_string(PATH))==OK and previous.data is Dictionary and previous.data.get("schema",0)==1 and not FileAccess.file_exists(PATH+".v0.1.bak"):
   var legacy_error=DirAccess.copy_absolute(PATH,PATH+".v0.1.bak")
   if legacy_error!=OK:return legacy_error
  var error=DirAccess.copy_absolute(PATH,PATH+".bak")
  if error!=OK:return error
 return DirAccess.rename_absolute(PATH+".tmp",PATH)
static func numeric(value) -> bool:
 return (value is float or value is int) and is_finite(float(value))
static func amount_map(value,allowed: Dictionary) -> bool:
 if not value is Dictionary:return false
 for key in value:
  if not allowed.has(key) or not numeric(value[key]) or value[key]<0:return false
 return true
static func load_game(sim) -> Dictionary:
 if not FileAccess.file_exists(PATH):return {}
 var parser=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(PATH))!=OK:return {}
 var data=parser.data
 if not data is Dictionary or (data.get("schema",0)!=1 and data.get("schema",0)!=2):return {}
 var legacy=data.schema==1
 var candidate=Sim.new()
 if not amount_map(data.get("resources"),candidate.resources):return {}
 for key in candidate.resources:
  if not data.resources.has(key):return {}
 if not data.get("buildings") is Array or data.buildings.size()>1024:return {}
 var occupied={};var normalized=[]
 for b in data.buildings:
  if not b is Dictionary or not b.has_all(["kind","x","y","remaining","level"]):return {}
  if not b.kind is String or not candidate.Catalog.DATA.has(b.kind):return {}
  for key in ["x","y","remaining","level"]:
   if not numeric(b[key]):return {}
  var cell=Vector2i(int(b.x),int(b.y))
  if not candidate.valid(cell) or b.x!=int(b.x) or b.y!=int(b.y) or b.remaining<0 or b.remaining>10000 or b.level<1 or b.level>10:return {}
  if occupied.has(cell) or candidate.terrain.get(cell)=="water":return {}
  if candidate.terrain.get(cell)=="tree":
   if not legacy:return {}
   candidate.terrain[cell]="grass"
  var stored=b.get("stored",{})
  if not amount_map(stored,candidate.resources):return {}
  var copy=candidate.Catalog.make(b.kind,cell,float(b.remaining));copy.level=int(b.level);copy.stored=stored.duplicate(true)
  normalized.append(copy);occupied[cell]=true
 if not data.get("people",[]) is Array or data.get("people",[]).size()>129:return {}
 if not legacy and data.get("people",[]).is_empty():return {}
 var restored=[];var horses=0
 for i in range(data.get("people",[]).size()):
  var person=data.people[i]
  if not person is Dictionary or not person.has_all(["x","y"]):return {}
  if not numeric(person.x) or not numeric(person.y):return {}
  var point=Vector2(float(person.x),float(person.y))
  if point.x<0 or point.y<0 or point.x>31 or point.y>31:return {}
  var kind=person.get("kind",i%24)
  if not numeric(kind) or kind<0 or kind>=24 or kind!=int(kind):return {}
  if not person.get("horse_only",false) is bool:return {}
  var cargo=person.get("cargo",{})
  if not amount_map(cargo,candidate.resources):return {}
  for key in ["stamina","work_elapsed","delivered","portrait"]:
   if person.has(key) and not numeric(person[key]):return {}
  if person.get("stamina",100)<0 or person.get("stamina",100)>100 or person.get("work_elapsed",0)<0:return {}
  if person.get("portrait",kind)<0 or person.get("portrait",kind)>=24 or person.get("delivered",0)<0:return {}
  if not person.get("name","") is String or person.get("name","").length()>80:return {}
  var citizen=Citizen.new(int(kind),Vector2i(point.round()))
  citizen.horse_only=person.get("horse_only",false);citizen.position=point.round();citizen.previous=citizen.position
  if citizen.horse_only:horses+=1
  if horses>1:return {}
  if not person.get("name","").is_empty():citizen.citizen_name=person.name
  citizen.cargo=cargo.duplicate(true);citizen.stamina=float(person.get("stamina",100));citizen.work_elapsed=float(person.get("work_elapsed",0));citizen.delivered=int(person.get("delivered",0));citizen.portrait_id=int(person.get("portrait",kind))
  restored.append(citizen)
 for key in ["saved_at","tick","seconds","immigration_elapsed"]:
  if data.has(key) and not numeric(data[key]):return {}
 if data.get("tick",0)<0 or data.get("seconds",0)<0:return {}
 candidate.buildings=normalized;candidate.resources=data.resources.duplicate(true);candidate.nav.rebuild(candidate)
 if not restored.is_empty():candidate.people=restored
 # Keep the horse last so immigration has a stable insertion point.
 var ordered=[]
 for citizen in candidate.people:
  if not citizen.horse_only:ordered.append(citizen)
 for citizen in candidate.people:
  if citizen.horse_only:ordered.append(citizen)
 candidate.people=ordered
 if not candidate.people.any(func(c):return c.horse_only):
  var horse=Citizen.new(0,Vector2i(15,15));horse.horse_only=true;horse.citizen_name="Castanha";candidate.people.append(horse)
 for person in candidate.people:
  var anchor=candidate.village_anchor()
  if anchor.x<0:return {}
  var start=Vector2i(person.position.round())
  if candidate.blocked(start) or (start!=anchor and candidate.nav.path(start,anchor).is_empty()):person.position=Vector2(anchor);person.previous=person.position
 candidate.seconds=float(data.get("seconds",data.get("tick",0)));candidate.tick_count=int(candidate.seconds);candidate.immigration_elapsed=float(data.get("immigration_elapsed",0));candidate.population=candidate.people.size()-1
 candidate.reassign_jobs()
 candidate.apply_offline(int(Time.get_unix_time_from_system())-int(data.get("saved_at",Time.get_unix_time_from_system())))
 # Commit only after complete validation; malformed saves leave the live game untouched.
 sim.resources=candidate.resources;sim.buildings=candidate.buildings;sim.people=candidate.people;sim.terrain=candidate.terrain;sim.seconds=candidate.seconds;sim.tick_count=candidate.tick_count;sim.elapsed=0;sim.population=candidate.population;sim.immigration_elapsed=candidate.immigration_elapsed;sim.offline_seconds=candidate.offline_seconds
 sim.nav.rebuild(sim);sim.reassign_jobs();sim.revision+=1
 data["migrated"]=legacy
 return data
