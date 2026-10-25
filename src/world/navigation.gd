extends RefCounted
const COST={"road":0.85,"grass":1.0,"dirt":1.0,"sand":1.3,"stone":1.2}
class WeightedGrid extends AStarGrid2D:
 func _estimate_cost(from_id: Vector2i,to_id: Vector2i) -> float:
  return (absi(from_id.x-to_id.x)+absi(from_id.y-to_id.y))*0.85
var grid: AStarGrid2D
var cache: Dictionary={}
var rebuild_count: int=0
var incremental_count: int=0
func rebuild(sim) -> void:
 grid=WeightedGrid.new();grid.region=Rect2i(0,0,sim.map_size(),sim.map_size());grid.cell_size=Vector2.ONE
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;grid.update();cache.clear();rebuild_count+=1
 for cell in sim.terrain:set_cell(sim,cell)
func set_cell(sim,cell: Vector2i) -> void:
 grid.set_point_solid(cell,sim.blocked(cell));grid.set_point_weight_scale(cell,COST.get(sim.terrain[cell],1.0))
func change_cell(sim,cell: Vector2i) -> void:
 set_cell(sim,cell);cache.clear();incremental_count+=1
func speed_factor(cell: Vector2i) -> float:
 return 1.0/grid.get_point_weight_scale(cell) if grid.region.has_point(cell) else 1.0
func path(start: Vector2i,goal: Vector2i) -> Array[Vector2i]:
 if not grid.region.has_point(start) or not grid.region.has_point(goal):return []
 if grid.is_point_solid(start) or grid.is_point_solid(goal):return []
 var key=Vector4i(start.x,start.y,goal.x,goal.y)
 if cache.has(key):return cache[key].duplicate()
 var result=grid.get_id_path(start,goal)
 if cache.size()>=256:cache.clear()
 cache[key]=result.duplicate();return result
