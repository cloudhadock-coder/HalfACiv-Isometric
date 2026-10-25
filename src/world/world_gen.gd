extends RefCounted
# Seeded village worlds. Empty settings keep the classic Vale da Aurora map (saves and tests rely on it).
# The plaza stays at (15,15) and a Chebyshev radius of SAFE around it never floods, so roads, the
# founders' spawn column and every starting building remain reachable on any seed.
const SIZE=32
const CENTRE=Vector2i(15,15)
const SAFE=9
const LANDSCAPES=["lagos","rio","costa"]
const LANDSCAPE_NAMES={"lagos":"Lagos","rio":"Rio","costa":"Costa"}
const BOUNTIES=["escasso","normal","farto"]
const BOUNTY_NAMES={"escasso":"Escassos","normal":"Normais","farto":"Fartos"}
const BOUNTY_FACTOR={"escasso":0.6,"normal":1.0,"farto":1.6}
const MAX_SEED=2147483646
const NAME_HEADS=["Vale","Campo","Ribeira","Vila","Serra","Bosque","Lago","Monte","Prado","Quinta"]
const NAME_TAILS=["da Aurora","dos Salgueiros","do Carvalho","das Pedras","do Norte","da Névoa","dos Moinhos","de Santa Clara","do Sol","das Águas","do Cervo","da Colina","do Rei","das Oliveiras"]
# Starting buildings with the distance from the plaza each one prefers.
const STARTING=[["market",1],["warehouse",2],["tavern",2],["bakery",3],["forge",3],["mill",4],["workshop",4],["herbalist",4],["chapel",4],["house",3],["house",3],["house",3],["house",4],["house",4],["tower",6],["farm",6],["farm",6],["pasture",7],["stable",6],["quarry",7],["lumber",0],["fishery",0]]
static func ring(cell: Vector2i) -> int:
 return maxi(absi(cell.x-CENTRE.x),absi(cell.y-CENTRE.y))
static func inside(cell: Vector2i) -> bool:
 return cell.x>=0 and cell.y>=0 and cell.x<SIZE and cell.y<SIZE
static func name_for(seed: int) -> String:
 var rng=RandomNumberGenerator.new();rng.seed=seed*31+7
 return NAME_HEADS[rng.randi_range(0,NAME_HEADS.size()-1)]+" "+NAME_TAILS[rng.randi_range(0,NAME_TAILS.size()-1)]
static func random_settings() -> Dictionary:
 var rng=RandomNumberGenerator.new();rng.randomize()
 var seed=rng.randi_range(1,MAX_SEED)
 return normalize({"seed":seed})
# Fills defaults; landscape "" is derived from the seed so a bare seed always means the same world.
static func normalize(settings: Dictionary) -> Dictionary:
 var seed=clampi(int(settings.get("seed",1)),1,MAX_SEED)
 var landscape=str(settings.get("landscape",""))
 if landscape not in LANDSCAPES:landscape=LANDSCAPES[seed%LANDSCAPES.size()]
 var bounty=str(settings.get("bounty","normal"))
 if bounty not in BOUNTIES:bounty="normal"
 var name=str(settings.get("name","")).strip_edges().left(40)
 return {"seed":seed,"landscape":landscape,"bounty":bounty,"name":name if not name.is_empty() else name_for(seed)}
static func valid(settings) -> bool:
 if not settings is Dictionary or not settings.has_all(["seed","landscape","bounty","name"]):return false
 var seed=settings.seed
 if not (seed is int or seed is float) or not is_finite(float(seed)) or float(seed)!=floor(float(seed)) or seed<1 or seed>MAX_SEED:return false
 return settings.landscape in LANDSCAPES and settings.bounty in BOUNTIES and settings.name is String and not settings.name.strip_edges().is_empty() and settings.name.length()<=40
