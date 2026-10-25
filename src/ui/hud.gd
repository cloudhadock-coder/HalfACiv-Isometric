extends CanvasLayer
# Layout after the classic 4X main screen: a menu bar on top, the map filling the rest, and a right
# column with the world overview, the status box and the selection's information. Construction is
# a floating tool window on the left. The chrome comes from ui_theme.gd.
signal build_selected(kind: String)
signal save_requested
signal load_requested
signal new_requested(settings: Dictionary)
signal pause_requested
signal speed_changed(speed: float)
signal profession_changed(kind: int)
signal citizen_selected(index: int)
signal building_selected(index: int)
signal command(name: String)
signal navigate(world_point: Vector2)
signal layout_changed
const Catalog=preload("res://src/construction/catalog.gd")
const Professions=preload("res://src/entities/professions.gd")
const PortraitRegistry=preload("res://src/ui/portrait_registry.gd")
const PortraitView=preload("res://src/ui/portrait_view.gd")
const Ledger=preload("res://src/ui/village_ledger.gd")
const QuickInfo=preload("res://src/ui/quick_info.gd")
const MessageLog=preload("res://src/ui/message_log.gd")
const UiTheme=preload("res://src/ui/ui_theme.gd")
const Minimap=preload("res://src/ui/minimap.gd")
const MainMenu=preload("res://src/ui/main_menu.gd")
const MARGIN=12
const COLUMN=262
var menu_bar: PanelContainer
var bar_info: Label
var build_panel: PanelContainer
var minimap_panel: PanelContainer
var status_panel: PanelContainer
var detail_panel: PanelContainer
var help_panel: PanelContainer
var build_scroll: ScrollContainer
var left_tab: Button
var right_tab: Button
var minimap
var camera_view: PackedVector2Array=PackedVector2Array()
var realm_label: Label
var date_label: Label
var resources: RichTextLabel
var status: Label
var details: RichTextLabel
var portrait
var menu
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
var _sim
var speed_buttons: Dictionary={}
var category_buttons: Dictionary={}
var quick
var messages
var samples: Array=[]
# Registry (village status window): 0 portraits, 1 villagers, 2 buildings, 3 messages.
var registry_tab: int=0
var registry_count: Label
var tab_buttons: Array=[]
var sort_bar: HBoxContainer
var ledger_list: VBoxContainer
var citizen_sort: Array=["order",false]
var building_sort: Array=["order",false]
func panel(pos: Vector2,size: Vector2) -> PanelContainer:
 var p=PanelContainer.new();p.position=pos;p.custom_minimum_size=size;p.theme=theme;add_child(p);return p
func button(text: String,callback: Callable,parent: Node) -> Button:
 var b=Button.new();b.text=text;b.pressed.connect(callback);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;parent.add_child(b);return b
func label(text: String,parent: Node,size: int=15) -> Label:
 var l=Label.new();l.text=text;l.add_theme_font_size_override("font_size",size);parent.add_child(l);return l
func heading(text: String,parent: Node) -> Label:
 var l=Label.new();l.text=text;l.theme_type_variation="TitleLabel";l.clip_text=true;parent.add_child(l);return l
func menu_entry(parent: Node,text: String,items: Array) -> MenuButton:
 var m=MenuButton.new();m.text=text;m.switch_on_hover=true;parent.add_child(m)
 var popup=m.get_popup();popup.theme=theme;var names=[]
 for item in items:
  if item.is_empty():popup.add_separator();continue
  popup.add_item(item[0],names.size());names.append(item[1])
 popup.id_pressed.connect(func(id):run(names[id]))
 return m
