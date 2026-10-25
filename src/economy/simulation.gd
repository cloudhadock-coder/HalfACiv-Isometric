extends RefCounted
const Catalog = preload("res://src/construction/catalog.gd")
const Iso = preload("res://src/world/iso.gd")
var resources: Dictionary = {"food":100.0,"wood":160.0,"stone":100.0,"gold":80.0,"influence":10.0}
var buildings: Array = []
var elapsed: float = 0.0
var tick_count: int = 0
var population: int = 12
var terrain: Dictionary = {}
var offline_seconds: int = 0
func _init() -> void:
 for x in range(Iso.SIZE):
  for y in range(Iso.SIZE):
   var t = "grass"
   if x >= 25 and y > 6: t = "water"
   elif (x < 7 and y > 13) or (y < 5 and x > 6): t = "tree"
   elif ((x>=9 and x<=10 and y>=8 and y<=9) or (x>=20 and x<=22 and y>=21 and y<=23) or (x>=18 and x<=20 and y>=7 and y<=9)):t="tree"
   elif x == 15 or y == 15: t = "road"
   terrain[Vector2i(x,y)] = t
 for entry in [["house",12,12],["house",17,12],["farm",12,17],["farm",13,18],["lumber",8,17],["quarry",20,18],["market",17,17]]:
  buildings.append({"kind":entry[0],"x":entry[1],"y":entry[2],"remaining":0.0,"level":1})
func valid(cell: Vector2i) -> bool:
 return cell.x>=0 and cell.y>=0 and cell.x<Iso.SIZE and cell.y<Iso.SIZE
func building_at(cell: Vector2i) -> int:
 for i in range(buildings.size()):
  if Vector2i(int(buildings[i].x),int(buildings[i].y)) == cell:return i
 return -1
func blocked(cell: Vector2i) -> bool:
 return not valid(cell) or terrain.get(cell,"water") in ["water","tree"] or building_at(cell)>=0
func can_build(kind: String,cell: Vector2i) -> bool:
 if not Catalog.DATA.has(kind) or blocked(cell):return false
 for key in Catalog.DATA[kind].cost:
  if resources[key]<Catalog.DATA[kind].cost[key]:return false
 return true
func build(kind: String,cell: Vector2i) -> bool:
 if not can_build(kind,cell):return false
 for key in Catalog.DATA[kind].cost:resources[key]-=Catalog.DATA[kind].cost[key]
 buildings.append({"kind":kind,"x":cell.x,"y":cell.y,"remaining":float(Catalog.DATA[kind].time),"level":1})
 return true
func tick(seconds: float=1.0) -> void:
 tick_count+=1
 for b in buildings:
  if b.remaining>0:
   b.remaining=maxf(0,b.remaining-seconds)
  else:
   for key in Catalog.DATA[b.kind].production:
    resources[key]+=Catalog.DATA[b.kind].production[key]*seconds*float(b.level)
 resources.food=maxf(0,resources.food-population*0.12*seconds)
 resources.gold+=population*0.015*seconds
 population=4
 for b in buildings:
  if b.kind=="house" and b.remaining<=0:population+=4
func advance(delta: float) -> void:
 elapsed+=delta
 while elapsed>=1.0:
  elapsed-=1.0
  tick()
func apply_offline(seconds: int) -> void:
 offline_seconds=clampi(seconds,0,7200)
 for i in range(offline_seconds):tick()
