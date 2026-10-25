extends RefCounted
# No political choice, promotion or support change is made by time/offline alone.
const FACTIONS={"peasants":"Camponeses","guilds":"Guildas","clergy":"Clero","nobility":"Nobreza"}
const STAGES=["Aldeia","Vila","Cidade Livre","Principado","Reino"]
const DECISIONS={
 "relief":{"name":"Abrir os celeiros","cost":{"food":40,"gold":20},"support":{"peasants":12,"guilds":-4,"clergy":3,"nobility":-4},"legitimacy":5,"reward":{"influence":5}},
 "guild_charter":{"name":"Encomenda às guildas","cost":{"wood":25,"gold":25},"support":{"peasants":-3,"guilds":12,"clergy":0,"nobility":-5},"legitimacy":4,"reward":{"influence":8}},
 "sanctuary":{"name":"Amparar o santuário","cost":{"food":25,"gold":15},"support":{"peasants":3,"guilds":-4,"clergy":12,"nobility":-3},"legitimacy":6,"reward":{"influence":4}},
 "oath":{"name":"Convocar juramento dos nobres","cost":{"gold":30,"influence":5},"support":{"peasants":-6,"guilds":-5,"clergy":2,"nobility":14},"legitimacy":8,"reward":{}},
 "levy":{"name":"Cobrar tributo extraordinário","cost":{"influence":4},"support":{"peasants":-10,"guilds":-8,"clergy":-3,"nobility":5},"legitimacy":-6,"reward":{"gold":45}}
}
const REFORMS={
 "commons":{"name":"Carta dos campos comuns","stage":1,"faction":"peasants","support":55,"cost":{"wood":60,"gold":60,"influence":20},"benefit":"+15% de alimento produzido; insumos mantidos.","legitimacy":3},
 "weights":{"name":"Pesos e medidas","stage":1,"faction":"guilds","support":55,"cost":{"stone":35,"gold":80,"influence":25},"benefit":"+15% de ouro produzido nos postos; insumos mantidos.","legitimacy":3},
 "parish":{"name":"Escolas paroquiais","stage":2,"faction":"clergy","support":55,"cost":{"wood":45,"gold":100,"influence":30},"benefit":"+20% de influência produzida nos postos.","legitimacy":5},
 "assembly":{"name":"Assembleia dos estamentos","stage":2,"faction":"nobility","support":55,"cost":{"stone":50,"gold":120,"influence":35},"benefit":"+10% de tributos populacionais; +5 de apoio às quatro facções.","legitimacy":5}
}
const THRESHOLDS=[
 {"population":24,"legitimacy":55,"support":40,"cost":{"gold":80,"influence":15},"buildings":["market"]},
 {"population":32,"legitimacy":60,"support":45,"cost":{"gold":160,"influence":40},"buildings":["market","chapel","warehouse"]},
 {"population":40,"legitimacy":70,"support":45,"cost":{"gold":300,"influence":80},"buildings":["chapel","forge","tower"]},
 {"population":48,"legitimacy":80,"support":50,"cost":{"gold":500,"influence":140},"buildings":["chapel","market","barracks"]}
]
var stage: int=0
var legitimacy: float=50.0
var support: Dictionary={"peasants":50.0,"guilds":50.0,"clergy":50.0,"nobility":50.0}
var reforms: Array=[]
var last_council_day: int=0
var history: Array=[]
static func finite_number(v) -> bool:
 return (v is int or v is float) and is_finite(float(v))
func snapshot() -> Dictionary:
 return {"stage":stage,"legitimacy":legitimacy,"support":support.duplicate(),"reforms":reforms.duplicate(),"last_council_day":last_council_day,"history":history.duplicate(true)}
