extends RefCounted
static var PATH: String="user://realm.json"
static func save_game(sim,citizens: Array) -> Error:
 var people=[]
 for c in citizens:people.append({"x":c.position.x,"y":c.position.y,"kind":c.kind,"mounted":c.mounted,"horse_only":c.horse_only})
 var data={"schema":1,"saved_at":int(Time.get_unix_time_from_system()),"resources":sim.resources,"buildings":sim.buildings,"people":people,"tick":sim.tick_count}
 var f=FileAccess.open(PATH+".tmp",FileAccess.WRITE)
 if f==null:return FileAccess.get_open_error()
 f.store_string(JSON.stringify(data))
 f.close()
 if FileAccess.file_exists(PATH):
  var err=DirAccess.copy_absolute(PATH,PATH+".bak")
  if err!=OK:return err
 return DirAccess.rename_absolute(PATH+".tmp",PATH)
static func numeric(value) -> bool:
 return (value is float or value is int) and is_finite(float(value))
static func load_game(sim) -> Dictionary:
 if not FileAccess.file_exists(PATH):return {}
 var parser=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(PATH))!=OK:return {}
 var data=parser.data
 if not data is Dictionary or data.get("schema",0)!=1:return {}
 if not data.get("resources") is Dictionary or not data.get("buildings") is Array:return {}
 for key in sim.resources:
  if not data.resources.has(key) or not numeric(data.resources[key]) or data.resources[key]<0:return {}
 var occupied={}
 for b in data.buildings:
  if not b is Dictionary:return {}
  if not b.has_all(["kind","x","y","remaining","level"]):return {}
  if not b.kind is String or not sim.Catalog.DATA.has(b.kind):return {}
  for key in ["x","y","remaining","level"]:
   if not numeric(b[key]):return {}
  if not sim.valid(Vector2i(int(b.x),int(b.y))) or b.x!=int(b.x) or b.y!=int(b.y) or b.remaining<0 or b.level<1:return {}
  var cell=Vector2i(int(b.x),int(b.y))
  if occupied.has(cell) or sim.terrain.get(cell,"water") in ["water","tree"]:return {}
  occupied[cell]=true
 if not data.get("people",[]) is Array:return {}
 for person in data.get("people",[]):
  if not person is Dictionary or not person.has_all(["x","y"]):return {}
  if not numeric(person.x) or not numeric(person.y) or not sim.valid(Vector2i(int(person.x),int(person.y))):return {}
 if not numeric(data.get("saved_at",0)) or not numeric(data.get("tick",0)):return {}
 sim.resources=data.resources.duplicate(true)
 sim.buildings=data.buildings.duplicate(true)
 sim.tick_count=int(data.get("tick",0))
 sim.apply_offline(int(Time.get_unix_time_from_system())-int(data.get("saved_at",Time.get_unix_time_from_system())))
 return data