func _ready() -> void:
 theme=UiTheme.build()
 registry=PortraitRegistry.new();portraits=registry.textures
 messages=MessageLog.new();add_child(messages)
 # Menu bar.
 menu_bar=panel(Vector2.ZERO,Vector2(1280,0));menu_bar.theme_type_variation="BarPanel"
 var bar=HBoxContainer.new();bar.add_theme_constant_override("separation",2);menu_bar.add_child(bar)
 menu_entry(bar,"Jogo",[["Salvar  (F5)","save"],["Carregar","load"],[],["Novo mundo…","new_world"],["Menu principal  (Esc)","main_menu"],[],["Sair","quit"]])
 menu_entry(bar,"Aldeia",[["Construir  (B)","build"],["Companhia e cavalaria  (R)","company"],[],["Velocidade 1×  (1)","speed1"],["Velocidade 2×  (2)","speed2"],["Velocidade 4×  (4)","speed4"]])
 menu_entry(bar,"Ver",[["Painel lateral  (I)","details"],["Centralizar a praça  (C)","center"],["Zoom normal  (Ctrl+meio)","zoom"],["Fixar rotas  (Shift)","routes"]])
 menu_entry(bar,"Conselheiros",[["Conselho do domínio  (P)","council"],[],["Moradores  (H)","registry1"],["Edifícios","registry2"],["Retratos","registry0"],["Mensagens","registry3"]])
 menu_entry(bar,"Ajuda",[["Controles","help"]])
 bar_info=label("",bar,13);bar_info.size_flags_horizontal=Control.SIZE_EXPAND_FILL;bar_info.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;bar_info.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;bar_info.add_theme_color_override("font_color",UiTheme.MUTED)
 # Construction tool window.
 build_panel=panel(Vector2(MARGIN,40),Vector2(222,293));var vb=VBoxContainer.new();vb.add_theme_constant_override("separation",8);build_panel.add_child(vb)
 var build_heading=HBoxContainer.new();vb.add_child(build_heading)
 heading("CONSTRUIR",build_heading).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button("◀",toggle_build,build_heading).tooltip_text="Recolher painel de construção [B]"
 var cats=HBoxContainer.new();cats.add_theme_constant_override("separation",3);vb.add_child(cats)
 for pair in [["Moradia","Casas"],["Alimentos","Alim."],["Oficinas","Ofic."],["Comunidade","Vila"]]:
  var key=pair[0];var b=button(pair[1],func():category=key;populate_builds(),cats);b.add_theme_font_size_override("font_size",12);b.toggle_mode=true;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;category_buttons[key]=b
 build_scroll=ScrollContainer.new();var scroll=build_scroll;scroll.custom_minimum_size=Vector2(196,63);scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;vb.add_child(scroll)
 build_list=VBoxContainer.new();build_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;build_list.add_theme_constant_override("separation",5);scroll.add_child(build_list)
 populate_builds()
 hint=label("Selecione uma construção.\nDepois clique no terreno livre.",vb,12);hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hint.custom_minimum_size=Vector2(190,42);hint.add_theme_color_override("font_color",UiTheme.MUTED)
 button("Cancelar ferramenta [Esc]",func():build_selected.emit("");hint.text="Selecione uma construção.",vb)
 # Right column: world overview, status box, selection information.
 minimap_panel=panel(Vector2.ZERO,Vector2(COLUMN,0));minimap=Minimap.new();minimap.custom_minimum_size=Vector2(COLUMN-24,118);minimap.tooltip_text="Clique ou arraste para mover a câmera";minimap_panel.add_child(minimap)
 minimap.navigate.connect(func(point):navigate.emit(point))
 status_panel=panel(Vector2.ZERO,Vector2(COLUMN,0));var sv=VBoxContainer.new();sv.add_theme_constant_override("separation",4);status_panel.add_child(sv)
 realm_label=heading("VALE DA AURORA",sv)
 date_label=label("",sv,14)
 resources=RichTextLabel.new();resources.bbcode_enabled=true;resources.scroll_active=false;resources.fit_content=true;resources.autowrap_mode=TextServer.AUTOWRAP_OFF;resources.add_theme_font_size_override("normal_font_size",14);resources.custom_minimum_size.x=COLUMN-24;sv.add_child(resources)
 status=label("",sv,13);status.add_theme_color_override("font_color",Ledger.COLORS.problem);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;status.custom_minimum_size.x=COLUMN-24;status.hide()
 var speeds=HBoxContainer.new();speeds.add_theme_constant_override("separation",4);sv.add_child(speeds)
 var speed_label=label("Ritmo",speeds,13);speed_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;speed_label.add_theme_color_override("font_color",UiTheme.MUTED)
 for value in [1,2,4]:
  var speed=value;speed_buttons[value]=button(str(value)+"×",func():speed_changed.emit(float(speed)),speeds);speed_buttons[value].add_theme_font_size_override("font_size",13);speed_buttons[value].tooltip_text="Velocidade %d× [%d]"%[value,value]
 detail_panel=panel(Vector2.ZERO,Vector2(COLUMN,300));var dv=VBoxContainer.new();dv.add_theme_constant_override("separation",6);detail_panel.add_child(dv)
 var heads=HBoxContainer.new();heads.add_theme_constant_override("separation",4);dv.add_child(heads);title=heading("VIDA NA ALDEIA",heads);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title.custom_minimum_size.x=120
 button("↶",func():selection_kind="overview";last_person_kind=-1;show_overview(_sim),heads).tooltip_text="Resumo da aldeia"
 button("▶",toggle_details,heads).tooltip_text="Recolher coluna [I]"
 var face_row=HBoxContainer.new();face_row.add_theme_constant_override("separation",8);dv.add_child(face_row)
 portrait=PortraitView.new();portrait.custom_minimum_size=Vector2(104,116);face_row.add_child(portrait)
 var side=VBoxContainer.new();side.size_flags_horizontal=Control.SIZE_EXPAND_FILL;side.add_theme_constant_override("separation",4);face_row.add_child(side)
 for pair in [["Registro [H]",toggle_roster],["Companhia [R]",func():run("company")]]:button(pair[0],pair[1],side).add_theme_font_size_override("font_size",12)
 portrait_note=label("Retrato em desenvolvimento",side,11);portrait_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;portrait_note.custom_minimum_size.x=COLUMN-24-112;portrait_note.add_theme_color_override("font_color",UiTheme.MUTED)
 profession=OptionButton.new();profession.custom_minimum_size=Vector2(COLUMN-24,30)
 for entry in Professions.DATA:profession.add_item(entry.name)
 profession.item_selected.connect(func(index):profession_changed.emit(index));dv.add_child(profession)
 details=RichTextLabel.new();details.custom_minimum_size=Vector2(COLUMN-24,60);details.size_flags_vertical=Control.SIZE_EXPAND_FILL;details.bbcode_enabled=true;details.add_theme_font_size_override("normal_font_size",14);details.add_theme_font_size_override("bold_font_size",14);dv.add_child(details)
 # Registry window.
 roster_panel=panel(Vector2(262,90),Vector2(728,544));var rv=VBoxContainer.new();rv.add_theme_constant_override("separation",8);roster_panel.add_child(rv)
 var rh=HBoxContainer.new();rh.add_theme_constant_override("separation",12);rv.add_child(rh);heading("REGISTRO DA ALDEIA",rh)
 registry_count=label("",rh,13);registry_count.size_flags_horizontal=Control.SIZE_EXPAND_FILL;registry_count.add_theme_color_override("font_color",UiTheme.MUTED)
 button("Fechar [Esc]",func():roster_panel.hide(),rh)
 var tabs=HBoxContainer.new();tabs.add_theme_constant_override("separation",3);rv.add_child(tabs)
 for pair in [[0,"Retratos"],[1,"Moradores"],[2,"Edifícios"],[3,"Mensagens"]]:
  var t=pair[0];var b=button(pair[1],func():registry_tab=t;refresh_registry(),tabs);b.toggle_mode=true;tab_buttons.append(b)
 sort_bar=HBoxContainer.new();sort_bar.add_theme_constant_override("separation",4);rv.add_child(sort_bar)
 var rs=ScrollContainer.new();rs.custom_minimum_size=Vector2(696,392);rs.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;rv.add_child(rs)
 var body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;rs.add_child(body)
 roster_grid=GridContainer.new();roster_grid.columns=5;roster_grid.add_theme_constant_override("h_separation",8);roster_grid.add_theme_constant_override("v_separation",10);body.add_child(roster_grid)
 ledger_list=VBoxContainer.new();ledger_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;ledger_list.add_theme_constant_override("separation",4);body.add_child(ledger_list);roster_panel.hide()
 # Controls reference.
 help_panel=panel(Vector2.ZERO,Vector2(560,0));var hv=VBoxContainer.new();hv.add_theme_constant_override("separation",8);help_panel.add_child(hv)
 var hh=HBoxContainer.new();hv.add_child(hh);heading("CONTROLES",hh).size_flags_horizontal=Control.SIZE_EXPAND_FILL;button("Fechar [Esc]",func():help_panel.hide(),hh)
 var help=RichTextLabel.new();help.bbcode_enabled=true;help.fit_content=true;help.custom_minimum_size.x=530;help.add_theme_font_size_override("normal_font_size",14);hv.add_child(help)
 help.text="[color=#dfbd72]Mapa[/color]\nWASD move · Roda: zoom no cursor · Meio: arrastar ou, num clique, centralizar · Ctrl+meio: zoom normal · C: centralizar a praça\n\n[color=#dfbd72]Seleção[/color]\nClique: morador ou prédio · Ctrl sobre o mapa: ficha rápida · Shift: rotas · Minimapa: clique ou arraste\n\n[color=#dfbd72]Janelas[/color]\nB construção · I coluna lateral · H registro · R companhia · P conselho · Esc fecha a janela aberta ou abre o menu\n\n[color=#dfbd72]Jogo[/color]\nEspaço pausa · 1/2/4 velocidade · F5 salvar"
 help_panel.hide()
 left_tab=button("Construir ▶",toggle_build,self);left_tab.theme=theme;left_tab.hide()
 right_tab=button("◀ Painel",toggle_details,self);right_tab.theme=theme;right_tab.hide()
 menu=MainMenu.new();menu.theme=theme;add_child(menu)
 menu.resume_requested.connect(func():pause_requested.emit());menu.load_requested.connect(func():load_requested.emit());menu.save_requested.connect(func():save_requested.emit());menu.world_requested.connect(func(settings):new_requested.emit(settings))
 quick=QuickInfo.new();quick.theme=theme;add_child(quick)
 get_viewport().size_changed.connect(resize);resize();call_deferred("resize");set_speed(1)
