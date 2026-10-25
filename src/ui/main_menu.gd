extends Control
# Main and pause menu: one column of actions, each with a keyboard shortcut, a card summarising the
# saved realm, a random world in one click and a setup page with a live preview of the seed.
signal resume_requested
signal load_requested
signal save_requested
signal world_requested(settings: Dictionary)
const WorldGen=preload("res://src/world/world_gen.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Minimap=preload("res://src/ui/minimap.gd")
var mode: String="start"
var main_page: VBoxContainer
var setup_page: VBoxContainer
var card: Label
var actions: VBoxContainer
var shortcuts: Dictionary={}
var name_edit: LineEdit
var seed_edit: LineEdit
var landscape: OptionButton
var bounty: OptionButton
var preview
var preview_note: Label
var name_follows_seed: bool=true
var preview_clock: float=-1
var draft: Dictionary={}
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 var shade=ColorRect.new();shade.color=Color(0.03,0.06,0.07,0.8);shade.set_anchors_preset(Control.PRESET_FULL_RECT);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(shade)
 var centre=CenterContainer.new();centre.set_anchors_preset(Control.PRESET_FULL_RECT);add_child(centre)
 var frame=PanelContainer.new();frame.custom_minimum_size.x=540;centre.add_child(frame)
 var column=VBoxContainer.new();column.add_theme_constant_override("separation",10);frame.add_child(column)
 var logo=Label.new();logo.text="HALFACIV ISOMETRIC";logo.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;logo.add_theme_font_size_override("font_size",30);logo.add_theme_color_override("font_color",Color("dfbd72"));column.add_child(logo)
 var subtitle=Label.new();subtitle.text="v"+str(ProjectSettings.get_setting("application/config/version","0.3.0"))+" · estratégia e vida medieval";subtitle.theme_type_variation="MutedLabel";subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(subtitle)
 main_page=VBoxContainer.new();main_page.add_theme_constant_override("separation",8);column.add_child(main_page)
 card=Label.new();card.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;card.theme_type_variation="TitleLabel";card.custom_minimum_size.x=500;main_page.add_child(card)
 actions=VBoxContainer.new();actions.add_theme_constant_override("separation",6);main_page.add_child(actions)
 var tip=Label.new();tip.text="Setas e Enter também navegam pelas opções.";tip.theme_type_variation="MutedLabel";tip.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;main_page.add_child(tip)
 setup_page=VBoxContainer.new();setup_page.add_theme_constant_override("separation",8);column.add_child(setup_page);build_setup()
 open("start")
func action(text: String,key: String,code: int,callback: Callable) -> Button:
 var b=Button.new();b.text=text;b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.custom_minimum_size=Vector2(500,38);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;b.pressed.connect(callback);actions.add_child(b)
 var hint=Label.new();hint.text=key;hint.theme_type_variation="MutedLabel";hint.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE);hint.offset_left=-90;hint.offset_right=-12;hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;hint.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;b.add_child(hint)
 shortcuts[code]=callback
 if actions.get_child_count()==1:shortcuts[KEY_ENTER]=callback;shortcuts[KEY_KP_ENTER]=callback
 return b
func age_text(saved_at: int) -> String:
 var minutes=maxi(0,int(Time.get_unix_time_from_system())-saved_at)/60
 if saved_at<=0:return ""
 if minutes<1:return "agora há pouco"
 if minutes<60:return "há %d min"%minutes
 if minutes<60*48:return "há %d h"%(minutes/60)
 return "há %d dias"%(minutes/1440)
func open(next_mode: String) -> void:
 mode=next_mode;show();show_main()
func show_main() -> void:
 main_page.show();setup_page.hide();shortcuts.clear()
 for child in actions.get_children():actions.remove_child(child);child.queue_free()
 var saved=Store.summary()
 card.text=("Domínio salvo: %s · Dia %d · %d moradores%s"%[saved.name,saved.day,saved.population,(" · "+age_text(saved.saved_at)) if saved.saved_at>0 else ""]) if not saved.is_empty() else "Nenhum domínio salvo. Comece um mundo novo ou o mapa clássico."
 if mode=="pause":
  action("Voltar ao jogo","Esc",KEY_ESCAPE,func():resume_requested.emit())
  action("Salvar domínio","F5",KEY_F5,func():save_requested.emit();show_main())
  if not saved.is_empty():action("Carregar: "+saved.name,"L",KEY_L,func():load_requested.emit())
 elif not saved.is_empty():action("Continuar: "+saved.name,"Enter",KEY_C,func():load_requested.emit())
 action("Novo mundo aleatório","N",KEY_N,func():world_requested.emit(WorldGen.random_settings()))
 action("Personalizar mundo…","P",KEY_P,show_setup)
 action("Mapa clássico: Vale da Aurora","V",KEY_V,func():world_requested.emit({}))
 action("Sair do jogo","Q",KEY_Q,func():get_tree().quit())
 if is_inside_tree() and actions.get_child_count()>0:actions.get_child(0).call_deferred("grab_focus")
