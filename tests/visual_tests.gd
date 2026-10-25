extends SceneTree
const Iso=preload("res://src/world/iso.gd")
const Bounds=preload("res://src/rendering/camera_bounds.gd")
const Policy=preload("res://src/rendering/render_policy.gd")
var assertions: int=0
var failures: int=0
func check(ok: bool,description: String) -> void:
 assertions+=1
 if not ok:failures+=1;push_error(description)
func _init() -> void:call_deferred("run")
func run() -> void:
 for x in range(-32,65):
  for y in range(-32,65):
   var cell=Vector2i(x,y);var point=Iso.grid_to_screen(Vector2(cell))
   check(Iso.screen_to_grid(point)==cell,"negative and border iso roundtrip")
   check(Iso.screen_to_grid(point+Vector2(0,15.5))==cell,"near lower diamond edge")
 check(Iso.tile(Iso.project(Vector2(-0.5,0)))==Vector2i(0,0),"negative half-open tie")
 check(Iso.tile(Iso.project(Vector2(31.5,0)))==Vector2i(32,0),"far half-open edge")
 var rng=RandomNumberGenerator.new();rng.seed=21921
 for size in [Vector2(748,566),Vector2(1122,849),Vector2(1256,566)]:
  for zoom in [1.0,1.5,2.0,3.0,4.0]:
   for i in range(120):
    var point=Vector2(rng.randf_range(-4000,4000),rng.randf_range(-3000,4000))
    var result=Bounds.constrain(point,size,zoom)
    check(Bounds.constrain(result,size,zoom).distance_to(result)<0.001,"camera clamp is stable")
    var region=Bounds.polygon(size,zoom)
    if region.is_empty():check(result.distance_to(Iso.project(Vector2(15.5,15.5)))<0.001,"small map centered")
    else:
     var grid=Iso.unproject(result)
     check(grid.x>=-0.501 and grid.x<=31.501 and grid.y>=-0.501 and grid.y<=31.501,"focus remains inside diamond")
 var a={"y":100.0,"type":1,"order":0};var b={"y":99.75,"type":2,"order":0};var c={"y":100.25,"type":2,"order":0}
 check(Policy.before(b,a) and Policy.before(a,c),"foot depth behind and front")
 check(not Policy.before(a,a),"strict depth ordering")
 check(Policy.before({"y":100.0,"type":2,"order":2},{"y":100.0,"type":2,"order":3}),"stable ties")
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 await process_frame
 game.hud.menu.hide();game.paused=true
 var rig=game.camera_rig
 for step in range(rig.minimum_step,5):
  rig.set_step(step);rig.move_to(Iso.project(Vector2(15.5,15.5)))
  for cell in [Vector2(-5,-2),Vector2.ZERO,Vector2(17,12),Vector2(31,31),Vector2(32,32)]:
   var point=Iso.project(cell);var screen=rig.world_to_screen(point)
   check(rig.screen_to_world(screen).distance_to(point)<0.001,"camera transform roundtrip")
   var actual=game.get_viewport().get_canvas_transform()*point
   check(actual.distance_to(screen)<0.01,"camera math agrees with real canvas")
  var region_revision=rig.region_revision
  var fractional=rig.focus
  for i in range(30):rig.pan_screen(Vector2(0.1,0))
  check(rig.focus.distance_to(fractional)>0.1,"fractional input accumulates without being lost")
  check(rig.region_revision==region_revision,"panning reuses cached polygon")
 rig.set_step(4)
 for edge in [[Vector2(0,-10000),Vector2.ZERO],[Vector2(10000,496),Vector2(31,0)],[Vector2(0,10000),Vector2(31,31)],[Vector2(-10000,496),Vector2(0,31)]]:
  rig.move_to(edge[0]);check(rig.useful.has_point(rig.world_to_screen(Iso.project(edge[1]))),"corner tile remains inspectable")
 rig.set_step(2);rig.move_to(Iso.project(Vector2(15.5,15.5)))
 var cursor=rig.useful.get_center()+Vector2(43,22);var anchor=rig.screen_to_world(cursor)
 rig.zoom_at(1,cursor)
 check(rig.world_to_screen(anchor).distance_to(cursor)<=1.1,"zoom retains cursor anchor within pixel snap")
 var revisions=rig.layout_revision
 rig.configure(rig.viewport_size,rig.useful);check(rig.layout_revision==revisions,"layout bounds cached")
 var position=game.camera.position
 for i in range(3):await process_frame
 check(game.camera.position==position,"idle camera does not drift")
 game.dragging=true
 var release=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_MIDDLE;release.pressed=false;game._input(release)
 check(not game.dragging,"middle release is handled even when GUI consumes it")
 var width=rig.useful.size.x
 game.hud.toggle_build();check(rig.useful.size.x>width,"collapsed panel expands usable viewport")
 game.hud.toggle_details();check(not game.hud.detail_panel.visible,"right panel collapses")
 game.hud.toggle_build();game.hud.toggle_details()
 # Sorting uses the same interpolated foot point as rendering, not next simulation state.
 var person=game.sim.people[0];person.previous=Vector2(14,14);person.position=Vector2(14.8,14.8);game.sim.elapsed=0.05;game.world.animate=true
 var point=game.world.person_point(person);var expected=Iso.project(person.previous.lerp(person.position,0.5))
 check((game.get_viewport().get_canvas_transform()*point).distance_to(game.get_viewport().get_canvas_transform()*expected)<=0.75,"interpolated foot snapped only in screen space")
 print("VISUAL_TEST_RESULT assertions=",assertions," failures=",failures)
 game.queue_free();quit(0 if failures==0 else 1)
