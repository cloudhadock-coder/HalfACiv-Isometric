extends RefCounted
const Catalog=preload("res://src/construction/catalog.gd")
const Company=preload("res://src/entities/company.gd")
const Iso=preload("res://src/world/iso.gd")
const Citizen=preload("res://src/entities/citizen.gd")
const Professions=preload("res://src/entities/professions.gd")
const Navigation=preload("res://src/world/navigation.gd")
const PortraitKit=preload("res://src/ui/portrait_kit.gd")
const WorldGen=preload("res://src/world/world_gen.gd")
const Realm=preload("res://src/politics/realm.gd")
var politics=Realm.new()
const STEP=0.1
const DAY_SECONDS=240.0
var resources: Dictionary={"food":160.0,"wood":180.0,"stone":120.0,"gold":90.0,"influence":10.0}
var buildings: Array=[]
var people: Array=[]
var elapsed: float=0
var seconds: float=0
var tick_count: int=0
var population: int=24
var immigration_elapsed: float=0
var terrain: Dictionary={}
var offline_seconds: int=0
var revision: int=0
var nav=Navigation.new()
var jobs: Dictionary={}
# Seeded world settings (see world_gen.gd); empty for the classic map.
var world: Dictionary={}
var terrain_edits: Dictionary={}
func _init(settings: Dictionary={}) -> void:
 if not settings.is_empty():
  var made=WorldGen.generate(settings);world=made.world;terrain=made.terrain
  for entry in made.buildings:buildings.append(Catalog.make(entry[0],Vector2i(entry[1],entry[2])))
  for key in ["food","wood","stone","gold"]:resources[key]=round(resources[key]*WorldGen.BOUNTY_FACTOR[world.bounty])
  populate(made.horse);return
 var classic=WorldGen.classic_data();terrain=classic.terrain
 for entry in classic.buildings:buildings.append(Catalog.make(entry[0],Vector2i(entry[1],entry[2])))
 populate(classic.horse)
func map_size() -> int:return int(world.get("size",32))
func centre() -> Vector2i:return Vector2i.ONE*(map_size()/2-1)
func populate(horse_cell: Vector2i) -> void:
 nav.rebuild(self)
 for i in range(24):
  var cell=Vector2i(15,6+i%18)+centre()-Vector2i(15,15)
  people.append(Citizen.new(i,cell))
 var horse=Citizen.new(0,horse_cell);horse.horse_only=true;horse.citizen_name="Castanha";people.append(horse)
 reassign_jobs()
func realm_name() -> String:
 return world.get("name","Vale da Aurora")
func valid(cell: Vector2i) -> bool:
 return cell.x>=0 and cell.y>=0 and cell.x<map_size() and cell.y<map_size()
func building_at(cell: Vector2i) -> int:
 for i in range(buildings.size()):
  if Vector2i(int(buildings[i].x),int(buildings[i].y))==cell:return i
 return -1
func blocked(cell: Vector2i) -> bool:
 return not valid(cell) or terrain.get(cell,"water") in ["water","tree"] or building_at(cell)>=0
func placement_reason(kind: String,cell: Vector2i) -> String:
 if buildings.size()>=1024:return "Limite de 1024 construções atingido"
 if not Catalog.DATA.has(kind):return "Construção desconhecida"
 if blocked(cell):return "Terreno ocupado ou impróprio"
 if cell==village_anchor():return "Preserve o acesso à praça"
 for person in people:
  if cell==Vector2i(person.position.floor()) or cell==Vector2i(person.position.ceil()):return "Aguarde a passagem do habitante"
 if kind=="fishery":
  var shore=false
  for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   if terrain.get(cell+offset,"")=="water":shore=true
  if not shore:return "O pesqueiro exige margem de água"
 var accessible=false
 for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
  if not blocked(cell+offset):accessible=true
 if not accessible:return "Deixe ao menos um acesso livre"
 for key in Catalog.DATA[kind].cost:
  if resources[key]<Catalog.DATA[kind].cost[key]:return "Falta "+Catalog.RESOURCE_NAMES[key]
 return ""
