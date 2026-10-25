extends RefCounted
const Company=preload("res://src/entities/company.gd")
const Professions=preload("res://src/entities/professions.gd")
var specialist: String=""
var equipment: Dictionary={"coat":0,"color":0,"armor":false,"banner":false,"gait":0}
var position: Vector2
var previous: Vector2
var route: Array[Vector2i]=[]
var kind: int=0
var portrait_id: int=0
var appearance: Dictionary={}  # parts-kit recipe (src/ui/portrait_kit.gd); empty for the 24 founders
var citizen_name: String
var state: String="Descansando"
var task: String="rest"
var clock: float=0
var work_elapsed: float=0
var wait: float=0
var mounted: bool=false
var horse_only: bool=false
var home: Vector2i
var workplace: Vector2i
var employer: int=-1
var cargo: Dictionary={}
var delivered: int=0
var stamina: float=100
var patrol_index: int=0
var destination: Vector2i=Vector2i(-1,-1)
var arriving: String="rest"
func _init(index: int,cell: Vector2i) -> void:
 kind=index%24;portrait_id=kind;citizen_name=Professions.NAMES[kind]
 position=Vector2(cell);previous=position;home=cell;workplace=cell
 mounted=kind==7
 wait=float(index%5)*0.3
func travel(target: Vector2i,next_task: String,nav) -> bool:
 if Vector2i(position.round())==target and position.distance_to(Vector2(target))<0.05:
  task=next_task;destination=target;route.clear();return true
 var found=nav.path(Vector2i(position.round()),target)
 if found.is_empty():state="Caminho bloqueado";wait=2;return false
 route=found
 if position.distance_to(Vector2(route[0]))<0.05:route.pop_front()
 destination=target;arriving=next_task;task="travel"
 return true
func update(delta: float,nav,sim=null) -> void:
 previous=position;clock+=delta;wait=maxf(0,wait-delta)
 if sim==null:return
 if not route.is_empty():
  state="Transportando recursos" if not cargo.is_empty() else ("Patrulhando" if Professions.patrol(kind) else "A caminho")
  var target=Vector2(route[0]);position=position.move_toward(target,delta*nav.speed_factor(Vector2i(position.round()))*(1.65*[1.0,1.3,1.65][equipment.gait] if mounted or horse_only else 1.15)*(1.0+Company.bonus(self) if mounted else 1.0))
  if position.distance_to(target)<0.001:route.pop_front()
  if route.is_empty():task=arriving;wait=0
  stamina=maxf(0,stamina-delta*0.12)
  return
 if task=="deliver":
  for key in cargo:sim.resources[key]+=cargo[key]
  cargo.clear();delivered+=1;task="rest";wait=0
 if not cargo.is_empty():
  travel(sim.dropoff(position,nav),"deliver",nav);return
 if horse_only:
  state="Descansando no estábulo"
  if wait<=0 and task!="horse_rest":travel(sim.stable_entrance(nav),"horse_rest",nav)
  return
 var hour=sim.hour()
 if hour>=20 or hour<6 or stamina<15 or (task=="sleep" and stamina<80):
  state="Dormindo" if hour>=20 or hour<6 else "Recuperando forças"
  if position.distance_to(Vector2(home))>0.1:
   if wait<=0:travel(home,"sleep",nav)
  else:task="sleep";stamina=minf(100,stamina+delta*3)
  return
 if hour>=12 and hour<13:
  state="Fazendo refeição"
  var table=sim.meeting_entrance(nav)
  if position.distance_to(Vector2(table))>0.1:
   if wait<=0:travel(table,"meal",nav)
  else:task="meal";stamina=minf(100,stamina+delta*2)
  return
 if kind==4:
  var site=sim.nearest_site(position,nav)
  if site>=0:
   var entrance=sim.entrance(site,position,nav)
   if position.distance_to(Vector2(entrance))>0.1:travel(entrance,"build",nav)
   else:
    task="build";state="Erguendo construção";sim.buildings[site].remaining=maxf(0.00001,sim.buildings[site].remaining-delta*0.8)
   return
 if Professions.patrol(kind):
  var points=[Vector2i(15,10),Vector2i(21,15),Vector2i(15,22),Vector2i(10,15)]
  state="Vigiando a aldeia"
  if wait<=0:
   travel(points[patrol_index%4]+sim.centre()-Vector2i(15,15),"patrol",nav);patrol_index+=1;wait=4
  return
 if kind==22:
  state="Organizando o depósito"
  var stash=sim.nearest_stash(position,nav)
  if stash>=0:
   var entrance=sim.entrance(stash,position,nav)
   if position.distance_to(Vector2(entrance))>0.1:travel(entrance,"collect",nav)
   else:cargo=sim.take_cargo(stash);task="rest"
  else:task="rest"
  return
 if employer<0 or employer>=sim.buildings.size():state="Sem posto de trabalho";task="rest";return
 var b=sim.buildings[employer]
 if b.remaining>0:state="Aguardando a obra";return
 var entrance=sim.entrance(employer,position,nav)
 if entrance.x<0:state="Posto sem acesso";wait=2;return
 workplace=entrance
 if position.distance_to(Vector2(entrance))>0.1:
  if wait<=0:travel(entrance,"work",nav)
  return
 task="work";state="Trabalhando";stamina=maxf(0,stamina-delta*0.22)
 if not sim.work(employer,delta*(1.0+Company.bonus(self))):state="Aguardando insumos"
 work_elapsed+=delta
 if work_elapsed>=6:
  work_elapsed=0;cargo=sim.take_cargo(employer)
