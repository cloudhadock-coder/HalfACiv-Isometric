extends CanvasLayer
signal build_selected(kind: String)
signal save_requested
signal load_requested
signal new_requested
signal pause_requested
signal speed_changed(speed: float)
signal profession_changed(kind: int)
signal citizen_selected(index: int)
const Catalog=preload("res://src/construction/catalog.gd")
const Professions=preload("res://src/entities/professions.gd")
var resources: Label
var status: Label
var details: RichTextLabel
var portrait: TextureRect
var menu: PanelContainer
var profession: OptionButton
var portrait_note: Label
var title: Label
var hint: Label
var build_list: VBoxContainer
var roster_panel: PanelContainer
var roster_grid: GridContainer
var portraits: Array=[]
var theme: Theme
var category: String="Moradia"
var selection_kind: String="overview"
var last_person_kind: int=-1
var notification: String=""
var notification_time: float=0
var _sim
var speed_buttons: Dictionary={}
func panel(pos: Vector2,size: Vector2) -> PanelContainer:
 var p=PanelContainer.new();p.position=pos;p.custom_minimum_size=size;p.theme=theme;add_child(p);return p
func button(text: String,callback: Callable,parent: Node) -> Button:
 var b=Button.new();b.text=text;b.pressed.connect(callback);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;parent.add_child(b);return b
func label(text: String,parent: Node,size: int=15) -> Label:
 var l=Label.new();l.text=text;l.add_theme_font_size_override("font_size",size);parent.add_child(l);return l
func _ready() -> void:
 theme=Theme.new()
 var style=StyleBoxFlat.new();style.bg_color=Color("17252b");style.border_color=Color("8d7955");style.set_border_width_all(1);style.set_content_margin_all(12);style.set_corner_radius_all(3)
 theme.set_stylebox("panel","PanelContainer",style)
 var bs=style.duplicate();bs.bg_color=Color("283b3f");bs.set_content_margin_all(8);theme.set_stylebox("normal","Button",bs);theme.set_stylebox("normal","OptionButton",bs)
 var hover=bs.duplicate();hover.bg_color=Color("44574c");theme.set_stylebox("hover","Button",hover);theme.set_stylebox("pressed","Button",hover)
 theme.set_color("font_color","Label",Color("e4dac4"));theme.set_color("font_color","Button",Color("e4dac4"));theme.default_font_size=15
 for i in range(24):portraits.append(load("res://assets/portraits/"+str(i)+".png"))
 var top=panel(Vector2(12,12),Vector2(923,52));var hb=HBoxContainer.new();hb.add_theme_constant_override("separation",20);top.add_child(hb)
 var brand=label("VALE DA AURORA",hb,18);brand.add_theme_color_override("font_color",Color("dfbd72"))
 resources=label("",hb,15)
 var actions=panel(Vector2(947,12),Vector2(321,52));var buttons=HBoxContainer.new();actions.add_child(buttons)
 button("Salvar",func():save_requested.emit(),buttons);button("Carregar",func():load_requested.emit(),buttons);button("Menu",func():pause_requested.emit(),buttons)
 var build_panel=panel(Vector2(12,80),Vector2(222,564));var vb=VBoxContainer.new();vb.add_theme_constant_override("separation",9);build_panel.add_child(vb)
 label("CONSTRUIR A ALDEIA",vb,16)
 var cats=HBoxContainer.new();vb.add_child(cats)
 for pair in [["Moradia","Casas"],["Alimentos","Alim."],["Oficinas","Ofic."],["Comunidade","Vila"]]:
  var key=pair[0];var b=button(pair[1],func():category=key;populate_builds(),cats);b.add_theme_font_size_override("font_size",12)
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(196,364);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;vb.add_child(scroll)
 build_list=VBoxContainer.new();build_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;build_list.add_theme_constant_override("separation",7);scroll.add_child(build_list)
 populate_builds()
 hint=label("Selecione uma construção.\nDepois clique no terreno livre.",vb,12);hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hint.custom_minimum_size=Vector2(190,42)
 button("Cancelar ferramenta [Esc]",func():build_selected.emit("");hint.text="Selecione uma construção.",vb)
 var detail_panel=panel(Vector2(1006,80),Vector2(262,564));var dv=VBoxContainer.new();dv.add_theme_constant_override("separation",8);detail_panel.add_child(dv)
 var heads=HBoxContainer.new();dv.add_child(heads);title=label("VIDA NA ALDEIA",heads,16);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button("↶",func():selection_kind="overview";last_person_kind=-1;show_overview(_sim),heads)
 portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(96,112);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;dv.add_child(portrait)
 portrait_note=label("Retrato em desenvolvimento",dv,11);portrait_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;portrait_note.add_theme_color_override("font_color",Color("a79d80"))
 profession=OptionButton.new();profession.custom_minimum_size=Vector2(232,34)
 for entry in Professions.DATA:profession.add_item(entry.name)
 profession.item_selected.connect(func(index):profession_changed.emit(index));dv.add_child(profession)
 details=RichTextLabel.new();details.custom_minimum_size=Vector2(232,233);details.bbcode_enabled=true;dv.add_child(details)
 button("Habitantes e retratos",toggle_roster,dv)
 var bottom=panel(Vector2(12,658),Vector2(1256,50));var bh=HBoxContainer.new();bh.add_theme_constant_override("separation",12);bottom.add_child(bh)
 status=label("",bh,14);status.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 for value in [1,2,4]:
  var speed=value;speed_buttons[value]=button(str(value)+"×",func():speed_changed.emit(float(speed)),bh)
 label("WASD · Roda · Arrastar · F5 salvar | v0.2.0",bh,12)
 menu=panel(Vector2(416,152),Vector2(448,416));var mv=VBoxContainer.new();mv.add_theme_constant_override("separation",15);menu.add_child(mv)
 var logo=label("HALFACIV\nISOMETRIC",mv,32);logo.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;logo.add_theme_color_override("font_color",Color("dfbd72"))
 var subtitle=label("v0.2.0 — Vida na aldeia\nCada habitante tem uma história e um ofício.",mv,15);subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 button("Continuar no vale",func():pause_requested.emit(),mv);button("Carregar domínio",func():load_requested.emit(),mv);button("Nova aldeia",func():new_requested.emit(),mv);button("Sair",func():get_tree().quit(),mv)
 roster_panel=panel(Vector2(262,90),Vector2(728,544));var rv=VBoxContainer.new();roster_panel.add_child(rv)
 var rh=HBoxContainer.new();rv.add_child(rh);label("OS ROSTOS DA ALDEIA",rh,20).size_flags_horizontal=Control.SIZE_EXPAND_FILL;button("Fechar",func():roster_panel.hide(),rh)
 var rs=ScrollContainer.new();rs.custom_minimum_size=Vector2(696,468);rs.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;rv.add_child(rs)
 roster_grid=GridContainer.new();roster_grid.columns=6;roster_grid.add_theme_constant_override("h_separation",8);roster_grid.add_theme_constant_override("v_separation",10);rs.add_child(roster_grid);roster_panel.hide()
 get_viewport().size_changed.connect(resize);resize();set_speed(1)
