extends SceneTree
# Reachability test using only real actions and time; no injected money, population or support.
const Sim=preload("res://src/economy/simulation.gd")
func _init() -> void:call_deferred("run")
func construct(sim,kind: String) -> bool:
 for x in range(7,24):
  for y in range(4,25):
   var cell=Vector2i(x,y)
   if sim.can_build(kind,cell) and sim.build(kind,cell):return true
 return false
func run() -> void:
 var sim=Sim.new();var target=sim.politics;var days=0
 for i in range(80):
  days=i+1
  if sim.housing_capacity()<52 and sim.population>=sim.housing_capacity():construct(sim,"house")
  if target.stage>=2 and sim.nearest_kind(["barracks"],Vector2(15,15))<0 and not sim.buildings.any(func(b):return b.kind=="barracks"):construct(sim,"barracks")
  var lowest="peasants"
  for key in target.support:
   if target.support[key]<target.support[lowest]:lowest=key
  target.decide(sim,{"peasants":"relief","guilds":"guild_charter","clergy":"sanctuary","nobility":"oath"}[lowest])
  for id in target.REFORMS:target.enact(sim,id)
  target.promote(sim)
  if target.stage==4:break
  sim.apply_offline(240);sim.tick(20)
 var ok=target.stage==4 and sim.population>=48 and sim.resources.food>=0
 print("REALM_CAMPAIGN_RESULT passed=",ok," cycles=",days," game_day=",sim.day()," stage=",target.STAGES[target.stage]," population=",sim.population," legitimacy=",target.legitimacy," support=",target.support," reforms=",target.reforms)
 quit(0 if ok else 1)
