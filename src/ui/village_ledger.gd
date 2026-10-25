extends RefCounted
# Pure helpers for the village registry, quick-info cards and resource trends.
# The ideas (sortable status lists, attitude colours, Ctrl quick info, research numbers)
# are adapted from Civ2-UI-Additions; no code from that project is used.
const Catalog=preload("res://src/construction/catalog.gd")
const Professions=preload("res://src/entities/professions.gd")
const COLORS={"work":Color("a6bb87"),"move":Color("8fb4c9"),"rest":Color("a79d80"),"problem":Color("dda176")}
const MOOD_RANK={"problem":0,"work":1,"move":2,"rest":3}
const STATE_MOOD={"Trabalhando":"work","Erguendo construção":"work","Vigiando a aldeia":"work","Organizando o depósito":"work","Transportando recursos":"move","A caminho":"move","Patrulhando":"move","Caminho bloqueado":"problem","Sem posto de trabalho":"problem","Aguardando a obra":"problem","Posto sem acesso":"problem","Aguardando insumos":"problem"}
const CITIZEN_SORTS=[["order","Ordem"],["name","Nome"],["profession","Ofício"],["state","Estado"],["stamina","Vigor"]]
const BUILDING_SORTS=[["order","Ordem"],["name","Nome"],["status","Situação"],["staff","Postos"],["stored","Estoque"]]
const TREND_WINDOW=30.0
static func mood(c) -> String:
 # Builders between sites are idle, not unemployed (the overview does not count them either).
 if c.kind==4 and c.state=="Sem posto de trabalho":return "rest"
 return STATE_MOOD.get(c.state,"rest")
static func color_hex(key: String) -> String:
 return COLORS[key].to_html(false)
static func period(hour: float) -> String:
 if hour>=12 and hour<13:return "Refeição"
 return "Trabalho" if hour>=6 and hour<20 else "Descanso"
static func compare(x,y,a: int,b: int,descending: bool) -> bool:
 if x==y:return a<b
 return x>y if descending else x<y
static func citizen_key(c,index: int,key: String):
 match key:
  "name":return c.citizen_name.to_lower()
  "profession":return ("cavalo" if c.horse_only else Professions.name_for(c.kind)).to_lower()
  "state":return "%d %s"%[MOOD_RANK[mood(c)],c.state.to_lower()]
  "stamina":return c.stamina
 return index
static func citizen_rows(people: Array,key: String="order",descending: bool=false) -> Array:
 var rows=[]
 for i in range(people.size()):
  if not people[i].horse_only:rows.append(i)
 rows.sort_custom(func(a,b):return compare(citizen_key(people[a],a,key),citizen_key(people[b],b,key),a,b,descending))
 return rows
static func stored_total(b) -> float:
 var total=0.0
 for key in b.stored:total+=b.stored[key]
 return total
static func building_status(sim,index: int) -> Array:
 var b=sim.buildings[index];var data=Catalog.DATA[b.kind]
 if b.remaining>0:return ["Em obra %d%%"%int(100*(1-b.remaining/float(data.time))),"move"]
 if b.kind=="house":return ["Moradia","rest"]
 if data.slots>0 and int(sim.jobs.get(index,0))==0:return ["Sem trabalhadores","problem"]
 if data.slots>0 and sim.active_workers(index)==0:return ["Equipe ausente","rest"]
 return ["Em funcionamento","work"]
static func building_key(sim,index: int,key: String):
 var b=sim.buildings[index]
 match key:
  "name":return Catalog.DATA[b.kind].name.to_lower()
  "status":return "%d %s"%[MOOD_RANK[building_status(sim,index)[1]],building_status(sim,index)[0]]
  "staff":return int(sim.jobs.get(index,0))
  "stored":return stored_total(b)
 return index
static func building_rows(sim,key: String="order",descending: bool=false) -> Array:
 var rows=range(sim.buildings.size())
 rows.sort_custom(func(a,b):return compare(building_key(sim,a,key),building_key(sim,b,key),a,b,descending))
 return rows
static func amounts(values: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in values:
  if values[key]>=0.05:chunks.append("%.1f %s"%[values[key],Catalog.RESOURCE_NAMES.get(key,key)])
 return ", ".join(chunks) if not chunks.is_empty() else "—"
static func citizen_card(sim,c) -> String:
 var title=c.citizen_name+" · "+("Cavalo" if c.horse_only else Professions.name_for(c.kind))
 var workplace="Sem posto"
 if c.employer>=0 and c.employer<sim.buildings.size():workplace=Catalog.DATA[sim.buildings[c.employer].kind].name
 var text="[b]%s[/b]\n[color=#%s]%s[/color]\nVigor %d%% · Entregas %d"%[title,color_hex(mood(c)),c.state,c.stamina,c.delivered]
 if not c.horse_only:text+="\nPosto: "+workplace
 if not c.cargo.is_empty():text+="\nCarga: "+amounts(c.cargo)
 if not c.route.is_empty():text+="\nRota: %d passos · Shift mostra"%c.route.size()
 return text
static func building_card(sim,index: int) -> String:
 var b=sim.buildings[index];var data=Catalog.DATA[b.kind];var status=building_status(sim,index)
 var text="[b]%s[/b]\n[color=#%s]%s[/color]"%[data.name,color_hex(status[1]),status[0]]
 if data.slots>0:text+="\nPostos %d/%d · Presentes %d"%[int(sim.jobs.get(index,0)),data.slots,sim.active_workers(index)]
 if not data.production.is_empty():text+="\nProduz: "+amounts(data.production)+"/s"
 if not data.get("inputs",{}).is_empty():text+="\nConsome: "+amounts(data.inputs)+"/s"
 if stored_total(b)>0:text+="\nAguardando: "+amounts(b.stored)
 return text
static func missing(cost: Dictionary,resources: Dictionary) -> String:
 var gaps={}
 for key in cost:
  if resources.get(key,0.0)<cost[key]:gaps[key]=cost[key]-resources.get(key,0.0)
 return amounts(gaps) if not gaps.is_empty() else ""
# samples: [[sim_seconds, resources]] oldest first. Returns change per game hour.
static func push_sample(samples: Array,seconds: float,resources: Dictionary) -> void:
 if not samples.is_empty() and seconds<samples.back()[0]:samples.clear()
 if samples.is_empty() or seconds-samples.back()[0]>=1.0:samples.append([seconds,resources.duplicate()])
 while samples.size()>2 and seconds-samples[1][0]>=TREND_WINDOW:samples.pop_front()
static func rates(samples: Array,day_seconds: float) -> Dictionary:
 var result={}
 if samples.size()<2:return result
 var first=samples.front();var last=samples.back();var span=last[0]-first[0]
 if span<5.0:return result
 for key in last[1]:result[key]=(last[1][key]-first[1].get(key,0.0))/span*day_seconds/24.0
 return result