func populate_builds() -> void:
 for child in build_list.get_children():child.queue_free()
 for kind in Catalog.DATA:
  var data=Catalog.DATA[kind]
  if data.category!=category:continue
  var key=kind;var b=button(data.name+"\n"+cost_text(data.cost),func():build_selected.emit(key);hint.text=Catalog.DATA[key].name+": clique no mapa.\n"+Catalog.DATA[key].benefit,build_list)
  b.custom_minimum_size=Vector2(190,56);b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.add_theme_font_size_override("font_size",14);b.icon=load("res://assets/tilesets/"+kind+".png");b.expand_icon=true;b.add_theme_constant_override("icon_max_width",32);b.tooltip_text=data.benefit+"\nObra: %ds | Postos: %d"%[data.time,data.slots]
func cost_text(cost: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in cost:chunks.append(str(cost[key])+{"wood":" M","stone":" P","gold":" O"}.get(key,""))
 return " · ".join(chunks)
func resource_text(values: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in values:chunks.append("%.1f %s"%[values[key],Catalog.RESOURCE_NAMES.get(key,key)])
 return ", ".join(chunks) if not chunks.is_empty() else "—"
func resize() -> void:
 var size=get_viewport().get_visible_rect().size;var s=minf(size.x/1280.0,size.y/720.0);scale=Vector2(s,s)
func set_speed(speed: int) -> void:
 for value in speed_buttons:speed_buttons[value].disabled=value==speed
func notify(text: String) -> void:
 notification=text;notification_time=5
func update_resources(sim,delta: float=0.0) -> void:
 _sim=sim;notification_time=maxf(0,notification_time-delta)
 resources.text="Alimento %d   Madeira %d   Pedra %d   Ouro %d   Influência %d"%[sim.resources.food,sim.resources.wood,sim.resources.stone,sim.resources.gold,sim.resources.influence]
 var hour=int(sim.hour());var minute=int(fmod(sim.hour(),1.0)*60)
 status.text="Dia %d · %02d:%02d | Moradores %d/%d"%[sim.day(),hour,minute,sim.population,sim.housing_capacity()]
 if notification_time>0:status.text+=" | "+notification
 elif sim.resources.food<30:status.text+=" | Alimento baixo!"
 if selection_kind=="overview":show_overview(sim)
func show_overview(sim) -> void:
 if sim==null:return
 selection_kind="overview";title.text="VIDA NA ALDEIA";portrait.texture=portraits[9];portrait_note.hide();profession.hide()
 var working=0;var carrying=0;var resting=0;var vacant=0
 for c in sim.people:
  if c.horse_only:continue
  if c.task in ["work","build"]:working+=1
  if not c.cargo.is_empty():carrying+=1
  if c.task in ["sleep","meal"]:resting+=1
  if c.employer<0 and not Professions.patrol(c.kind) and c.kind not in [4,22]:vacant+=1
 details.text="[color=#dfbd72]Uma aldeia em movimento[/color]\n\nNo trabalho: %d\nTransportando: %d\nRefeição / descanso: %d\nSem posto: %d\n\n06h–12h / 13h–20h: trabalho\n12h–13h: refeição\n20h–06h: descanso\n\nConstrua casas para receber moradores. Troque os ofícios ao selecionar uma pessoa."%[working,carrying,resting,vacant]
func show_person(c) -> void:
 selection_kind="person";title.text=c.citizen_name;portrait.texture=portraits[c.portrait_id];portrait_note.show();profession.visible=not c.horse_only
 if last_person_kind!=c.kind:profession.select(c.kind);last_person_kind=c.kind
 var workplace="Sem posto"
 if _sim!=null and c.employer>=0:workplace=Catalog.DATA[_sim.buildings[c.employer].kind].name
 details.text="[b]"+("Cavalo" if c.horse_only else Professions.name_for(c.kind))+"[/b]\n[color=#dfbd72]"+c.state+"[/color]\n\nPosto: "+workplace+"\nVigor: %d%%\nEntregas: %d\nCarga: %s\n\n"%[c.stamina,c.delivered,resource_text(c.cargo)]+("Descansa no estábulo." if c.horse_only else "Escolha outro ofício acima para redistribuir o trabalho.")
func show_building(b,index: int=-1) -> void:
 selection_kind="building";var data=Catalog.DATA[b.kind];title.text=data.name;portrait.texture=load("res://assets/tilesets/"+b.kind+".png");portrait_note.hide();profession.hide()
 var workers=0;var active=0;var names=PackedStringArray()
 if _sim!=null:
  workers=int(_sim.jobs.get(index,0));active=_sim.active_workers(index)
  for c in _sim.people:
   if c.employer==index:names.append(c.citizen_name)
 details.text=("[color=#dfbd72]Em obra: %.0fs[/color]"%b.remaining if b.remaining>0 else "[color=#a6bb87]Em funcionamento[/color]")+"\n\n"+data.benefit+"\n\nPostos: %d/%d | Presentes: %d\n"%[workers,data.slots,active]+", ".join(names)+"\n\nProdução máxima/s: "+resource_text(data.production)+"\nInsumos/s: "+resource_text(data.get("inputs",{}))+"\nAguardando entrega: "+resource_text(b.stored)
 if workers==0 and data.slots>0:details.text+="\n[color=#dda176]Atribua um trabalhador compatível.[/color]"
func toggle_roster() -> void:
 roster_panel.visible=not roster_panel.visible
 if not roster_panel.visible or _sim==null:return
 for child in roster_grid.get_children():child.queue_free()
 for i in range(_sim.people.size()):
  var c=_sim.people[i]
  if c.horse_only:continue
  var index=i;var box=VBoxContainer.new();roster_grid.add_child(box)
  var b=TextureButton.new();b.texture_normal=portraits[c.portrait_id];b.custom_minimum_size=Vector2(104,112);b.ignore_texture_size=true;b.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED;b.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;b.tooltip_text=c.citizen_name+" · "+Professions.name_for(c.kind)+"\n"+c.state;b.pressed.connect(func():roster_panel.hide();citizen_selected.emit(index));box.add_child(b)
  var l=label(c.citizen_name,box,12);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