# Menu-bar and panel commands; anything the HUD cannot do itself goes to the game.
func run(name: String) -> void:
 match name:
  "build":toggle_build()
  "details":toggle_details()
  "help":help_panel.visible=not help_panel.visible
  "registry0","registry1","registry2","registry3":open_registry(int(name.right(1)))
  _:command.emit(name)
func open_registry(tab: int) -> void:
 registry_tab=tab;roster_panel.show();refresh_registry()
func populate_builds() -> void:
 for child in build_list.get_children():child.queue_free()
 for key in category_buttons:category_buttons[key].set_pressed_no_signal(key==category)
 for kind in Catalog.DATA:
  var data=Catalog.DATA[kind]
  if data.category!=category:continue
  var key=kind;var b=button(data.name+"\n"+cost_text(data.cost),func():build_selected.emit(key);hint.text=Catalog.DATA[key].name+": clique no mapa.\n"+Catalog.DATA[key].benefit,build_list)
  b.custom_minimum_size=Vector2(190,56);b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.add_theme_font_size_override("font_size",14);b.icon=load("res://assets/buildings/native_v042/"+kind+".png");b.expand_icon=true;b.add_theme_constant_override("icon_max_width",32);b.tooltip_text=data.benefit+"\nObra: %ds | Postos: %d"%[data.time,data.slots]
  b.set_meta("kind",key);b.set_meta("tip",b.tooltip_text)
 if _sim!=null:update_costs(_sim.resources)
 call_deferred("resize")
