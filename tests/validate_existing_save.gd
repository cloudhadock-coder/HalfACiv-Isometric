extends SceneTree
const Store=preload("res://src/persistence/save_store.gd")
func _init() -> void:call_deferred("run")
func run() -> void:
 var path=ProjectSettings.globalize_path("user://realm.json")
 if not FileAccess.file_exists(path):print("PLAYER_SAVE_NOT_AVAILABLE");quit(0);return
 var before=FileAccess.get_sha256(path);var metadata=JSON.parse_string(FileAccess.get_file_as_string(path))
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 Store.PATH=path
 game.load_game();game.paused=true;game.autosave_clock=-1000000;game.hud.menu.hide()
 await process_frame
 await RenderingServer.frame_post_draw
 var error=root.get_texture().get_image().save_png("res://docs/visual-validation/v0.2.1/Existing_Save.png")
 var unchanged=before==FileAccess.get_sha256(path)
 var ok=game.sim.people.size()==metadata.people.size() and game.sim.buildings.size()==metadata.buildings.size() and unchanged and error==OK
 var result={"source_version":metadata.get("version","legacy"),"schema":metadata.schema,"people":game.sim.people.size(),"buildings":game.sim.buildings.size(),"source_file_unchanged":unchanged,"screenshot_error":error,"passed":ok,"offline_seconds":game.sim.offline_seconds}
 var f=FileAccess.open("res://docs/visual-validation/v0.2.1/existing-save.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
 print("EXISTING_SAVE_RESULT ",JSON.stringify(result));game.queue_free();quit(0 if ok else 1)
