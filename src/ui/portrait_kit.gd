extends RefCounted

# Portrait parts kit (assets/portraits/kit/kit.json): aligned 64x64 layers drawn in slot order,
# material colours swapped through the ramps baked by tools/portrait_pipeline/kit.py. Nothing is
# drawn or filtered here: every pixel is a kit pixel or a baked ramp colour. Only parts approved
# by a human reviewer are combined; otherwise compose() returns null and the caller keeps the
# NPC's manifest portrait. Same rule as kit.py compose().
const KIT="res://assets/portraits/kit/kit.json"
const SLOTS=["head","clothing","beard","hair","hat"]
const MATERIALS={"skin":"skin","hair":"hair_color","cloth":"cloth"}
const TUNIC_TOP=36
const SIZE=64
static var shared_doc=null
var approved_only: bool
var parts: Dictionary={}
var layers: Dictionary={}
var cache: Dictionary={}
static func kit() -> Dictionary:
 if shared_doc==null:
  shared_doc=JSON.parse_string(FileAccess.get_file_as_string(KIT)) if FileAccess.file_exists(KIT) else null
  if not shared_doc is Dictionary:shared_doc={}
 return shared_doc
static func fits(part: Dictionary,head: String) -> bool:
 return part.slot=="head" or part.fits.has("*") or part.fits.has(head)
# Appearance for a generated villager. Drawn from every part, approved or not, so the face shows
# up as soon as its parts pass review; until then the villager keeps the fallback portrait.
static func recipe(seed: int) -> Dictionary:
 var doc=kit();if doc.is_empty():return {}
 var rng=RandomNumberGenerator.new();rng.seed=seed
 var heads=[]
 for part in doc.parts:
  if part.slot=="head":heads.append(part.id)
 if heads.is_empty():return {}
 var out={"head":heads[rng.randi_range(0,heads.size()-1)]}
 for slot in SLOTS.slice(1):
  var options=[""]
  for part in doc.parts:
   if part.slot==slot and fits(part,out.head):options.append(part.id)
  out[slot]=options[rng.randi_range(0,options.size()-1)]
 for material in MATERIALS:
  var presets=doc.presets[material];out[MATERIALS[material]]=presets[rng.randi_range(0,presets.size()-1)]
 return out
static func valid_recipe(value) -> bool:
 if not value is Dictionary or value.size()>SLOTS.size()+MATERIALS.size():return false
 for key in value:
  if not (SLOTS.has(key) or MATERIALS.values().has(key)) or not value[key] is String or value[key].length()>40:return false
 return true
func _init(only_approved: bool=true) -> void:
 approved_only=only_approved
 for part in kit().get("parts",[]):parts[part.id]=part
func layer(part: Dictionary) -> Image:
 if not layers.has(part.id):
  var image=(load("res://"+part.file) as Texture2D).get_image();image.convert(Image.FORMAT_RGBA8);layers[part.id]=image
 return layers[part.id]
func compose(appearance: Dictionary) -> Image:
 if String(appearance.get("head",""))=="":return null
 var out=Image.create(SIZE,SIZE,false,Image.FORMAT_RGBA8)
 for slot in SLOTS:
  var id=String(appearance.get(slot,""))
  if id=="":continue
  var part=parts.get(id)
  if part==null or part.slot!=slot or (approved_only and part.status!="approved") or not fits(part,appearance.head):return null
  var table={};var cloth={}
  for material in part.materials:
   var target=String(appearance.get(MATERIALS.get(material,""),""))
   if part.recolor.has(material) and part.recolor[material].has(target):
    var from=part.materials[material];var to=part.recolor[material][target]
    for i in range(from.size()):(cloth if material=="cloth" else table)[from[i]]=Color(to[i])
  var lower=table.merged(cloth);var image=layer(part)
  for y in range(SIZE):
   var lookup=lower if y>=TUNIC_TOP else table
   for x in range(SIZE):
    var c=image.get_pixel(x,y)
    if c.a>0:out.set_pixel(x,y,lookup.get("#"+c.to_html(false),c))
 return out
func texture(appearance: Dictionary) -> Texture2D:
 var key=JSON.stringify(appearance,"",true)
 if not cache.has(key):
  var image=compose(appearance) if not appearance.is_empty() else null
  cache[key]=ImageTexture.create_from_image(image) if image!=null else null
 return cache[key]
