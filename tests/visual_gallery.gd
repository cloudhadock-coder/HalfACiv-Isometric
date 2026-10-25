extends SceneTree
func _init() -> void:call_deferred("run")
func run() -> void:
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 game.paused=false;game.hud.menu.hide();game.sim.tick(18);game.hud.update_resources(game.sim);game.hud.toggle_roster()
 await create_timer(0.5).timeout
 root.get_texture().get_image().save_png("res://docs/gallery-v0.2.0.png")
 print("GALLERY_CAPTURE_OK");game.queue_free();quit()
