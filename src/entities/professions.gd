extends RefCounted

# Stable IDs preserve identities in v0.1 saves.
const DATA = [
 {"name":"Camponês","jobs":["farm","pasture"],"tool":"hoe"},
 {"name":"Camponesa","jobs":["farm","pasture"],"tool":"basket"},
 {"name":"Lenhador","jobs":["lumber"],"tool":"axe"},
 {"name":"Minerador","jobs":["quarry"],"tool":"pick"},
 {"name":"Construtor","jobs":[],"tool":"hammer"},
 {"name":"Mercador","jobs":["market"],"tool":"coins"},
 {"name":"Guarda","jobs":["barracks","tower"],"tool":"sword"},
 {"name":"Cavaleiro","jobs":["stable"],"tool":"sword"},
 {"name":"Arqueiro","jobs":["tower","barracks"],"tool":"bow"},
 {"name":"Governante","jobs":["market"],"tool":"seal"},
 {"name":"Nobre","jobs":["market"],"tool":"seal"},
 {"name":"Sacerdote","jobs":["chapel"],"tool":"book"},
 {"name":"Agricultora","jobs":["farm","pasture"],"tool":"hoe"},
 {"name":"Pescador","jobs":["fishery"],"tool":"rod"},
 {"name":"Moleiro","jobs":["mill"],"tool":"sack"},
 {"name":"Padeira","jobs":["bakery"],"tool":"bread"},
 {"name":"Ferreiro","jobs":["forge"],"tool":"hammer"},
 {"name":"Carpinteiro","jobs":["workshop"],"tool":"saw"},
 {"name":"Herbalista","jobs":["herbalist"],"tool":"herbs"},
 {"name":"Cervejeiro","jobs":["tavern"],"tool":"mug"},
 {"name":"Pastora","jobs":["pasture"],"tool":"crook"},
 {"name":"Estalajadeira","jobs":["tavern"],"tool":"mug"},
 {"name":"Carregador","jobs":["warehouse"],"tool":"crate"},
 {"name":"Vigia","jobs":["tower","barracks"],"tool":"lantern"}
]
const NAMES = ["Aldric","Elena","Borin","Darin","Edwin","Farid","Gareth","Hector","Ivar","Jonas","Klara","Lucian","Mara","Oswin","Odo","Beatriz","Ulric","Tomas","Ysabel","Bruno","Rosa","Agnes","Nuno","Cedric"]

static func patrol(kind: int) -> bool:
 return kind in [6,7,8,23]

static func name_for(kind: int) -> String:
 return DATA[clampi(kind,0,DATA.size()-1)].name
