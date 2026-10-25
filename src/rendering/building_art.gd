extends RefCounted
const DIRECTORY="res://assets/buildings/native_v042/"
var data: Dictionary={}
var textures: Dictionary={}
func _init() -> void:
 var manifest=JSON.parse_string(FileAccess.get_file_as_string(DIRECTORY+"manifest.json"))
 data=manifest.animations
 for kind in data:textures[kind]=load(DIRECTORY+data[kind].atlas)
func frame_index(kind: String,time: float) -> int:
 var entry=data[kind]
 return posmod(int(floor(time*float(entry.fps))),int(entry.count))
func has_native_smoke(kind: String) -> bool:return data.get(kind,{}).get("native_smoke",false)