func can_build(kind: String,cell: Vector2i) -> bool:return placement_reason(kind,cell).is_empty()
func build(kind: String,cell: Vector2i) -> bool:
 if not can_build(kind,cell):return false
 # A new obstacle may not isolate an existing door or cut a worker off from the village.
 var anchor=village_anchor()
 var previous_access=[]
 for i in range(buildings.size()):
  if entrance(i,Vector2(anchor),nav).x>=0:previous_access.append(i)
 var probe=Catalog.make(kind,cell,float(Catalog.DATA[kind].time))
 buildings.append(probe);nav.change_cell(self,cell)
 var reachable=true
 previous_access.append(buildings.size()-1)
 for i in previous_access:
  if entrance(i,Vector2(anchor),nav).x<0:reachable=false;break
 if reachable:
  for person in people:
   var start=Vector2i(person.position.round())
   if start!=anchor and nav.path(start,anchor).is_empty():reachable=false;break
 if not reachable:buildings.pop_back();nav.change_cell(self,cell);return false
 for key in Catalog.DATA[kind].cost:resources[key]-=Catalog.DATA[kind].cost[key]
 for person in people:
  person.previous=person.position;person.route.clear();person.task="rest"
 revision+=1;reassign_jobs();return true
func entrance(index: int,from: Vector2,navigation) -> Vector2i:
 if index<0 or index>=buildings.size():return Vector2i(-1,-1)
 var b=buildings[index];var cell=Vector2i(int(b.x),int(b.y));var candidates: Array=[]
 for offset in [Vector2i(0,1),Vector2i(1,0),Vector2i(-1,0),Vector2i(0,-1)]:
  var c=cell+offset
  if not blocked(c):candidates.append(c)
 candidates.sort_custom(func(a,b):return from.distance_squared_to(Vector2(a))<from.distance_squared_to(Vector2(b)))
 for c in candidates:
  if Vector2i(from.round())==c or not navigation.path(Vector2i(from.round()),c).is_empty():return c
 return Vector2i(-1,-1)
func village_anchor() -> Vector2i:
 var centre=centre()
 if not blocked(centre):return centre
 for radius in range(1,map_size()):
  for x in range(-radius,radius+1):
   for y in [-radius,radius]:
    if not blocked(centre+Vector2i(x,y)):return centre+Vector2i(x,y)
  for y in range(-radius+1,radius):
   for x in [-radius,radius]:
    if not blocked(centre+Vector2i(x,y)):return centre+Vector2i(x,y)
 return Vector2i(-1,-1)
func nearest_kind(kinds: Array,from: Vector2) -> int:
 var best=-1;var distance=INF
 for i in range(buildings.size()):
  var b=buildings[i]
  if b.kind in kinds and b.remaining<=0:
   var d=from.distance_squared_to(Vector2(b.x,b.y))
   if d<distance:best=i;distance=d
 return best
func nearest_site(from: Vector2,navigation) -> int:
 for i in range(buildings.size()):
  if buildings[i].remaining>0 and entrance(i,from,navigation).x>=0:return i
 return -1
func nearest_stash(from: Vector2,navigation) -> int:
 var best=-1;var distance=INF
 for i in range(buildings.size()):
  var amount=0.0
  for value in buildings[i].stored.values():amount+=value
  var d=from.distance_squared_to(Vector2(buildings[i].x,buildings[i].y))
  if amount>=2 and d<distance and entrance(i,from,navigation).x>=0:best=i;distance=d
 return best
func destination_for(kinds: Array,from: Vector2,navigation) -> Vector2i:
 var best=-1;var distance=INF;var target=centre()
 for i in range(buildings.size()):
  if buildings[i].kind in kinds and buildings[i].remaining<=0:
   var e=entrance(i,from,navigation)
   if e.x>=0 and from.distance_squared_to(Vector2(e))<distance:best=i;distance=from.distance_squared_to(Vector2(e));target=e
 if best<0:
  if blocked(target):return village_anchor()
 return target
