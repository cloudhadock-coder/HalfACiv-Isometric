extends RefCounted
# Stable specialist IDs; each unique contract reuses the matching founder identity.
const COLORS=["Vermelho","Azul","Verde","Amarelo","Roxo","Preto"]
const COATS=["Castanho","Preto","Branco","Cinza","Marrom"]
const OFFERS=[
 {"id":"hector","portrait":7,"kind":7,"name":"Hector","specialty":"Cavalaria · patrulha montada","cost":55,"bonus":0.20,"description":"+20% de velocidade de deslocamento"},
 {"id":"ulric","portrait":16,"kind":16,"name":"Ulric","specialty":"Mestre ferreiro","cost":45,"bonus":0.25,"description":"+25% de produção e insumos no próprio posto"},
 {"id":"beatriz","portrait":15,"kind":15,"name":"Beatriz","specialty":"Mestra padeira","cost":35,"bonus":0.25,"description":"+25% de produção e insumos no próprio posto"},
 {"id":"oswin","portrait":13,"kind":13,"name":"Oswin","specialty":"Pescador experiente","cost":30,"bonus":0.25,"description":"+25% de produção no próprio posto"}
]
static func offer(id: String) -> Dictionary:
 for entry in OFFERS:
  if entry.id==id:return entry
 return {}
static func valid_equipment(value) -> bool:
 if not value is Dictionary:return false
 for key in value:
  if key not in ["coat","color","armor","banner","gait"]:return false
  if key in ["armor","banner"]:
   if not value[key] is bool:return false
  else:
   if not value[key] is int and not value[key] is float:return false
   var limit=5 if key=="coat" else (6 if key=="color" else 3)
   if value[key]!=int(value[key]) or value[key]<0 or value[key]>=limit:return false
 return true
static func reason(sim,id: String) -> String:
 var data=offer(id)
 if data.is_empty():return "Contrato desconhecido"
 for c in sim.people:
  if c.specialist==id:return "Especialista já contratado"
 if sim.resources.gold<data.cost:return "Ouro insuficiente"
 # Existing named residents can receive a contract without consuming another bed.
 if not sim.people.any(func(c):return not c.horse_only and c.portrait_id==data.portrait) and sim.population>=sim.housing_capacity():return "Construa uma casa para receber o especialista"
 if data.kind==7 and sim.nearest_kind(["stable"],Vector2(15,15))<0:return "Conclua um estábulo"
 return ""
static func recruit(sim,id: String) -> bool:
 if not reason(sim,id).is_empty():return false
 var data=offer(id);var person
 for c in sim.people:
  if not c.horse_only and c.portrait_id==data.portrait:person=c;break
 if person==null:
  person=load("res://src/entities/citizen.gd").new(data.kind,sim.village_anchor())
  person.citizen_name=data.name;person.portrait_id=data.portrait
  sim.people.insert(sim.people.size()-1,person);sim.population+=1
 person.specialist=id;person.kind=data.kind;person.mounted=data.kind==7
 person.route.clear();person.previous=person.position;person.task="rest"
 sim.resources.gold-=data.cost;sim.reassign_jobs();return true
static func bonus(c) -> float:
 var data=offer(c.specialist)
 return float(data.bonus) if not data.is_empty() and c.kind==data.kind else 0.0
