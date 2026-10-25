extends RefCounted
var position: Vector2
var route: Array[Vector2i]=[]
var kind: int=0
var citizen_name: String
var state: String="Descansando"
var clock: float=0
var wait: float=0
var mounted: bool=false
var horse_only: bool=false
var home: Vector2i
var workplace: Vector2i
var going_to_work: bool=true
func _init(index: int,cell: Vector2i) -> void:
 kind=index%12
 citizen_name=["Aldric","Elena","Borin","Darin","Edwin","Farid","Gareth","Hector","Ivar","Jonas","Klara","Lucian"][kind]
 position=Vector2(cell)
 home=cell
 workplace=Vector2i(15,19+(index%4))
 mounted=index==7
 horse_only=index==12
 wait=float(index)*0.25
func update(delta: float,nav) -> void:
 clock+=delta
 if route.is_empty():
  wait-=delta
  if wait<=0:
   var target=workplace if going_to_work else home
   route=nav.path(Vector2i(position.round()),target)
   going_to_work=not going_to_work
   wait=3.0+kind*0.3
   if not route.is_empty():route.pop_front()
  state="Trabalhando" if not going_to_work else "Descansando"
 else:
  state="Patrulhando" if mounted else "Caminhando"
  var goal=Vector2(route[0])
  position=position.move_toward(goal,delta*(1.5 if mounted else 0.9))
  if position.distance_to(goal)<0.01:route.pop_front()
