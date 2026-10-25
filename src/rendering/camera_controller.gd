extends RefCounted
const Bounds=preload("res://src/rendering/camera_bounds.gd")
const Iso=preload("res://src/world/iso.gd")
const ZOOM_STEPS=[1.0,1.5,2.0,3.0,4.0]
var camera: Camera2D
var viewport_size: Vector2
var useful: Rect2
var focus: Vector2=Iso.project(Vector2(15.5,15.5))
var step: int=2
var minimum_step: int=0
var region: PackedVector2Array=PackedVector2Array()
var layout_revision: int=0
var region_revision: int=0

func _init(node: Camera2D) -> void:
 camera=node
 camera.position_smoothing_enabled=false

func configure(size: Vector2,area: Rect2) -> void:
 if size==viewport_size and area==useful:return
 viewport_size=size;useful=area;layout_revision+=1
 var required=Bounds.required_zoom(useful.size+Vector2(4,4))
 minimum_step=0
 while minimum_step<ZOOM_STEPS.size()-1 and ZOOM_STEPS[minimum_step]<required:minimum_step+=1
 step=maxi(step,minimum_step)
 update_region();apply()

func update_region() -> void:
 region=Bounds.polygon(useful.size+Vector2(4,4),ZOOM_STEPS[step])
 region_revision+=1

func apply() -> void:
 var zoom=ZOOM_STEPS[step]
 focus=Bounds.constrain_region(focus,region)
 var origin=focus-(useful.get_center()-viewport_size*0.5)/zoom
 # Snap the camera's final screen translation, retaining fractional input in focus.
 var translation=(viewport_size*0.5-origin*zoom).round()
 camera.zoom=Vector2.ONE*zoom
 camera.position=(viewport_size*0.5-translation)/zoom
 camera.force_update_scroll()

func pan_screen(motion: Vector2) -> void:
 if motion.is_zero_approx():return
 focus+=motion/ZOOM_STEPS[step];apply()

func screen_to_world(screen: Vector2) -> Vector2:
 return camera.position+(screen-viewport_size*0.5)/camera.zoom

func world_to_screen(world: Vector2) -> Vector2:
 return (world-camera.position)*camera.zoom+viewport_size*0.5

func zoom_at(direction: int,cursor: Vector2) -> void:
 var next=clampi(step+direction,minimum_step,ZOOM_STEPS.size()-1)
 if next==step:return
 var anchor=screen_to_world(cursor)
 step=next;update_region()
 var desired_origin=anchor-(cursor-viewport_size*0.5)/ZOOM_STEPS[step]
 focus=desired_origin+(useful.get_center()-viewport_size*0.5)/ZOOM_STEPS[step]
 apply()

func move_to(point: Vector2) -> void:
 focus=point;apply()

func set_step(index: int) -> void:
 step=clampi(index,minimum_step,ZOOM_STEPS.size()-1);update_region();apply()
