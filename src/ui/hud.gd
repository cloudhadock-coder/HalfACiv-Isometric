extends CanvasLayer
signal build_selected(kind: String)
signal save_requested
signal load_requested
signal new_requested
signal pause_requested
signal speed_changed(speed: float)
signal profession_changed(kind: int)
signal citizen_selected(index: int)
signal layout_changed
var build_panel: PanelContainer
var detail_panel: PanelContainer
var top_panel: PanelContainer
var action_panel: PanelContainer
var bottom_panel: PanelContainer
var build_scroll: ScrollContainer
var left_tab: Button
var right_tab: Button
const Catalog=preload("res://src/construction/catalog.gd")
const Professions=preload("res://src/entities/professions.gd")
const PortraitRegistry=preload("res://src/ui/portrait_registry.gd")
const PortraitView=preload("res://src/ui/portrait_view.gd")
var resources: Label
var status: Label
var details: RichTextLabel
var portrait
var menu: PanelContainer
var profession: OptionButton
var portrait_note: Label
var title: Label
var hint: Label
var build_list: VBoxContainer
var roster_panel: PanelContainer
var roster_grid: GridContainer
var portraits: Array=[]
var registry
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
 registry=PortraitRegistry.new();portraits=registry.textures
 top_panel=panel(Vector2(12,12),Vector2(923,52));var top=top_panel;var hb=HBoxContainer.new();hb.add_theme_constant_override("separation",20);top.add_child(hb)
 var brand=label("VALE DA AURORA",hb,18);brand.add_theme_color_override("font_color",Color("dfbd72"))
 resources=label("",hb,15);resources.size_flags_horizontal=Control.SIZE_EXPAND_FILL;resources.clip_text=true
 action_panel=panel(Vector2(947,12),Vector2(321,52));var actions=action_panel;var buttons=HBoxContainer.new();actions.add_child(buttons)
 button("Salvar",func():save_requested.emit(),buttons);button("Carregar",func():load_requested.emit(),buttons);button("Menu",func():pause_requested.emit(),buttons)
 build_panel=panel(Vector2(12,80),Vector2(222,293));var vb=VBoxContainer.new();vb.add_theme_constant_override("separation",9);build_panel.add_child(vb)
 var build_heading=HBoxContainer.new();vb.add_child(build_heading)
 label("CONSTRUIR",build_heading,15).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button("◀",toggle_build,build_heading).tooltip_text="Recolher painel de construção [B]"
 var cats=HBoxContainer.new();vb.add_child(cats)
 for pair in [["Moradia","Casas"],["Alimentos","Alim."],["Oficinas","Ofic."],["Comunidade","Vila"]]:
  var key=pair[0];var b=button(pair[1],func():category=key;populate_builds(),cats);b.add_theme_font_size_override("font_size",12)
 build_scroll=ScrollContainer.new();var scroll=build_scroll;scroll.custom_minimum_size=Vector2(196,63);scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;vb.add_child(scroll)
 build_list=VBoxContainer.new();build_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;build_list.add_theme_constant_override("separation",7);scroll.add_child(build_list)
 populate_builds()
 hint=label("Selecione uma construção.\nDepois clique no terreno livre.",vb,12);hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hint.custom_minimum_size=Vector2(190,42)
 button("Cancelar ferramenta [Esc]",func():build_selected.emit("");hint.text="Selecione uma construção.",vb)
 detail_panel=panel(Vector2(1006,80),Vector2(262,564));var dv=VBoxContainer.new();dv.add_theme_constant_override("separation",8);detail_panel.add_child(dv)
 var heads=HBoxContainer.new();dv.add_child(heads);title=label("VIDA NA ALDEIA",heads,16);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title.clip_text=true;title.custom_minimum_size.x=120
 button("↶",func():selection_kind="overview";last_person_kind=-1;show_overview(_sim),heads)
 button("▶",toggle_details,heads).tooltip_text="Recolher informações [I]"
 portrait=PortraitView.new();portrait.custom_minimum_size=Vector2(128,128);dv.add_child(portrait)
 portrait_note=label("Retrato em desenvolvimento",dv,11);portrait_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;portrait_note.add_theme_color_override("font_color",Color("a79d80"))
 profession=OptionButton.new();profession.custom_minimum_size=Vector2(232,34)
 for entry in Professions.DATA:profession.add_item(entry.name)
 profession.item_selected.connect(func(index):profession_changed.emit(index));dv.add_child(profession)
 details=RichTextLabel.new();details.custom_minimum_size=Vector2(232,150);details.size_flags_vertical=Control.SIZE_EXPAND_FILL;details.bbcode_enabled=true;dv.add_child(details)
 button("Habitantes e retratos",toggle_roster,dv)
 button("Companhia e cavalaria [R]",func():get_parent().company_panel.open(),dv)
 bottom_panel=panel(Vector2(12,658),Vector2(1256,50));var bottom=bottom_panel;var bh=HBoxContainer.new();bh.add_theme_constant_override("separation",12);bottom.add_child(bh)
 status=label("",bh,14);status.size_flags_horizontal=Control.SIZE_EXPAND_FILL;status.clip_text=true
 for value in [1,2,4]:
  var speed=value;speed_buttons[value]=button(str(value)+"×",func():speed_changed.emit(float(speed)),bh)
 label("WASD · Roda · Arrastar · F5 salvar | v0.3.0",bh,12)
 menu=panel(Vector2(416,152),Vector2(448,416));var mv=VBoxContainer.new();mv.add_theme_constant_override("separation",15);menu.add_child(mv)
 var logo=label("HALFACIV\nISOMETRIC",mv,32);logo.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;logo.add_theme_color_override("font_color",Color("dfbd72"))
 var subtitle=label("v0.3.0 — Cavalaria e personagens\nCada habitante tem uma história e um ofício.",mv,15);subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 button("Continuar no vale",func():pause_requested.emit(),mv);button("Carregar domínio",func():load_requested.emit(),mv);button("Nova aldeia",func():new_requested.emit(),mv);button("Sair",func():get_tree().quit(),mv)
 roster_panel=panel(Vector2(262,90),Vector2(728,544));var rv=VBoxContainer.new();roster_panel.add_child(rv)
 var rh=HBoxContainer.new();rv.add_child(rh);label("OS ROSTOS DA ALDEIA",rh,20).size_flags_horizontal=Control.SIZE_EXPAND_FILL;button("Fechar",func():roster_panel.hide(),rh)
 var rs=ScrollContainer.new();rs.custom_minimum_size=Vector2(696,468);rs.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;rv.add_child(rs)
 roster_grid=GridContainer.new();roster_grid.columns=5;roster_grid.add_theme_constant_override("h_separation",8);roster_grid.add_theme_constant_override("v_separation",10);rs.add_child(roster_grid);roster_panel.hide()
 left_tab=button("Construir ▶",toggle_build,self);left_tab.theme=theme;left_tab.hide()
 right_tab=button("◀ Informações",toggle_details,self);right_tab.theme=theme;right_tab.hide()
 get_viewport().size_changed.connect(resize);resize();set_speed(1)
