extends RefCounted
const SIZE = 32
const TILE_ORIGIN = Vector2(32,40)
const TILE_HALF = Vector2(32,16)
static func project(cell: Vector2) -> Vector2:
 return Vector2((cell.x-cell.y)*32.0,(cell.x+cell.y)*16.0)
static func unproject(point: Vector2) -> Vector2:
 return Vector2(point.x/64.0+point.y/32.0,point.y/32.0-point.x/64.0)
static func tile(point: Vector2) -> Vector2i:
 # Half-open cells: [-0.5, 0.5), also for negative coordinates.
 return Vector2i((unproject(point)+Vector2(0.5,0.5)).floor())
static func grid_to_screen(cell: Vector2) -> Vector2:
 return project(cell)
static func screen_to_grid(point: Vector2) -> Vector2i:
 return tile(point)
static func footprint(size: int=SIZE) -> PackedVector2Array:
 return PackedVector2Array([project(Vector2(-0.5,-0.5)),project(Vector2(size-0.5,-0.5)),project(Vector2(size-0.5,size-0.5)),project(Vector2(-0.5,size-0.5))])
