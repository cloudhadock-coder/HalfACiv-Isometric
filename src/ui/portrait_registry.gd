extends RefCounted

# Resolves NPC portraits through assets/portraits/portraits.json: approved 64x64 art first,
# preserved legacy portrait otherwise. portrait_id indexes the manifest, so saves stay valid.
const MANIFEST="res://assets/portraits/portraits.json"
const LEGACY_COUNT=24
var textures: Array=[]
var final: Array=[]
func _init() -> void:
 var doc=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST)) if FileAccess.file_exists(MANIFEST) else null
 if doc==null:
  push_warning("Portrait manifest missing; using legacy portraits")
  for i in range(LEGACY_COUNT):textures.append(load("res://assets/portraits/"+str(i)+".png"));final.append(false)
  return
 for entry in doc.portraits:
  var approved=entry.status=="approved" and entry.approved!=null and ResourceLoader.exists("res://"+entry.approved)
  textures.append(load("res://"+(entry.approved if approved else entry.fallback)));final.append(approved)
func texture(id: int) -> Texture2D:
 return textures[clampi(id,0,textures.size()-1)]
func is_final(id: int) -> bool:
 return final[clampi(id,0,final.size()-1)]
