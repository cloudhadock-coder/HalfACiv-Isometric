extends PanelContainer
# Floating card shown while Ctrl is held over a villager or building (Civ2-UI-Additions quickinfo).
var text: RichTextLabel
func _init() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;z_index=20
 text=RichTextLabel.new();text.bbcode_enabled=true;text.fit_content=true;text.scroll_active=false;text.autowrap_mode=TextServer.AUTOWRAP_OFF;text.mouse_filter=Control.MOUSE_FILTER_IGNORE
 text.add_theme_font_size_override("normal_font_size",13);text.add_theme_font_size_override("bold_font_size",14);add_child(text);hide()
func show_card(card: String,screen: Vector2,hud_scale: float,virtual: Vector2) -> void:
 if text.text!=card:text.text=card;reset_size()
 show()
 var anchor=screen/hud_scale+Vector2(18,18)
 if anchor.x+size.x>virtual.x-8:anchor.x=screen.x/hud_scale-size.x-12
 if anchor.y+size.y>virtual.y-8:anchor.y=screen.y/hud_scale-size.y-12
 position=anchor.max(Vector2(8,8))