func row(grid: GridContainer,text: String,control: Control,extra: Control=null) -> void:
 var l=Label.new();l.text=text;grid.add_child(l)
 var box=HBoxContainer.new();box.add_theme_constant_override("separation",6);box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(box)
 control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_child(control)
 if extra!=null:box.add_child(extra)
func dice(callback: Callable) -> Button:
 var b=Button.new();b.text="Sortear";b.tooltip_text="Valor aleatório";b.pressed.connect(callback);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;return b
func build_setup() -> void:
 var heading=Label.new();heading.text="NOVO MUNDO";heading.theme_type_variation="TitleLabel";setup_page.add_child(heading)
 var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",6);setup_page.add_child(grid)
 name_edit=LineEdit.new();name_edit.max_length=40;name_edit.placeholder_text="Nome da aldeia"
 name_edit.text_changed.connect(func(_text):name_follows_seed=false;schedule())
 row(grid,"Nome",name_edit,dice(func():name_follows_seed=true;sync_name()))
 seed_edit=LineEdit.new();seed_edit.placeholder_text="Número ou palavra";seed_edit.max_length=24
 seed_edit.text_changed.connect(func(_text):sync_name();schedule())
 seed_edit.text_submitted.connect(func(_text):start())
 row(grid,"Semente",seed_edit,dice(func():seed_edit.text=str(WorldGen.random_settings().seed);sync_name();schedule()))
 landscape=OptionButton.new();landscape.add_item("Pela semente")
 for key in WorldGen.LANDSCAPES:landscape.add_item(WorldGen.LANDSCAPE_NAMES[key])
 landscape.item_selected.connect(func(_index):schedule());row(grid,"Paisagem",landscape)
 bounty=OptionButton.new()
 for key in WorldGen.BOUNTIES:bounty.add_item(WorldGen.BOUNTY_NAMES[key])
 bounty.select(1);bounty.item_selected.connect(func(_index):schedule());row(grid,"Recursos",bounty)
 preview=Minimap.new();preview.interactive=false;preview.mouse_default_cursor_shape=Control.CURSOR_ARROW;preview.custom_minimum_size=Vector2(500,250);setup_page.add_child(preview)
 preview_note=Label.new();preview_note.theme_type_variation="MutedLabel";preview_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;setup_page.add_child(preview_note)
 var buttons=HBoxContainer.new();buttons.add_theme_constant_override("separation",8);setup_page.add_child(buttons)
 var back=Button.new();back.text="Voltar  [Esc]";back.pressed.connect(show_main);back.size_flags_horizontal=Control.SIZE_EXPAND_FILL;buttons.add_child(back)
 var go=Button.new();go.text="Fundar aldeia  [Enter]";go.pressed.connect(start);go.size_flags_horizontal=Control.SIZE_EXPAND_FILL;buttons.add_child(go)
func show_setup() -> void:
 main_page.hide();setup_page.show()
 seed_edit.text=str(WorldGen.random_settings().seed);landscape.select(0);bounty.select(1);name_follows_seed=true;sync_name();refresh_preview()
func settings() -> Dictionary:
 var chosen=WorldGen.LANDSCAPES[landscape.selected-1] if landscape.selected>0 else ""
 return WorldGen.normalize({"seed":WorldGen.seed_from_text(seed_edit.text),"landscape":chosen,"bounty":WorldGen.BOUNTIES[bounty.selected],"name":name_edit.text})
func sync_name() -> void:
 if name_follows_seed:name_edit.set_block_signals(true);name_edit.text=WorldGen.name_for(WorldGen.seed_from_text(seed_edit.text));name_edit.set_block_signals(false)
func schedule() -> void:
 preview_clock=0.25
func _process(delta: float) -> void:
 if preview_clock<0:return
 preview_clock-=delta
 if preview_clock<0:refresh_preview()
func refresh_preview() -> void:
 preview_clock=-1;draft=settings()
 var made=WorldGen.generate(draft);var sites=[]
 for entry in made.buildings:sites.append({"kind":entry[0],"x":entry[1],"y":entry[2]})
 preview.show_world(made.terrain,sites)
 var water=0;var trees=0
 for cell in made.terrain:
  if made.terrain[cell]=="water":water+=1
  elif made.terrain[cell]=="tree":trees+=1
 preview_note.text="%s · semente %d · %s · água %d%% · floresta %d%% · %d edifícios"%[draft.name,draft.seed,WorldGen.LANDSCAPE_NAMES[draft.landscape],water*100/made.terrain.size(),trees*100/made.terrain.size(),made.buildings.size()]
func start() -> void:
 world_requested.emit(settings())
func _unhandled_key_input(event: InputEvent) -> void:
 if not visible or not event.pressed or event.echo:return
 # The menu owns the keyboard while open, so map shortcuts never act behind it.
 get_viewport().set_input_as_handled()
 if setup_page.visible:
  if event.keycode in [KEY_ENTER,KEY_KP_ENTER]:start()
  elif event.keycode==KEY_ESCAPE:show_main()
 elif shortcuts.has(event.keycode):shortcuts[event.keycode].call()
