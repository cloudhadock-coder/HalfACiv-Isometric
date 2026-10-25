extends VBoxContainer
# Notices drawn over the map instead of a single status-bar line (Civ2-UI-Additions map-overlay
# popups). Recent entries fade out on their own; the full history stays in the registry.
const LIFETIME=6.0
const VISIBLE=4
const HISTORY=40
var history: Array=[]
var live: Array=[]
var style: StyleBoxFlat
func _init() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;add_theme_constant_override("separation",4)
 style=StyleBoxFlat.new();style.bg_color=Color(0.09,0.15,0.17,0.86);style.border_color=Color("8d7955");style.border_width_left=2;style.set_content_margin_all(6);style.content_margin_left=9
func push(message: String,stamp: String="") -> void:
 history.push_front({"text":message,"stamp":stamp})
 if history.size()>HISTORY:history.pop_back()
 var l=Label.new();l.text=message;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.add_theme_font_size_override("font_size",13);l.add_theme_stylebox_override("normal",style);l.add_theme_color_override("font_color",Color("e4dac4"))
 add_child(l);move_child(l,0);live.push_front({"label":l,"age":0.0})
 while live.size()>VISIBLE:live.pop_back().label.queue_free()
func latest() -> String:
 return history[0].text if not history.is_empty() else ""
func _process(delta: float) -> void:
 for entry in live.duplicate():
  entry.age+=delta;entry.label.modulate.a=clampf(LIFETIME-entry.age,0,1)
  if entry.age>=LIFETIME:live.erase(entry);entry.label.queue_free()
