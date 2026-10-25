extends RefCounted
const Iso=preload("res://src/world/iso.gd")

# Erode the real diamond, then retain bounded inspection space at its vertices.
# Otherwise a fully-inscribed rectangular viewport can never show the corner tiles.
static func grid_limits(view_size: Vector2,zoom: float,size: int=32) -> Vector2:
 var margin=(view_size.x/128.0+view_size.y/64.0)/zoom
 return Vector2(-0.5+margin,float(size)-0.5-margin)

static func required_zoom(view_size: Vector2,size: int=32) -> float:
 return (view_size.x/64.0+view_size.y/32.0)/float(size)

static func fitted_polygon(view_size: Vector2,zoom: float,size: int=32) -> PackedVector2Array:
 var limits=grid_limits(view_size,zoom,size)
 if limits.x>limits.y:return PackedVector2Array()
 return PackedVector2Array([Iso.project(Vector2(limits.x,limits.x)),Iso.project(Vector2(limits.y,limits.x)),Iso.project(Vector2(limits.y,limits.y)),Iso.project(Vector2(limits.x,limits.y))])

static func polygon(view_size: Vector2,zoom: float,size: int=32) -> PackedVector2Array:
 var inner=fitted_polygon(view_size,zoom,size)
 if inner.is_empty():return inner
 var half=view_size/zoom*0.5
 var border=Iso.footprint(size)
 var vertical_margin=minf(64,half.y*0.8)
 var horizontal_margin=minf(40,half.x*0.65)
 inner.append(border[0]+Vector2(0,half.y-vertical_margin))
 inner.append(border[1]-Vector2(half.x-horizontal_margin,0))
 inner.append(border[2]-Vector2(0,half.y-minf(32,half.y*0.65)))
 inner.append(border[3]+Vector2(half.x-horizontal_margin,0))
 return Geometry2D.convex_hull(inner)

static func constrain(point: Vector2,view_size: Vector2,zoom: float,size: int=32) -> Vector2:
 return constrain_region(point,polygon(view_size,zoom,size),size)

static func constrain_region(point: Vector2,region: PackedVector2Array,size: int=32) -> Vector2:
 if region.is_empty():return Iso.project(Vector2.ONE*(size-1)*0.5)
 if Geometry2D.is_point_in_polygon(point,region):return point
 var nearest=region[0];var distance=INF
 for i in range(region.size()):
  var candidate=Geometry2D.get_closest_point_to_segment(point,region[i],region[(i+1)%region.size()])
  var d=point.distance_squared_to(candidate)
  if d<distance:distance=d;nearest=candidate
 return nearest

static func corners_inside(focus: Vector2,view_size: Vector2,zoom: float,size: int=32) -> bool:
 var half=view_size/zoom*0.5
 for corner in [Vector2(-half.x,-half.y),Vector2(half.x,-half.y),Vector2(half.x,half.y),Vector2(-half.x,half.y)]:
  var p=Iso.unproject(focus+corner)
  if p.x < -0.5001 or p.y < -0.5001 or p.x > size-0.4999 or p.y > size-0.4999:return false
 return true