static func restore(value):
 if not value is Dictionary:return null
 var result=load("res://src/politics/realm.gd").new()
 if value.is_empty():return result
 if not value.has_all(["stage","legitimacy","support","reforms","last_council_day","history"]):return null
 for key in ["stage","last_council_day"]:
  if not finite_number(value[key]) or value[key]!=int(value[key]) or value[key]<0:return null
 if value.stage>=STAGES.size() or not finite_number(value.legitimacy) or value.legitimacy<0 or value.legitimacy>100:return null
 if not value.support is Dictionary or value.support.size()!=4:return null
 for key in FACTIONS:
  if not value.support.has(key) or not finite_number(value.support[key]) or value.support[key]<0 or value.support[key]>100:return null
 if not value.reforms is Array or value.reforms.size()>REFORMS.size():return null
 var seen={}
 for id in value.reforms:
  if not id is String or not REFORMS.has(id) or seen.has(id) or REFORMS[id].stage>value.stage:return null
  seen[id]=true
 if not value.history is Array or value.history.size()>40:return null
 for entry in value.history:
  if not entry is Dictionary or not entry.has_all(["day","text"]):return null
  if not finite_number(entry.day) or entry.day<1 or entry.day!=int(entry.day) or not entry.text is String or entry.text.length()>160:return null
 result.stage=int(value.stage);result.legitimacy=float(value.legitimacy);result.support=value.support.duplicate()
 result.reforms=value.reforms.duplicate();result.last_council_day=int(value.last_council_day);result.history=value.history.duplicate(true)
 return result
func cost_reason(sim,cost: Dictionary) -> String:
 for key in cost:
  if sim.resources[key]<cost[key]:return "Falta %d de %s"%[ceili(cost[key]-sim.resources[key]),sim.Catalog.RESOURCE_NAMES[key]]
 return ""
func pay(sim,cost: Dictionary) -> void:
 for key in cost:sim.resources[key]-=cost[key]
func record(sim,text: String) -> void:
 history.push_front({"day":sim.day(),"text":text})
 if history.size()>40:history.resize(40)
func decision_reason(sim,id: String) -> String:
 if not DECISIONS.has(id):return "Proposta desconhecida"
 if last_council_day>=sim.day():return "O conselho volta a deliberar no próximo dia"
 return cost_reason(sim,DECISIONS[id].cost)
func decide(sim,id: String) -> bool:
 if not decision_reason(sim,id).is_empty():return false
 var data=DECISIONS[id];pay(sim,data.cost)
 for key in data.support:support[key]=clampf(support[key]+data.support[key],0,100)
 legitimacy=clampf(legitimacy+data.legitimacy,0,100)
 for key in data.reward:sim.resources[key]+=data.reward[key]
 last_council_day=sim.day();record(sim,data.name);return true
func reform_reason(sim,id: String) -> String:
 if not REFORMS.has(id):return "Reforma desconhecida"
 if id in reforms:return "Reforma já promulgada"
 var data=REFORMS[id]
 if stage<data.stage:return "Requer "+STAGES[data.stage]
 if support[data.faction]<data.support:return "Requer %d de apoio: %s"%[data.support,FACTIONS[data.faction]]
 return cost_reason(sim,data.cost)
func enact(sim,id: String) -> bool:
 if not reform_reason(sim,id).is_empty():return false
 var data=REFORMS[id];pay(sim,data.cost);reforms.append(id);legitimacy=minf(100,legitimacy+data.legitimacy)
 if id=="assembly":
  for key in support:support[key]=minf(100,support[key]+5)
 record(sim,"Reforma: "+data.name);return true
func promotion_reasons(sim) -> PackedStringArray:
 var reasons=PackedStringArray()
 if stage==4:return reasons
 var data=THRESHOLDS[stage]
 if sim.population<data.population:reasons.append("Moradores: %d/%d"%[sim.population,data.population])
 if sim.housing_capacity()<sim.population:reasons.append("Providencie moradia para toda a população")
 if legitimacy<data.legitimacy:reasons.append("Legitimidade: %d/%d"%[legitimacy,data.legitimacy])
 for key in support:
  if support[key]<data.support:reasons.append("Apoio de %s: %d/%d"%[FACTIONS[key],support[key],data.support])
 for kind in data.buildings:
  if sim.nearest_kind([kind],Vector2(15,15))<0:reasons.append("Conclua: "+sim.Catalog.DATA[kind].name)
 if stage==3 and reforms.size()<3:reasons.append("Reformas: %d/3"%reforms.size())
 var money=cost_reason(sim,data.cost)
 if not money.is_empty():reasons.append(money)
 return reasons
func promote(sim) -> bool:
 if stage==4 or not promotion_reasons(sim).is_empty():return false
 pay(sim,THRESHOLDS[stage].cost);stage+=1;record(sim,"Domínio elevado a "+STAGES[stage]);return true
func production_multiplier(resource: String) -> float:
 if resource=="food" and "commons" in reforms:return 1.15
 if resource=="gold" and "weights" in reforms:return 1.15
 if resource=="influence" and "parish" in reforms:return 1.2
 return 1.0
func tax_multiplier() -> float:return 1.1 if "assembly" in reforms else 1.0
