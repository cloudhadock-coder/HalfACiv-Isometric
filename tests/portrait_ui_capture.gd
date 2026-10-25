extends SceneTree
# Captures the real HUD showing portraits (roster and detail panel) for docs/portrait-validation/
# and proves the portrait reaches the screen pixel-identical (whole-number scale, no resampling),
# both at 1280x720 and under the 1.5x window stretch of 1920x1080.
const Store=preload("res://src/persistence/save_store.gd")
const FOLDER="res://docs/portrait-validation/"
var failures: int=0
var checks: int=0
func _init() -> void:call_deferred("run")
func shot(name: String) -> Image:
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var image=root.get_texture().get_image();if "--no-save" not in OS.get_cmdline_user_args():image.save_png(FOLDER+name)
 return image
func pixel_exact(screen: Image,view,label: String) -> void:
 # Expected: every texture pixel becomes a k x k block of identical screen pixels.
 checks+=1
 var art=view.texture.get_image();art.convert(Image.FORMAT_RGBA8);screen.convert(Image.FORMAT_RGBA8)
 var k=view.display_scale();var t=view.to_screen();var g=view.screen_factor();var shown=Vector2(art.get_size())*k
 var origin=(t.origin+(view.size*g-shown)/2).floor()
 for y in range(art.get_height()*k):
  for x in range(art.get_width()*k):
   var expected=art.get_pixel(x/k,y/k)
   if expected.a<1.0:continue
   if not screen.get_pixel(int(origin.x)+x,int(origin.y)+y).is_equal_approx(expected):
    failures+=1;push_error(label+" differs at "+str(Vector2i(x,y)));return
 print("PORTRAIT_PIXEL_EXACT ",label," scale=",k," stretch=",g)
func run() -> void:
 Store.PATH="res://tests/portrait-capture-save.json"
 root.size=Vector2i(1280,720)
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 for i in range(6):await process_frame
 if game.paused:game.toggle_pause()
 game.hud.toggle_roster();var roster=await shot("ui-roster.png")
 var first=game.hud.roster_grid.get_child(0).get_child(0).get_child(0);pixel_exact(roster,first,"roster 720p")
 game.hud.roster_grid.get_child(9).get_child(0).pressed.emit();var detail=await shot("ui-detail-panel.png")
 pixel_exact(detail,game.hud.portrait,"detail 720p")
 root.size=Vector2i(1920,1080);for i in range(4):await process_frame
 var wide=await shot("ui-detail-panel-1080p.png");pixel_exact(wide,game.hud.portrait,"detail 1080p")
 game.queue_free();await process_frame
 if FileAccess.file_exists(Store.PATH):DirAccess.remove_absolute(ProjectSettings.globalize_path(Store.PATH))
 print("PORTRAIT_UI_RESULT checks=",checks," failures=",failures)
 quit(1 if failures else 0)