static func seed_from_text(text: String) -> int:
 var clean=text.strip_edges()
 if clean.is_valid_int() and int(clean)>=1 and int(clean)<=MAX_SEED:return int(clean)
 # Any phrase works as a seed; hash it into the accepted range.
 return 1+absi(clean.hash())%MAX_SEED if not clean.is_empty() else 1
static func generate(settings: Dictionary) -> Dictionary:
 var world=normalize(settings)
 var rng=RandomNumberGenerator.new();rng.seed=world.seed
 var terrain={}
 for x in range(SIZE):
  for y in range(SIZE):terrain[Vector2i(x,y)]="grass"
 flood(terrain,world,rng)
 lay_roads(terrain,rng)
 plant(terrain,world,rng)
 var buildings=place(terrain,rng)
 var horse=CENTRE+Vector2i(0,2)
 for entry in buildings:
  if entry[0]=="stable":horse=road_next_to(terrain,Vector2i(entry[1],entry[2]))
 return {"world":world,"terrain":terrain,"buildings":buildings,"horse":horse}
static func flood(terrain: Dictionary,world: Dictionary,rng: RandomNumberGenerator) -> void:
 var noise=FastNoiseLite.new();noise.seed=world.seed;noise.noise_type=FastNoiseLite.TYPE_SIMPLEX_SMOOTH;noise.frequency=0.11
 match world.landscape:
  "lagos":
   for cell in terrain:
    if ring(cell)>SAFE and noise.get_noise_2d(cell.x,cell.y)>0.22:terrain[cell]="water"
  "rio":
   # A meandering river two or three tiles wide along one side of the valley.
   var vertical=rng.randf()<0.5;var base=rng.randi_range(27,28) if rng.randf()<0.5 else rng.randi_range(2,3);var width=rng.randi_range(2,3)
   for t in range(SIZE):
    var centre=base+int(round(2.0*sin(t*0.35+rng.randf_range(-0.2,0.2)+world.seed%7)+noise.get_noise_1d(t*3.0)*2.0))
    for w in range(width):
     var cell=Vector2i(centre+w-width/2,t) if vertical else Vector2i(t,centre+w-width/2)
     if inside(cell) and ring(cell)>SAFE:terrain[cell]="water"
  "costa":
   # Sea along one edge with a ragged shoreline.
   var edge=rng.randi_range(0,3)
   for t in range(SIZE):
    var depth=4+int(round(noise.get_noise_1d(t*4.0)*2.5))
    for d in range(clampi(depth,2,6)):
     var cell=[Vector2i(d,t),Vector2i(SIZE-1-d,t),Vector2i(t,d),Vector2i(t,SIZE-1-d)][edge]
     if ring(cell)>SAFE:terrain[cell]="water"
 var water=0
 for cell in terrain:
  if terrain[cell]=="water":water+=1
 if water<12:
  # Guarantee a pond so the fishery has a shore on every seed.
  var angle=rng.randf()*TAU;var spot=CENTRE+Vector2i(int(round(cos(angle)*12.0)),int(round(sin(angle)*12.0)))
  spot=spot.clamp(Vector2i(2,2),Vector2i(SIZE-3,SIZE-3))
  for x in range(-2,3):
   for y in range(-2,3):
    var cell=spot+Vector2i(x,y)
    if inside(cell) and ring(cell)>SAFE and x*x+y*y<=5:terrain[cell]="water"
