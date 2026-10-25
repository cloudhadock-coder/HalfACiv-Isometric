extends SceneTree
const Iso=preload("res://src/world/iso.gd")
const Citizen=preload("res://src/entities/citizen.gd")
const Policy=preload("res://src/rendering/render_policy.gd")
const FOLDER="res://docs/visual-validation/v0.2.1/"
var game
var report={"captures":[],"checks":0,"failures":0,"depth":{}}
func check(ok: bool,message: String) -> void:
 report.checks+=1
 if not ok:report.failures+=1;push_error(message)
func _init() -> void:call_deferred("run")
func settle() -> void:
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
func capture(name: String) -> Image:
 await settle()
 var image=root.get_texture().get_image()
 if "--no-save" in OS.get_cmdline_user_args():check(not image.is_empty(),"render "+name)
 else:check(image.save_png(FOLDER+name+".png")==OK,"capture "+name)
 report.captures.append({"file":name+".png","size":[image.get_width(),image.get_height()],"zoom":game.camera.zoom.x,"focus":[game.camera_rig.focus.x,game.camera_rig.focus.y]})
 return image
func apply_person(person) -> void:
 game.sim.people=[person] if person!=null else []
 game.people=game.sim.people;game.world.people=game.sim.people;game.world.refresh()
func colour_close(a: Color,b: Color) -> bool:
 return maxf(maxf(absf(a.r-b.r),absf(a.g-b.g)),absf(a.b-b.b))<0.006
func depth_pixels(image: Image,base: Image,person,building: Dictionary,behind: bool) -> int:
 var frame=game.world.building_frame("house",Vector2i(building.x,building.y))
 var tile=game.world.building_art.textures.house.get_image().get_region(Rect2i(frame*64,0,64,64))
 var sprite=game.world.characters[person.portrait_id].get_image()
 var foot=game.world.person_point(person)
 var first=game.camera_rig.world_to_screen(foot-Policy.CHARACTER_PIVOT)
 var last=game.camera_rig.world_to_screen(foot-Policy.CHARACTER_PIVOT+Policy.CHARACTER_FRAME)
 var count=0
 for y in range(maxi(0,int(first.y)),mini(image.get_height(),int(last.y))):
  for x in range(maxi(0,int(first.x)),mini(image.get_width(),int(last.x))):
   var world=game.camera_rig.screen_to_world(Vector2(x+0.5,y+0.5))
   var actor=Vector2i((world-(foot-Policy.CHARACTER_PIVOT)).floor())
   var house=Vector2i((world-(Iso.project(Vector2(building.x,building.y))-Iso.TILE_ORIGIN)).floor())
   if actor.x<0 or actor.x>=30 or actor.y<0 or actor.y>=35 or house.x<0 or house.x>=64 or house.y<0 or house.y>=64:continue
   var colour=sprite.get_pixelv(actor)
   if colour.a>0.99 and tile.get_pixelv(house).a>0.99:
    count+=1;check(colour_close(image.get_pixel(x,y),base.get_pixel(x,y) if behind else colour),"actual pixel occlusion behind/front")
 return count
func run() -> void:
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await settle()
 game.hud.menu.hide();game.sim.tick(20);game.paused=true;game.world.animate=false;game.hud.update_resources(game.sim)
 await capture("Camera_Default")
 game.camera_rig.set_step(4);await capture("Camera_Zoom_In")
 game.camera_rig.set_step(game.camera_rig.minimum_step);game.camera_rig.move_to(Iso.project(Vector2(15.5,15.5)));await capture("Camera_Zoom_Out")
 game.camera_rig.set_step(2)
 for item in [["North",Vector2(0,-10000)],["South",Vector2(0,10000)],["East",Vector2(10000,496)],["West",Vector2(-10000,496)]]:
  game.camera_rig.move_to(item[1]);await capture("Camera_"+item[0]+"_Edge")
  var focus=game.camera_rig.focus;game.camera_rig.pan_screen(item[1].normalized()*1000)
  check(game.camera_rig.focus.distance_to(focus)<0.01,"edge input cannot overshoot")
 game.camera_rig.move_to(Iso.project(Vector2(16,15)));game.camera_rig.set_step(3);await capture("Village_Closeup")
 game.camera_rig.set_step(2);game.camera_rig.move_to(Iso.project(Vector2(15.5,15.5)));await capture("UI_Layout")
 game.hud.toggle_build();game.hud.toggle_details();await capture("UI_Collapsed")
 game.camera_rig.move_to(Iso.project(game.sim.people[7].position));game.camera_rig.set_step(3);await capture("Cavalry_Closeup")
 game.camera_rig.move_to(Iso.project(game.sim.people.back().position));await capture("Horse_Closeup")
 game.camera_rig.set_step(2);game.camera_rig.move_to(Iso.project(Vector2(15.5,15.5)))
 game.hud.toggle_build();game.hud.toggle_details()
 root.size=Vector2i(960,540);await settle();check(game.camera_rig.viewport_size==root.get_visible_rect().size,"resize updates actual camera transform")
 await capture("UI_Layout_960x540")
 root.size=Vector2i(1600,720);await settle();var wide=await capture("UI_Wide_1600x720")
 check(wide.get_size()==Vector2i(1600,720),"wide window renders the full client area without letterboxing")
 check(absf((game.hud.detail_panel.position.x+game.hud.detail_panel.size.x)*game.hud.scale.x-(root.get_visible_rect().size.x-12*game.hud.scale.x))<2,"wide inspector stays at right edge")
 root.mode=Window.MODE_FULLSCREEN;await settle();await capture("UI_Layout_1080")
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720);await settle()
 # Controlled render fixture, using real sprites and the production renderer.
 game.hud.toggle_build();game.hud.toggle_details();game.hud.selection_kind="overview"
 game.sim.seconds=20
 var index=game.sim.nearest_kind(["house"],Vector2(17,12));var building=game.sim.buildings[index];var centre=Iso.project(Vector2(building.x,building.y))
 game.world.selected_person=-1;game.world.selected_building=-1;game.world.hovered=Vector2i(-1,-1)
 game.camera_rig.set_step(3);game.camera_rig.move_to(centre-Vector2(0,12))
 apply_person(null);var base=await capture("Depth_Base")
 var actor=Citizen.new(0,Vector2i(17,12));actor.position=Iso.unproject(centre-Vector2(0,20));actor.previous=actor.position;actor.clock=0;apply_person(actor)
 var back=await capture("NPC_Behind");var hidden=depth_pixels(back,base,actor,building,true);check(hidden>20,"NPC behind intersects actual building pixels")
 actor.position=Iso.unproject(centre+Vector2(0,20));actor.previous=actor.position;var front=await capture("NPC_Front");var visible=depth_pixels(front,base,actor,building,false);check(visible>20,"NPC in front overlaps building pixels")
 report.depth={"occluded_pixel_checks":hidden,"foreground_pixel_checks":visible}
 var back_actor=Citizen.new(2,Vector2i(17,12));back_actor.position=Iso.unproject(centre+Vector2(-7,-20));back_actor.previous=back_actor.position
 actor.position=Iso.unproject(centre+Vector2(7,20));actor.previous=actor.position
 game.sim.people=[back_actor,actor];game.people=game.sim.people;game.world.people=game.sim.people;game.world.refresh();await capture("NPC_Depth_Test")
 if not "--no-save" in OS.get_cmdline_user_args():
  var f=FileAccess.open(FOLDER+"validation.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
 print("VISUAL_CAPTURE_RESULT checks=",report.checks," failures=",report.failures," depth=",report.depth)
 game.queue_free();quit(0 if report.failures==0 else 1)
