extends SceneTree
const Citizen=preload("res://src/entities/citizen.gd")
func _init() -> void:call_deferred("run")
func run() -> void:
 var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
 await process_frame
 game.paused=false;game.hud.menu.hide()
 while game.sim.people.size()<65:
  var c=Citizen.new(6,Vector2i(15,6+game.sim.people.size()%18));c.citizen_name="Patrulheiro";game.sim.people.insert(game.sim.people.size()-1,c)
 game.sim.reassign_jobs();game.sim.population=64
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 await create_timer(1).timeout
 var samples=[];var previous=Time.get_ticks_usec()
 for i in range(360):
  await process_frame
  var now=Time.get_ticks_usec();samples.append(float(now-previous)/1000.0);previous=now
 samples.sort();var total=0.0
 for value in samples:total+=value
 var result={"villagers":64,"frames":360,"average_fps":360000.0/total,"frame_ms_p95":samples[int(samples.size()*0.95)],"adapter":RenderingServer.get_video_adapter_name(),"engine":Engine.get_version_info().string}
 var file=FileAccess.open("res://docs/benchmark-v0.2.0.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"  "));file.close();print("BENCHMARK_RESULT ",JSON.stringify(result));game.queue_free();quit()