static func lay_roads(terrain: Dictionary,rng: RandomNumberGenerator) -> void:
 # Cross roads run from the plaza until they reach water; a rectangular ring links the quarters.
 for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
  var cell=CENTRE
  while inside(cell) and terrain[cell]!="water":terrain[cell]="road";cell+=direction
 var rx=rng.randi_range(4,6);var ry=rng.randi_range(4,5)
 if rng.randf()<0.5:var swap=rx;rx=ry;ry=swap
 for x in range(-rx,rx+1):
  terrain[CENTRE+Vector2i(x,-ry)]="road";terrain[CENTRE+Vector2i(x,ry)]="road"
 for y in range(-ry,ry+1):
  terrain[CENTRE+Vector2i(-rx,y)]="road";terrain[CENTRE+Vector2i(rx,y)]="road"
 # One or two lanes leave a ring corner towards the edge of the safe area.
 for i in range(rng.randi_range(1,2)):
  var corner=CENTRE+Vector2i(rx*(1 if rng.randf()<0.5 else -1),ry*(1 if rng.randf()<0.5 else -1))
  var step=Vector2i(signi(corner.x-CENTRE.x),0) if rng.randf()<0.5 else Vector2i(0,signi(corner.y-CENTRE.y))
  var cell=corner+step
  while inside(cell) and ring(cell)<=SAFE-1 and terrain[cell]!="water":terrain[cell]="road";cell+=step
static func plant(terrain: Dictionary,world: Dictionary,rng: RandomNumberGenerator) -> void:
 var forest=FastNoiseLite.new();forest.seed=world.seed+7919;forest.noise_type=FastNoiseLite.TYPE_SIMPLEX_SMOOTH;forest.frequency=0.14
 for cell in terrain:
  if terrain[cell]!="grass" or ring(cell)<=5:continue
  if forest.get_noise_2d(cell.x,cell.y)>0.18 or (ring(cell)>7 and rng.randf()<0.035):terrain[cell]="tree"
static func open_cell(terrain: Dictionary,taken: Dictionary,cell: Vector2i) -> bool:
 return inside(cell) and terrain[cell]=="grass" and not taken.has(cell)
static func road_next_to(terrain: Dictionary,cell: Vector2i) -> Vector2i:
 for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
  if inside(cell+offset) and terrain[cell+offset]=="road":return cell+offset
 return CENTRE
static func reachable(terrain: Dictionary,taken: Dictionary) -> Dictionary:
 # Flood fill of walkable cells from the plaza.
 var seen={CENTRE:true};var queue=[CENTRE]
 while not queue.is_empty():
  var cell=queue.pop_back()
  for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   var next=cell+offset
   if inside(next) and not seen.has(next) and terrain[next] in ["grass","road"] and not taken.has(next):seen[next]=true;queue.append(next)
 return seen
static func place(terrain: Dictionary,rng: RandomNumberGenerator) -> Array:
 var taken={};var result=[]
 var trees=[]
 for cell in terrain:
  if terrain[cell]=="tree":trees.append(cell)
 for entry in STARTING:
  var kind=entry[0];var best=Vector2i(-1,-1);var score=INF
  var walkable=reachable(terrain,taken)
  for cell in terrain:
   if not open_cell(terrain,taken,cell) or cell==CENTRE:continue
   var door=false;var shore=false
   for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
    var next=cell+offset
    if not inside(next):continue
    if terrain[next]=="road" or (kind=="fishery" and walkable.has(next)):door=door or walkable.has(next)
    if terrain[next]=="water":shore=true
   if not door:continue
   var value=0.0
   if kind=="fishery":
    if not shore:continue
    value=Vector2(cell-CENTRE).length()
   elif ring(cell)>SAFE-1:continue
   elif kind=="lumber":
    var nearest=INF
    for tree in trees:nearest=minf(nearest,Vector2(tree-cell).length_squared())
    value=sqrt(nearest)+ring(cell)*0.15
   else:value=absf(ring(cell)-entry[1])
   value+=rng.randf()*1.5
   if value<score:score=value;best=cell
  if best.x<0:continue
  # Never seal another building's last free side.
  taken[best]=true
  if not all_open(terrain,taken,result):taken.erase(best);continue
  result.append([kind,best.x,best.y])
 return result
static func all_open(terrain: Dictionary,taken: Dictionary,placed: Array) -> bool:
 var walkable=reachable(terrain,taken)
 for entry in placed:
  var open=false
  for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   if walkable.has(Vector2i(entry[1],entry[2])+offset):open=true
  if not open:return false
 return true