func dropoff(from: Vector2,navigation) -> Vector2i:return destination_for(["warehouse","market"],from,navigation)
func stable_entrance(navigation) -> Vector2i:return destination_for(["stable"],Vector2(centre()),navigation)
func meeting_entrance(navigation) -> Vector2i:return destination_for(["tavern","market"],Vector2(centre()),navigation)
func reassign_jobs() -> void:
 jobs.clear()
 for person in people:
  person.employer=-1
  person.home=destination_for(["house"],person.position,nav)
  if person.horse_only:continue
  var choices: Array=[]
  for i in range(buildings.size()):
   var b=buildings[i];var slots=int(Catalog.DATA[b.kind].slots)
   if b.kind in Professions.DATA[person.kind].jobs and b.remaining<=0 and jobs.get(i,0)<slots and entrance(i,person.position,nav).x>=0:choices.append(i)
  choices.sort_custom(func(a,b):return person.position.distance_squared_to(Vector2(buildings[a].x,buildings[a].y))<person.position.distance_squared_to(Vector2(buildings[b].x,buildings[b].y)))
  if not choices.is_empty():
   person.employer=choices[0];jobs[person.employer]=jobs.get(person.employer,0)+1
func set_profession(index: int,kind: int) -> bool:
 if index<0 or index>=people.size() or kind<0 or kind>=24 or people[index].horse_only:return false
 var person=people[index];person.kind=kind;person.mounted=kind==7
 person.route.clear();person.previous=person.position;person.task="rest"
 reassign_jobs();return true
func work(index: int,delta: float) -> bool:
 var b=buildings[index];var data=Catalog.DATA[b.kind];var factor=delta/float(maxi(1,data.slots))*float(b.level)
 for key in data.get("inputs",{}):
  if resources[key]<data.inputs[key]*factor:return false
 for key in data.get("inputs",{}):resources[key]=maxf(0,resources[key]-data.inputs[key]*factor)
 for key in data.production:b.stored[key]=b.stored.get(key,0.0)+data.production[key]*factor*politics.production_multiplier(key)
 return true
func take_cargo(index: int) -> Dictionary:
 var cargo={};var capacity=12.0
 for key in buildings[index].stored:
  var amount=minf(buildings[index].stored[key],capacity)
  if amount>0.01:cargo[key]=amount;buildings[index].stored[key]-=amount;capacity-=amount
 return cargo
func hour() -> float:return fmod(6.0+seconds/DAY_SECONDS*24.0,24.0)
func day() -> int:return 1+int(seconds/DAY_SECONDS)
func housing_capacity() -> int:
 var capacity=4
 for b in buildings:
  if b.kind=="house" and b.remaining<=0:capacity+=4
 return capacity
func active_workers(index: int) -> int:
 var count=0
 for person in people:
  if person.employer==index and person.task=="work" and person.route.is_empty():count+=1
 return count
func tick(delta: float=1.0) -> void:
 var remaining=delta
 while remaining>0.00001:
  var dt=minf(STEP,remaining);remaining-=dt;seconds+=dt
  var finished=false
  for b in buildings:
   if b.remaining>0:
    b.remaining=maxf(0,b.remaining-dt)
    if b.remaining==0:finished=true
  if finished:revision+=1;reassign_jobs()
  for person in people:
   person.update(dt,nav,self)
   if not person.horse_only and Professions.patrol(person.kind) and person.employer>=0 and hour()>=6 and hour()<20:
    var data=Catalog.DATA[buildings[person.employer].kind]
    resources.influence+=data.production.get("influence",0.0)*politics.production_multiplier("influence")*dt/float(maxi(1,data.slots))
  resources.food=maxf(0,resources.food-population*0.035*dt)
  resources.gold+=population*0.006*dt*politics.tax_multiplier()
  population=people.size()-1
  immigration_elapsed+=dt
  if immigration_elapsed>=20:
   immigration_elapsed=0
   if population<housing_capacity() and population<64 and resources.food>=30:
    var cell=dropoff(Vector2(centre()),nav)
    var newcomer=Citizen.new(population,cell)
    if population>=24:newcomer.citizen_name+=" "+str(1+population/24);newcomer.appearance=PortraitKit.recipe(population)
    people.insert(people.size()-1,newcomer);reassign_jobs();population+=1
 tick_count=int(seconds+0.0001)
