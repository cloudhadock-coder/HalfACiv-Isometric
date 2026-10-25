extends PanelContainer
const Company=preload("res://src/entities/company.gd")
const PortraitView=preload("res://src/ui/portrait_view.gd")
var game
var content: VBoxContainer
var tab: int=0
func _ready() -> void:
 theme=game.hud.theme;z_index=5
 content=VBoxContainer.new();content.add_theme_constant_override("separation",10);add_child(content)
 hide();get_viewport().size_changed.connect(resize)
func resize() -> void:
 var size=get_viewport_rect().size/game.hud.scale.x
 position=Vector2((size.x-650)/2,82);custom_minimum_size=Vector2(650,minf(550,size.y-160));self.size=custom_minimum_size
func open() -> void:
 visible=not visible
 if visible:rebuild();resize()
func rebuild() -> void:
 for child in content.get_children():content.remove_child(child);child.queue_free()
 var head=HBoxContainer.new();content.add_child(head)
 game.hud.label("COMPANHIA DO VALE",head,20).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 game.hud.button("Fechar",func():hide(),head)
 var tabs=HBoxContainer.new();content.add_child(tabs)
 game.hud.button("Contratos",func():tab=0;rebuild(),tabs)
 game.hud.button("Cavalaria e heráldica",func():tab=1;rebuild(),tabs)
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(610,360);scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;content.add_child(scroll)
 var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",12);scroll.add_child(list)
 if tab==0:
  game.hud.label("Contratos únicos para os moradores nomeados do vale.",list,13)
  for data in Company.OFFERS:
   var row=HBoxContainer.new();row.add_theme_constant_override("separation",12);list.add_child(row)
   var face=PortraitView.new();face.texture=game.hud.registry.textures[data.portrait];face.custom_minimum_size=Vector2(96,112);row.add_child(face)
   var box=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(box)
   game.hud.label(data.name+" · "+data.specialty,box,15)
   game.hud.label(data.description,box,13)
   var reason=Company.reason(game.sim,data.id);var id=data.id
   var b=game.hud.button("Contratar · %d ouro"%data.cost,func():
    if Company.recruit(game.sim,id):game.hud.notify("Contrato firmado com "+data.name)
    else:game.hud.notify(Company.reason(game.sim,id))
    rebuild(),box)
   b.disabled=not reason.is_empty();b.tooltip_text=reason
   game.hud.label(reason if not reason.is_empty() else "Retrato provisório · identidade preservada",box,12)
 else:
  game.hud.label("Selecione um cavaleiro ou cavalo no mapa para equipá-lo.",list,13)
  if game.selected<0 or game.selected>=game.people.size():return
  var c=game.people[game.selected]
  if not c.mounted and not c.horse_only:
   game.hud.label("O habitante selecionado está a pé.",list);return
  game.hud.label(c.citizen_name,list,20)
  choose(list,"Pelagem",Company.COATS,"coat",c)
  choose(list,"Casa heráldica",Company.COLORS,"color",c)
  choose(list,"Andadura",["Passo","Trote (ritmo)","Galope (ritmo)"],"gait",c)
  for pair in [["armor","Barda de aço"],["banner","Estandarte"]]:
   var key=pair[0];var check=CheckButton.new();check.text=pair[1];check.button_pressed=c.equipment[key];list.add_child(check)
   check.toggled.connect(func(value):c.equipment[key]=value)
  game.hud.label("Equipamento cosmético. Andadura altera ritmo e velocidade.\nCiclo lateral de passo reutilizado; trote/galope anatômicos pendentes.\nSem combate. Alterações são salvas com o domínio.",list,12)
func choose(parent: Node,text: String,options: Array,key: String,c) -> void:
 var row=HBoxContainer.new();parent.add_child(row);game.hud.label(text,row).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 var select=OptionButton.new();select.custom_minimum_size.x=240
 for option in options:select.add_item(option)
 select.select(c.equipment[key]);row.add_child(select);select.item_selected.connect(func(index):c.equipment[key]=index)