func populate_builds() -> void:
 for child in build_list.get_children():child.queue_free()
 for kind in Catalog.DATA:
  var data=Catalog.DATA[kind]
  if data.category!=category:continue
  var key=kind;var b=button(data.name+"\n"+cost_text(data.cost),func():build_selected.emit(key);hint.text=Catalog.DATA[key].name+": clique no mapa.\n"+Catalog.DATA[key].benefit,build_list)
  b.custom_minimum_size=Vector2(190,56);b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.add_theme_font_size_override("font_size",14);b.icon=load("res://assets/tilesets/"+kind+".png");b.expand_icon=true;b.add_theme_constant_override("icon_max_width",32);b.tooltip_text=data.benefit+"\nObra: %ds | Postos: %d"%[data.time,data.slots]
 call_deferred("resize")
func cost_text(cost: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in cost:chunks.append(str(cost[key])+{"wood":" M","stone":" P","gold":" O"}.get(key,""))
 return " · ".join(chunks)
func resource_text(values: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in values:chunks.append("%.1f %s"%[values[key],Catalog.RESOURCE_NAMES.get(key,key)])
 return ", ".join(chunks) if not chunks.is_empty() else "—"
func resize() -> void:
 if bottom_panel==null:return
 var viewport=get_viewport().get_visible_rect().size
 var s=minf(viewport.x/1280.0,viewport.y/720.0);scale=Vector2(s,s)
 var virtual=viewport/s
 action_panel.position.x=virtual.x-333
 top_panel.custom_minimum_size.x=virtual.x-357;top_panel.size.x=virtual.x-357
 bottom_panel.position.y=virtual.y-62;bottom_panel.custom_minimum_size.x=virtual.x-24;bottom_panel.size.x=virtual.x-24
 detail_panel.position.x=virtual.x-274
 var available=virtual.y-156
 detail_panel.custom_minimum_size.y=available;detail_panel.size.y=available
 var count=0
 for kind in Catalog.DATA:
  if Catalog.DATA[kind].category==category:count+=1
 var height=minf(available,230+count*63)
 build_scroll.custom_minimum_size.y=minf(count*63,maxf(63,height-230))
 build_panel.custom_minimum_size.y=height;build_panel.size.y=height
 menu.position=(virtual-menu.size)*0.5
 roster_panel.position=Vector2((virtual.x-728)*0.5,90)
 if left_tab!=null:left_tab.position=Vector2(12,80)
 if right_tab!=null:right_tab.position=Vector2(virtual.x-154,80)
 layout_changed.emit()
func toggle_build() -> void:
 build_panel.visible=not build_panel.visible;left_tab.visible=not build_panel.visible
 resize()
func toggle_details() -> void:
 detail_panel.visible=not detail_panel.visible;right_tab.visible=not detail_panel.visible
 resize()
func useful_map_rect() -> Rect2:
 var viewport=get_viewport().get_visible_rect().size;var s=scale.x
 var left=(build_panel.position.x+build_panel.size.x+12)*s if build_panel.visible else 12*s
 var right=(detail_panel.position.x-12)*s if detail_panel.visible else viewport.x-12*s
 var top=maxf(top_panel.position.y+top_panel.size.y,action_panel.position.y+action_panel.size.y)*s+10*s
 var bottom=bottom_panel.position.y*s-10*s
 return Rect2(Vector2(left,top),Vector2(maxf(64,right-left),maxf(64,bottom-top)))
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
 selection_kind="person";title.text=c.citizen_name;portrait.texture=registry.for_citizen(c);portrait_note.visible=not registry.citizen_is_final(c);profession.visible=not c.horse_only
 if last_person_kind!=c.kind:profession.select(c.kind);last_person_kind=c.kind
 var workplace="Sem posto"
 if _sim!=null and c.employer>=0:workplace=Catalog.DATA[_sim.buildings[c.employer].kind].name
 details.text="[b]"+("Cavalo" if c.horse_only else Professions.name_for(c.kind))+"[/b]\n[color=#dfbd72]"+c.state+"[/color]\n\nPosto: "+workplace+"\nVigor: %d%%\nEntregas: %d\nCarga: %s\n\n"%[c.stamina,c.delivered,resource_text(c.cargo)]+("Descansa no estábulo." if c.horse_only else "Escolha outro ofício acima para redistribuir o trabalho.")
 if not c.specialist.is_empty():details.text+="\n\nContrato: "+c.specialist+" · bônus ativo no ofício de origem"
 if c.mounted or c.horse_only:details.text+="\n\nEquipar montaria: Companhia [R]"
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
  var b=Button.new();b.custom_minimum_size=Vector2(130,130);var face=PortraitView.new();face.texture=registry.for_citizen(c);face.set_anchors_preset(Control.PRESET_FULL_RECT);b.add_child(face);b.tooltip_text=c.citizen_name+" · "+Professions.name_for(c.kind)+"\n"+c.state;b.pressed.connect(func():roster_panel.hide();citizen_selected.emit(index));box.add_child(b)
  var l=label(c.citizen_name,box,12);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
