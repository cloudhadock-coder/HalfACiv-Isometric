extends RefCounted
const DATA = {
 "house":{"name":"Casa","cost":{"wood":25,"stone":5},"time":8,"production":{},"slots":0,"benefit":"+4 habitantes","category":"Moradia"},
 "farm":{"name":"Horta","cost":{"wood":15},"time":6,"production":{"food":2.8},"slots":2,"benefit":"Alimentos frescos","category":"Alimentos"},
 "lumber":{"name":"Serraria","cost":{"wood":30,"stone":8},"time":10,"production":{"wood":1.8},"slots":2,"benefit":"Madeira","category":"Oficinas"},
 "quarry":{"name":"Pedreira","cost":{"wood":30,"gold":10},"time":12,"production":{"stone":1.4},"slots":2,"benefit":"Pedra","category":"Oficinas"},
 "market":{"name":"Feira","cost":{"wood":45,"stone":15},"time":15,"production":{"gold":0.9},"slots":3,"benefit":"Comércio e tributos","category":"Comunidade"},
 "chapel":{"name":"Capela","cost":{"wood":55,"stone":50,"gold":20},"time":20,"production":{"influence":0.18},"slots":1,"benefit":"Influência","category":"Comunidade"},
 "mill":{"name":"Moinho","cost":{"wood":45,"stone":20},"time":16,"production":{"food":2.4},"slots":1,"benefit":"Moagem de cereais","category":"Alimentos"},
 "bakery":{"name":"Padaria","cost":{"wood":35,"stone":25,"gold":10},"time":16,"production":{"food":3.2},"inputs":{"wood":0.12},"slots":1,"benefit":"Pão; consome lenha","category":"Alimentos"},
 "fishery":{"name":"Pesqueiro","cost":{"wood":25,"gold":5},"time":10,"production":{"food":2.4},"slots":1,"benefit":"Exige margem de água","category":"Alimentos"},
 "forge":{"name":"Forja","cost":{"wood":45,"stone":40,"gold":20},"time":22,"production":{"gold":1.6},"inputs":{"wood":0.16,"stone":0.1},"slots":1,"benefit":"Ferragens; consome madeira e pedra","category":"Oficinas"},
 "workshop":{"name":"Carpintaria","cost":{"wood":35,"stone":10},"time":14,"production":{"gold":1.0},"inputs":{"wood":0.2},"slots":1,"benefit":"Móveis e ferramentas","category":"Oficinas"},
 "herbalist":{"name":"Herbário","cost":{"wood":25,"gold":10},"time":12,"production":{"food":0.8,"influence":0.1},"slots":1,"benefit":"Ervas e cuidados","category":"Comunidade"},
 "tavern":{"name":"Estalagem","cost":{"wood":55,"stone":20,"gold":25},"time":20,"production":{"gold":1.4},"inputs":{"food":0.25},"slots":2,"benefit":"Bebidas, refeições e descanso","category":"Comunidade"},
 "warehouse":{"name":"Depósito","cost":{"wood":40,"stone":15},"time":14,"production":{},"slots":1,"benefit":"Recebe cargas dos trabalhadores","category":"Comunidade"},
 "stable":{"name":"Estábulo","cost":{"wood":40,"stone":10},"time":14,"production":{},"slots":1,"benefit":"Repouso dos cavalos","category":"Comunidade"},
 "pasture":{"name":"Pasto","cost":{"wood":20},"time":10,"production":{"food":2.0},"slots":2,"benefit":"Rebanho e alimentos","category":"Alimentos"},
 "barracks":{"name":"Quartel","cost":{"wood":55,"stone":30,"gold":20},"time":20,"production":{"influence":0.1},"slots":2,"benefit":"Base de patrulhas","category":"Comunidade"},
 "tower":{"name":"Torre de vigia","cost":{"wood":35,"stone":40},"time":18,"production":{"influence":0.1},"slots":1,"benefit":"Vigilância das estradas","category":"Comunidade"}
}
const RESOURCE_NAMES={"food":"alimento","wood":"madeira","stone":"pedra","gold":"ouro","influence":"influência"}
static func make(kind: String,cell: Vector2i,remaining: float=0.0) -> Dictionary:
 return {"kind":kind,"x":cell.x,"y":cell.y,"remaining":remaining,"level":1,"stored":{}}