# Dims options the village cannot pay for and names the shortfall (Change Production costs).
func update_costs(values: Dictionary) -> void:
 for b in build_list.get_children():
  if not b.has_meta("kind"):continue
  var gap=Ledger.missing(Catalog.DATA[b.get_meta("kind")].cost,values)
  b.add_theme_color_override("font_color",UiTheme.TEXT if gap.is_empty() else Color("8f8370"))
  b.tooltip_text=b.get_meta("tip")+("" if gap.is_empty() else "\nFaltam: "+gap)
func cost_text(cost: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in cost:chunks.append(str(cost[key])+{"wood":" M","stone":" P","gold":" O"}.get(key,""))
 return " · ".join(chunks)
func resource_text(values: Dictionary) -> String:
 var chunks=PackedStringArray()
 for key in values:chunks.append("%.1f %s"%[values[key],Catalog.RESOURCE_NAMES.get(key,key)])
 return ", ".join(chunks) if not chunks.is_empty() else "—"
func hud_scale(viewport: Vector2) -> float:
 # The window stretch already scales the canvas (1.5x at 1080p). Pick the HUD scale so the final
 # factor on screen is a whole number from 1x up, keeping the pixel-art chrome exact; windows
 # smaller than 1280x720 still shrink to fit.
 var stretch=get_viewport().get_final_transform().get_scale().x if is_inside_tree() else 1.0
 var s=minf(viewport.x/1280.0,viewport.y/720.0)
 var whole=floorf(s*stretch+0.001)
 return whole/stretch if whole>=1.0 else s
func resize() -> void:
 if detail_panel==null:return
 var viewport=get_viewport().get_visible_rect().size
 var s=hud_scale(viewport);scale=Vector2(s,s)
 var virtual=viewport/s
 menu_bar.custom_minimum_size.x=virtual.x;menu_bar.size=Vector2(virtual.x,menu_bar.get_combined_minimum_size().y)
 var top=menu_bar.size.y+6;var right=virtual.x-COLUMN-MARGIN
 minimap_panel.position=Vector2(right,top)
 status_panel.position=Vector2(right,top+minimap_panel.get_combined_minimum_size().y+6)
 detail_panel.position=Vector2(right,status_panel.position.y+status_panel.get_combined_minimum_size().y+6)
 detail_panel.custom_minimum_size.y=0
 var column=maxf(detail_panel.get_combined_minimum_size().y,virtual.y-MARGIN-detail_panel.position.y)
 detail_panel.custom_minimum_size.y=column;detail_panel.size.y=column
 var count=0
 for kind in Catalog.DATA:
  if Catalog.DATA[kind].category==category:count+=1
 var available=virtual.y-MARGIN-top
 var height=minf(available,226+count*61)
 build_scroll.custom_minimum_size.y=minf(count*61,maxf(61,height-226))
 build_panel.position=Vector2(MARGIN,top);build_panel.custom_minimum_size.y=height;build_panel.size.y=height
 menu.position=Vector2.ZERO;menu.size=virtual
 roster_panel.position=Vector2((virtual.x-728)*0.5,maxf(top,(virtual.y-roster_panel.get_combined_minimum_size().y)*0.5))
 help_panel.position=((virtual-help_panel.get_combined_minimum_size())*0.5).floor()
 left_tab.position=Vector2(MARGIN,top);right_tab.position=Vector2(virtual.x-MARGIN-right_tab.get_combined_minimum_size().x,top)
 messages.position=Vector2((build_panel.position.x+build_panel.size.x+MARGIN) if build_panel.visible else (2*MARGIN+left_tab.get_combined_minimum_size().x),top+4)
 layout_changed.emit()
func toggle_build() -> void:
 build_panel.visible=not build_panel.visible;left_tab.visible=not build_panel.visible
 resize()
func toggle_details() -> void:
 var shown=not detail_panel.visible
 for p in [minimap_panel,status_panel,detail_panel]:p.visible=shown
 right_tab.visible=not shown
 resize()
func useful_map_rect() -> Rect2:
 var viewport=get_viewport().get_visible_rect().size;var s=scale.x
 var left=(build_panel.position.x+build_panel.size.x+MARGIN)*s if build_panel.visible else MARGIN*s
 var right=(detail_panel.position.x-MARGIN)*s if detail_panel.visible else viewport.x-MARGIN*s
 var top=(menu_bar.position.y+menu_bar.size.y+8)*s
 var bottom=viewport.y-MARGIN*s
 return Rect2(Vector2(left,top),Vector2(maxf(64,right-left),maxf(64,bottom-top)))
func set_speed(speed: int) -> void:
 for value in speed_buttons:speed_buttons[value].disabled=value==speed
func clock_text(sim) -> String:
 return "Dia %d · %02d:%02d"%[sim.day(),int(sim.hour()),int(fmod(sim.hour(),1.0)*60)]
func notify(text: String) -> void:
 messages.push(text,clock_text(_sim) if _sim!=null else "")
func resource_cell(icon: String,name: String,amount: String,change: float) -> String:
 var text="[cell][hint=%s][img=12x12]res://assets/ui/icon_%s.png[/img] %s"%[name,icon,amount]
 if absf(change)>=0.5:text+=" [font_size=11][color=#%s]%+d/h[/color][/font_size]"%[Ledger.color_hex("work" if change>0 else "problem"),int(round(change))]
 return text+"[/hint][/cell]"
func update_resources(sim,_delta: float=0.0) -> void:
 if sim!=_sim:samples.clear()
 _sim=sim;Ledger.push_sample(samples,sim.seconds,sim.resources)
 var trend=Ledger.rates(samples,sim.DAY_SECONDS)
 realm_label.text=sim.realm_name().to_upper()
 date_label.text=clock_text(sim)+" · "+Ledger.period(sim.hour())
 bar_info.text=sim.realm_name()+" · "+sim.politics.STAGES[sim.politics.stage]+" · Leg. %d · "%sim.politics.legitimacy+clock_text(sim)
 var cells=resource_cell("people","Moradores / capacidade","%d/%d"%[sim.population,sim.housing_capacity()],0.0)
 for pair in [["influence","Influência"],["food","Alimento"],["wood","Madeira"],["stone","Pedra"],["gold","Ouro"]]:
  cells+=resource_cell(pair[0],pair[1],"%d"%sim.resources[pair[0]],trend.get(pair[0],0.0))
 resources.text="[table=2]"+cells+"[/table]"
 update_costs(sim.resources)
 var warnings=PackedStringArray()
 if sim.resources.food<30:warnings.append("Alimento baixo!")
 if sim.population>=sim.housing_capacity():warnings.append("Sem casas livres para imigrantes.")
 status.text=" ".join(warnings)
 if status.visible==warnings.is_empty():status.visible=not warnings.is_empty();call_deferred("resize")
 minimap.show_world(sim.terrain,sim.buildings,sim.people,camera_view)
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
 details.text="[color=#dfbd72]"+sim.politics.STAGES[sim.politics.stage]+" · Legitimidade %d/100"%sim.politics.legitimacy+"[/color]\nConselho e evolução: P\n\n[color=#dfbd72]Uma aldeia em movimento[/color]\nNo trabalho: %d\nTransportando: %d\nRefeição / descanso: %d\nSem posto: %d\n\n06h–12h / 13h–20h: trabalho\n12h–13h: refeição · 20h–06h: descanso\n\nConstrua casas para receber moradores. Troque os ofícios ao selecionar uma pessoa."%[working,carrying,resting,vacant]
func show_person(c) -> void:
 selection_kind="person";title.text=c.citizen_name;portrait.texture=registry.for_citizen(c);portrait_note.visible=not registry.citizen_is_final(c);profession.visible=not c.horse_only
 if last_person_kind!=c.kind:profession.select(c.kind);last_person_kind=c.kind
 var workplace="Sem posto"
 if _sim!=null and c.employer>=0:workplace=Catalog.DATA[_sim.buildings[c.employer].kind].name
 details.text="[b]"+("Cavalo" if c.horse_only else Professions.name_for(c.kind))+"[/b]\n[color=#"+Ledger.color_hex(Ledger.mood(c))+"]"+c.state+"[/color]\n\nPosto: "+workplace+"\nVigor: %d%%\nEntregas: %d\nCarga: %s\n\n"%[c.stamina,c.delivered,resource_text(c.cargo)]+("Descansa no estábulo." if c.horse_only else "Escolha outro ofício acima para redistribuir o trabalho.")
 if not c.specialist.is_empty():details.text+="\n\nContrato: "+c.specialist+" · bônus ativo no ofício de origem"
 if c.mounted or c.horse_only:details.text+="\n\nEquipar montaria: Companhia [R]"
func show_building(b,index: int=-1) -> void:
 selection_kind="building";var data=Catalog.DATA[b.kind];title.text=data.name;portrait.texture=load("res://assets/buildings/native_v042/"+b.kind+".png");portrait_note.hide();profession.hide()
 var workers=0;var active=0;var names=PackedStringArray()
 if _sim!=null:
  workers=int(_sim.jobs.get(index,0));active=_sim.active_workers(index)
  for c in _sim.people:
   if c.employer==index:names.append(c.citizen_name)
 var adjusted=data.production.duplicate()
 if _sim!=null:
  for key in adjusted:adjusted[key]*=_sim.politics.production_multiplier(key)
 details.text=("[color=#dfbd72]Em obra: %.0fs[/color]"%b.remaining if b.remaining>0 else "[color=#a6bb87]Em funcionamento[/color]")+"\n\n"+data.benefit+"\n\nPostos: %d/%d | Presentes: %d\n"%[workers,data.slots,active]+", ".join(names)+"\n\nProdução máxima/s: "+resource_text(adjusted)+"\nInsumos/s: "+resource_text(data.get("inputs",{}))+"\nAguardando entrega: "+resource_text(b.stored)
 if workers==0 and data.slots>0:details.text+="\n[color=#dda176]Atribua um trabalhador compatível.[/color]"
func quick_info(sim,person: int,building: int,screen: Vector2) -> void:
 var card=""
 if person>=0 and person<sim.people.size():card=Ledger.citizen_card(sim,sim.people[person])
 elif building>=0 and building<sim.buildings.size():card=Ledger.building_card(sim,building)
 if card.is_empty():quick.hide();return
 quick.show_card(card,screen,scale.x,get_viewport().get_visible_rect().size/scale.x)
func toggle_roster() -> void:
 roster_panel.visible=not roster_panel.visible
 if roster_panel.visible:refresh_registry()
func clear(node: Node) -> void:
 for child in node.get_children():node.remove_child(child);child.queue_free()
func sort_button(text: String,key: String,state: Array) -> void:
 var active=state[0]==key
 var b=button(text+((" ▼" if state[1] else " ▲") if active else ""),func():
  if state[0]==key:state[1]=not state[1]
  else:state[0]=key;state[1]=key in ["stamina","staff","stored"]
  refresh_registry(),sort_bar)
 b.add_theme_font_size_override("font_size",12);b.toggle_mode=true;b.set_pressed_no_signal(active)
func ledger_row(cells: Array,callback: Callable,tip: String="") -> Control:
 var row=HBoxContainer.new();row.add_theme_constant_override("separation",10);row.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var holder: Control=row
 if callback.is_valid():
  var b=Button.new();b.custom_minimum_size=Vector2(680,30);b.tooltip_text=tip;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;b.pressed.connect(callback);b.add_child(row)
  row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);row.offset_left=10;row.offset_right=-10;holder=b
 ledger_list.add_child(holder)
 for cell in cells:
  var l=label(cell[0],row,13);l.custom_minimum_size.x=cell[1];l.clip_text=true;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.size_flags_vertical=Control.SIZE_EXPAND_FILL
  if cell.size()>2:l.add_theme_color_override("font_color",cell[2])
 return holder