func advance(delta: float) -> void:
 elapsed+=delta
 while elapsed+0.000001>=STEP:
  elapsed-=STEP;tick(STEP)
func apply_offline(duration: int) -> void:
 offline_seconds=clampi(duration,0,7200)
 # Economic approximation only: no NPC travel, cargo delivery, political decisions or visual events.
 for _second in range(offline_seconds):
  seconds+=1
  var completed=false
  for b in buildings:
   if b.remaining>0:
    b.remaining=maxf(0,b.remaining-1)
    if b.remaining==0:completed=true
  if completed:reassign_jobs()
  if hour()>=6 and hour()<20 and not (hour()>=12 and hour()<13):
   for index in jobs:
    var b=buildings[index]
    if b.remaining>0:continue
    var data=Catalog.DATA[b.kind];var weight=0.0
    for c in people:
     if c.employer==index:weight+=1.0+(Company.bonus(c) if c.kind!=7 else 0.0)
    var factor=weight/float(maxi(1,data.slots))*0.55
    var enough=true
    for key in data.get("inputs",{}):
     if resources[key]<data.inputs[key]*factor:enough=false
    if enough:
     for key in data.get("inputs",{}):resources[key]-=data.inputs[key]*factor
     for key in data.production:resources[key]+=data.production[key]*factor*politics.production_multiplier(key)
  resources.food=maxf(0,resources.food-population*0.035);resources.gold+=population*0.006*politics.tax_multiplier()
 tick_count=int(seconds);reassign_jobs()

func road_reason(cell: Vector2i,erase: bool=false) -> String:
 if not valid(cell) or building_at(cell)>=0:return "Terreno ocupado ou fora do mapa"
 if terrain[cell] in ["tree","water"]:return "Estradas exigem solo livre; não atravessam água ou floresta"
 if erase and terrain[cell]!="road":return "Não há estrada neste tile"
 if not erase and terrain[cell]=="road":return "Estrada já existente"
 if not erase and resources.stone<1:return "Falta 1 pedra"
 return ""
func edit_road(cell: Vector2i,erase: bool=false) -> bool:
 if not road_reason(cell,erase).is_empty():return false
 if not erase:resources.stone-=1
 terrain[cell]="dirt" if erase else "road";terrain_edits[cell]=terrain[cell]
 nav.change_cell(self,cell);revision+=1
 for c in people:c.route.clear();c.previous=c.position;c.task="rest"
 return true
func expansion_reason() -> String:
 if map_size()>=64:return "O domínio já tem 64×64 tiles"
 if resources.gold<150 or resources.influence<25:return "Ampliar exige 150 ouro e 25 influência"
 return ""
func expand() -> bool:
 if not expansion_reason().is_empty():return false
 var old_size=map_size();var settings=world.duplicate()
 if settings.is_empty():settings={"seed":1,"landscape":"lagos","bounty":"normal","name":realm_name(),"base":"classic"}
 settings["size"]=old_size+16
 var made=WorldGen.generate(settings);var offset=Vector2i(8,8);var shifted={}
 for cell in terrain:
  var dest=cell+offset
  if made.terrain[dest]!=terrain[cell]:shifted[dest]=terrain[cell]
 for cell in shifted:made.terrain[cell]=shifted[cell]
 terrain=made.terrain;terrain_edits=shifted;world=made.world
 for b in buildings:b.x+=8;b.y+=8
 for c in people:
  c.position+=Vector2(offset);c.previous+=Vector2(offset);c.route.clear();c.home+=offset;c.workplace+=offset;c.destination+=offset;c.task="rest"
 resources.gold-=150;resources.influence-=25
 nav.rebuild(self);reassign_jobs();revision+=1;return true
