extends PanelContainer
const Realm=preload("res://src/politics/realm.gd")
var game
var content: VBoxContainer
var body: VBoxContainer
var heading: Label
var summary: Label
var pending_label: Label
var tab: int=0
var refresh_clock: float=0
func _ready() -> void:
 theme=game.hud.theme;z_index=6
 content=VBoxContainer.new();content.add_theme_constant_override("separation",8);add_child(content)
 hide();get_viewport().size_changed.connect(resize)
func resize() -> void:
 var area=get_viewport_rect().size/game.hud.scale.x
 custom_minimum_size=Vector2(minf(760,area.x-32),minf(600,area.y-80));size=custom_minimum_size
 position=((area-size)/2).floor()
 if body!=null:body.custom_minimum_size.x=size.x-52
func open() -> void:
 visible=not visible
 if visible:rebuild();resize()
func _process(delta: float) -> void:
 if not visible:return
 refresh_clock+=delta
 if refresh_clock>=1:
  refresh_clock=0;update_summary();update_buttons()
func wrapped(text: String,parent: Node,font: int=14) -> Label:
 var l=game.hud.label("",parent,font)
 # Establish width before text: otherwise the first layout measures a one-character column
 # and grows the entire window vertically before the ScrollContainer gets its viewport.
 l.custom_minimum_size.x=minf(708,get_viewport_rect().size.x/game.hud.scale.x-84)
 l.size.x=l.custom_minimum_size.x;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.text=text;return l
func update_summary() -> void:
 if summary==null:return
 var realm=game.sim.politics;var lines=PackedStringArray()
 heading.text="CONSELHO · "+Realm.STAGES[realm.stage].to_upper()
 lines.append("%s · Dia %d · Legitimidade %d/100"%[game.sim.realm_name(),game.sim.day(),realm.legitimacy])
 for key in Realm.FACTIONS:lines.append("%s %d"%[Realm.FACTIONS[key],realm.support[key]])
 lines.append("Sessão concluída hoje" if realm.last_council_day>=game.sim.day() else "Sessão disponível")
 summary.text="  ·  ".join(lines)
 if pending_label!=null and is_instance_valid(pending_label):
  var reasons=realm.promotion_reasons(game.sim)
  pending_label.text="Pendências:\n"+"\n".join(reasons) if not reasons.is_empty() else "Todos os requisitos atendidos."
func update_buttons() -> void:
 for node in body.get_children():
  if not node is Button or not node.has_meta("action"):continue
  var action=node.get_meta("action");var id=node.get_meta("id");var realm=game.sim.politics
  var reason=realm.decision_reason(game.sim,id) if action=="decision" else (realm.reform_reason(game.sim,id) if action=="reform" else "\n".join(realm.promotion_reasons(game.sim)))
  if action=="promotion" and realm.stage==4:reason="Seu domínio já é um Reino"
  node.disabled=not reason.is_empty();node.tooltip_text=reason if not reason.is_empty() else "Disponível"
func action_button(text: String,action: String,id: String="") -> Button:
 var b=game.hud.button(text,func():
  var realm=game.sim.politics
  var ok=realm.decide(game.sim,id) if action=="decision" else (realm.enact(game.sim,id) if action=="reform" else realm.promote(game.sim))
  game.hud.notify("Deliberação registrada" if ok else "Condições mudaram; confira os requisitos")
  rebuild(),body)
 b.set_meta("action",action);b.set_meta("id",id);return b
func rebuild() -> void:
 pending_label=null
 for child in content.get_children():content.remove_child(child);child.queue_free()
 var top=HBoxContainer.new();content.add_child(top)
 heading=game.hud.heading("CONSELHO",top);heading.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 game.hud.button("Fechar [Esc]",func():hide(),top)
 summary=wrapped("",content,13)
 var tabs=HBoxContainer.new();content.add_child(tabs)
 for pair in [[0,"Facções e decisões"],[1,"Reformas"],[2,"Evolução"],[3,"Crônicas"]]:
  var index=pair[0];var button=game.hud.button(pair[1],func():tab=index;rebuild(),tabs);button.toggle_mode=true;button.set_pressed_no_signal(tab==index)
 var scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;content.add_child(scroll)
 body=VBoxContainer.new();body.add_theme_constant_override("separation",10);body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(body)
 var realm=game.sim.politics
 if tab==0:
  wrapped("Uma decisão por dia. Os efeitos abaixo são imediatos. O apoio e a legitimidade vão de 0 a 100. Nada é decidido automaticamente enquanto você está fora.",body)
  for id in Realm.DECISIONS:
   var data=Realm.DECISIONS[id];wrapped(data.name,body,17)
   var effects=PackedStringArray()
   for key in data.support:
    if data.support[key]!=0:effects.append("%s %+d"%[Realm.FACTIONS[key],data.support[key]])
   effects.append("Legitimidade %+d"%data.legitimacy)
   wrapped(" · ".join(effects)+"\nCusto: "+game.hud.resource_text(data.cost)+" · Recebe: "+game.hud.resource_text(data.reward),body,13)
   action_button("Aprovar: "+data.name,"decision",id)
 elif tab==1:
  for id in Realm.REFORMS:
   var data=Realm.REFORMS[id];wrapped(data.name+(" · EM VIGOR" if id in realm.reforms else ""),body,17)
   wrapped(data.benefit+"\nRequer %s e apoio %d de %s. Legitimidade +%d.\nCusto: %s"%[Realm.STAGES[data.stage],data.support,Realm.FACTIONS[data.faction],data.legitimacy,game.hud.resource_text(data.cost)],body,13)
   action_button("Promulgar: "+data.name,"reform",id)
 elif tab==2:
  wrapped("Aldeia → Vila → Cidade Livre → Principado → Reino",body,17)
  wrapped("A evolução é permanente e depende da sua confirmação. Não remove construções nem contratos. Vila e Cidade Livre liberam reformas; a soberania final exige apoio de todos os estamentos.",body)
  if realm.stage<4:
   var data=Realm.THRESHOLDS[realm.stage];var requirements=PackedStringArray()
   for kind in data.buildings:requirements.append(game.sim.Catalog.DATA[kind].name)
   wrapped("Próximo: %s\n%d moradores com moradia · legitimidade %d · apoio mínimo %d por facção\nEdifícios concluídos: %s\nCusto: %s"%[Realm.STAGES[realm.stage+1],data.population,data.legitimacy,data.support,", ".join(requirements),game.hud.resource_text(data.cost)],body,16)
   var reasons=realm.promotion_reasons(game.sim)
   if realm.stage==3:wrapped("Requer pelo menos três reformas promulgadas.",body)
   pending_label=wrapped("Pendências:\n"+"\n".join(reasons) if not reasons.is_empty() else "Todos os requisitos atendidos.",body)
   action_button("Elevar a "+Realm.STAGES[realm.stage+1],"promotion")
  else:wrapped("Seu domínio é um Reino. Continue administrando suas facções e recursos.",body,18)
 else:
  wrapped("Histórico das últimas 40 deliberações, reformas e evoluções.",body)
  if realm.history.is_empty():wrapped("O conselho ainda não tomou decisões.",body)
  for entry in realm.history:wrapped("Dia %d · %s"%[entry.day,entry.text],body)
 resize();update_summary();update_buttons()