# Rebuilds the registry snapshot for the active tab; rows select (and the game centres on) the entry.
func refresh_registry() -> void:
 if _sim==null:return
 for i in range(tab_buttons.size()):tab_buttons[i].set_pressed_no_signal(i==registry_tab)
 clear(sort_bar);clear(roster_grid);clear(ledger_list)
 var sites=0
 for b in _sim.buildings:
  if b.remaining>0:sites+=1
 registry_count.text="%d moradores · %d edifícios · %d em obra"%[Ledger.citizen_rows(_sim.people).size(),_sim.buildings.size(),sites]
 roster_grid.visible=registry_tab==0;ledger_list.visible=registry_tab!=0;sort_bar.visible=registry_tab!=3
 if registry_tab<=2:label("Ordenar:",sort_bar,12).add_theme_color_override("font_color",UiTheme.MUTED)
 if registry_tab<=1:
  for pair in Ledger.CITIZEN_SORTS:sort_button(pair[1],pair[0],citizen_sort)
 elif registry_tab==2:
  for pair in Ledger.BUILDING_SORTS:sort_button(pair[1],pair[0],building_sort)
 var gold=Color("dfbd72")
 if registry_tab==0:
  for i in Ledger.citizen_rows(_sim.people,citizen_sort[0],citizen_sort[1]):
   var c=_sim.people[i];var index=i;var box=VBoxContainer.new();roster_grid.add_child(box)
   var b=Button.new();b.custom_minimum_size=Vector2(130,130);var face=PortraitView.new();face.texture=registry.for_citizen(c);face.set_anchors_preset(Control.PRESET_FULL_RECT);b.add_child(face);b.tooltip_text=c.citizen_name+" · "+Professions.name_for(c.kind)+"\n"+c.state;b.pressed.connect(func():roster_panel.hide();citizen_selected.emit(index));box.add_child(b)
   var l=label(c.citizen_name,box,12);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   var mood=label(c.state,box,11);mood.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;mood.clip_text=true;mood.custom_minimum_size.x=130;mood.add_theme_color_override("font_color",Ledger.COLORS[Ledger.mood(c)])
 elif registry_tab==1:
  ledger_row([["Nome",150,gold],["Ofício",140,gold],["Estado",230,gold],["Vigor",60,gold],["Entregas",60,gold]],Callable())
  for i in Ledger.citizen_rows(_sim.people,citizen_sort[0],citizen_sort[1]):
   var c=_sim.people[i];var index=i
   ledger_row([[c.citizen_name,150],[Professions.name_for(c.kind),140],[c.state,230,Ledger.COLORS[Ledger.mood(c)]],["%d%%"%c.stamina,60],[str(c.delivered),60]],func():roster_panel.hide();citizen_selected.emit(index),"Clique para selecionar e centralizar")
 elif registry_tab==2:
  ledger_row([["Edifício",160,gold],["Situação",190,gold],["Postos",100,gold],["Aguardando entrega",200,gold]],Callable())
  for i in Ledger.building_rows(_sim,building_sort[0],building_sort[1]):
   var b=_sim.buildings[i];var data=Catalog.DATA[b.kind];var index=i;var state=Ledger.building_status(_sim,i)
   var staff="%d/%d · %d"%[int(_sim.jobs.get(i,0)),data.slots,_sim.active_workers(i)] if data.slots>0 else "—"
   ledger_row([[data.name,160],[state[0],190,Ledger.COLORS[state[1]]],[staff,100],[Ledger.amounts(b.stored),200]],func():roster_panel.hide();building_selected.emit(index),data.benefit+"\nPostos: ocupados/vagas · presentes")
 else:
  if messages.history.is_empty():ledger_row([["Nenhuma mensagem ainda.",400,Color("a79d80")]],Callable())
  for entry in messages.history:ledger_row([[entry.stamp,130,Color("a79d80")],[entry.text,540]],Callable())
