extends RefCounted
var grid: AStarGrid2D
func rebuild(sim) -> void:
 grid=AStarGrid2D.new()
 grid.region=Rect2i(0,0,32,32)
 grid.cell_size=Vector2.ONE
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.update()
 for x in range(32):
  for y in range(32):grid.set_point_solid(Vector2i(x,y),sim.blocked(Vector2i(x,y)))
func path(start: Vector2i,goal: Vector2i) -> Array[Vector2i]:
 if not grid.region.has_point(start) or not grid.region.has_point(goal):return []
 if grid.is_point_solid(start) or grid.is_point_solid(goal):return []
 return grid.get_id_path(start,goal)
