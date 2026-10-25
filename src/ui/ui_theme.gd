extends RefCounted
# HUD theme built from assets/ui (tools/ui_pipeline/build_ui.py). Frames are 9-slice with tiled
# centres so the dither stays pixel-exact; the HUD scales only by whole numbers from 1x up (hud.gd).
# Replacing a PNG with hand-drawn art only requires keeping its size and the margins below.
const TEXT=Color("e4dac4")
const BRIGHT=Color("f4ecd8")
const GOLD=Color("dfbd72")
const MUTED=Color("a79d80")
const DISABLED=Color("7d7666")
static func box(file: String,margin: int,content: Vector4) -> StyleBoxTexture:
 var s=StyleBoxTexture.new();s.texture=load("res://assets/ui/"+file+".png")
 s.texture_margin_left=margin;s.texture_margin_top=margin;s.texture_margin_right=margin;s.texture_margin_bottom=margin
 s.axis_stretch_horizontal=StyleBoxTexture.AXIS_STRETCH_MODE_TILE;s.axis_stretch_vertical=StyleBoxTexture.AXIS_STRETCH_MODE_TILE
 s.content_margin_left=content.x;s.content_margin_top=content.y;s.content_margin_right=content.z;s.content_margin_bottom=content.w
 return s
static func icon(name: String) -> Texture2D:
 return load("res://assets/ui/icon_"+name+".png")
static func build() -> Theme:
 var t=Theme.new();t.default_font_size=15
 var frame=box("panel",6,Vector4(12,10,12,10))
 t.set_stylebox("panel","PanelContainer",frame)
 t.set_stylebox("panel","PopupMenu",box("panel",6,Vector4(6,6,6,6)))
 t.set_stylebox("hover","PopupMenu",box("button_hover",3,Vector4(6,3,6,3)))
 t.set_color("font_color","PopupMenu",TEXT);t.set_color("font_hover_color","PopupMenu",BRIGHT);t.set_color("font_disabled_color","PopupMenu",DISABLED);t.set_color("font_accelerator_color","PopupMenu",MUTED)
 t.set_stylebox("panel","TooltipPanel",box("panel",6,Vector4(9,7,9,7)));t.set_color("font_color","TooltipLabel",TEXT)
 var states={"normal":"button_normal","hover":"button_hover","pressed":"button_pressed","hover_pressed":"button_pressed","disabled":"button_disabled"}
 for type in ["Button","OptionButton","CheckButton"]:
  for state in states:t.set_stylebox(state,type,box(states[state],3,Vector4(9,5,9,5)))
  t.set_stylebox("focus",type,StyleBoxEmpty.new())
  t.set_color("font_color",type,TEXT);t.set_color("font_hover_color",type,BRIGHT);t.set_color("font_pressed_color",type,GOLD);t.set_color("font_hover_pressed_color",type,GOLD);t.set_color("font_focus_color",type,TEXT);t.set_color("font_disabled_color",type,DISABLED)
 # Menu bar entries are flat until hovered, like a classic window menu.
 var flat=StyleBoxEmpty.new();flat.content_margin_left=10;flat.content_margin_right=10;flat.content_margin_top=3;flat.content_margin_bottom=3
 t.set_stylebox("normal","MenuButton",flat);t.set_stylebox("focus","MenuButton",StyleBoxEmpty.new())
 for state in ["hover","pressed","hover_pressed"]:t.set_stylebox(state,"MenuButton",box("button_hover",3,Vector4(10,3,10,3)))
 t.set_color("font_color","MenuButton",TEXT);t.set_color("font_hover_color","MenuButton",BRIGHT);t.set_color("font_pressed_color","MenuButton",GOLD);t.set_color("font_hover_pressed_color","MenuButton",GOLD)
 t.set_stylebox("normal","LineEdit",box("button_field",3,Vector4(8,5,8,5)));t.set_stylebox("focus","LineEdit",box("button_field",3,Vector4(8,5,8,5)))
 t.set_color("font_color","LineEdit",TEXT);t.set_color("caret_color","LineEdit",GOLD);t.set_color("selection_color","LineEdit",Color(0.55,0.47,0.33,0.6))
 for type in ["VScrollBar","HScrollBar"]:
  t.set_stylebox("scroll",type,box("button_field",3,Vector4(2,2,2,2)))
  for state in ["grabber","grabber_highlight","grabber_pressed"]:t.set_stylebox(state,type,box("grabber",2,Vector4(3,3,3,3)))
 t.set_color("font_color","Label",TEXT);t.set_color("default_color","RichTextLabel",TEXT)
 # Variations: window titles, the menu bar strip and secondary text.
 t.set_type_variation("TitleLabel","Label");t.set_stylebox("normal","TitleLabel",box("title",3,Vector4(8,3,8,6)));t.set_color("font_color","TitleLabel",GOLD);t.set_font_size("font_size","TitleLabel",15)
 t.set_type_variation("BarPanel","PanelContainer");t.set_stylebox("panel","BarPanel",box("bar",3,Vector4(6,1,6,4)))
 t.set_type_variation("MutedLabel","Label");t.set_color("font_color","MutedLabel",MUTED);t.set_font_size("font_size","MutedLabel",12)
 return t
