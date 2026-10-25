extends CanvasLayer
signal build_selected(kind: String)
signal save_requested
signal load_requested
signal new_requested
signal pause_requested
const Catalog=preload("res://src/construction/catalog.gd")
var resources: Label
var status: Label
var details: RichTextLabel
var portrait: TextureRect
var menu: PanelContainer
func panel(pos: Vector2,size: Vector2,theme: Theme) -> PanelContainer:
 var p=PanelContainer.new();p.position=pos;p.custom_minimum_size=size;p.theme=theme;add_child(p);return p
func button(text: String,callback: Callable,parent: Node) -> Button:
 var b=Button.new();b.text=text;b.pressed.connect(callback);parent.add_child(b);return b
func _ready() -> void:
 var theme=Theme.new()
 var style=StyleBoxFlat.new();style.bg_color=Color("17232a");style.border_color=Color("8d7955");style.set_border_width_all(1);style.set_content_margin_all(12);style.set_corner_radius_all(3)
 theme.set_stylebox("panel","PanelContainer",style)
 var bs=style.duplicate();bs.bg_color=Color("26363c");theme.set_stylebox("normal","Button",bs)
 var hover=bs.duplicate();hover.bg_color=Color("42534b");theme.set_stylebox("hover","Button",hover)
 theme.set_color("font_color","Label",Color("e4dac4"));theme.set_color("font_color","Button",Color("e4dac4"));theme.default_font_size=15
 var top=panel(Vector2(14,12),Vector2(910,51),theme)
 var hb=HBoxContainer.new();hb.add_theme_constant_override("separation",20);top.add_child(hb)
 var brand=Label.new();brand.text="VALE DA AURORA  |  ALDEIA";brand.add_theme_color_override("font_color",Color("dfbd72"));hb.add_child(brand)
 resources=Label.new();hb.add_child(resources)
 var actions=panel(Vector2(936,12),Vector2(330,51),theme)
 var buttons=HBoxContainer.new();actions.add_child(buttons)
 button("Salvar",func():save_requested.emit(),buttons);button("Carregar",func():load_requested.emit(),buttons);button("Menu / Esc",func():pause_requested.emit(),buttons)
 var build_panel=panel(Vector2(14,83),Vector2(218,340),theme)
 var vb=VBoxContainer.new();vb.add_theme_constant_override("separation",7);build_panel.add_child(vb)
 var title=Label.new();title.text="CONSTRUIR";vb.add_child(title)
 for kind in Catalog.DATA:
  var k=kind;var data=Catalog.DATA[kind];var cost=""
  for key in data.cost:cost+=str(data.cost[key])+{"wood":"M ","stone":"P ","gold":"O "}.get(key,"")
  button(data.name+"   "+cost,func():build_selected.emit(k),vb)
 button("Cancelar [Esc]",func():build_selected.emit(""),vb)
 var legend=Label.new();legend.text="M: madeira  P: pedra  O: ouro";legend.add_theme_font_size_override("font_size",12);vb.add_child(legend)
 var detail_panel=panel(Vector2(1034,83),Vector2(232,340),theme)
 var dv=VBoxContainer.new();detail_panel.add_child(dv)
 var head=Label.new();head.text="SEU DOMINIO";dv.add_child(head)
 portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(96,120);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;dv.add_child(portrait)
 details=RichTextLabel.new();details.custom_minimum_size=Vector2(205,220);details.bbcode_enabled=true;dv.add_child(details)
 details.text="Doze pioneiros chegaram ao vale.\n\nPlante hortas e mantenha seus habitantes alimentados.\n\nClique em pessoas e construcoes."
 var bottom=panel(Vector2(14,660),Vector2(1252,46),theme)
 var bh=HBoxContainer.new();bottom.add_child(bh)
 status=Label.new();status.size_flags_horizontal=Control.SIZE_EXPAND_FILL;bh.add_child(status)
 var tip=Label.new();tip.text="WASD mover | Roda zoom | Meio arrastar | F5 salvar | v0.1.0";tip.add_theme_font_size_override("font_size",13);bh.add_child(tip)
 menu=panel(Vector2(430,155),Vector2(420,400),theme)
 var mv=VBoxContainer.new();mv.add_theme_constant_override("separation",14);menu.add_child(mv)
 var logo=Label.new();logo.text="HALFACIV\nISOMETRIC";logo.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;logo.add_theme_font_size_override("font_size",30);mv.add_child(logo)
 var subtitle=Label.new();subtitle.text="O nascimento de um reino\nv0.1.0 - Fundacao";subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;mv.add_child(subtitle)
 button("Entrar no vale / Continuar",func():pause_requested.emit(),mv);button("Carregar dominio salvo",func():load_requested.emit(),mv);button("Novo dominio",func():new_requested.emit(),mv);button("Sair",func():get_tree().quit(),mv)
 portrait.texture=load("res://assets/portraits/9.png")
 get_viewport().size_changed.connect(resize);resize()
func resize() -> void:
 var size=get_viewport().get_visible_rect().size
 var s=minf(size.x/1280.0,size.y/720.0);scale=Vector2(s,s)
func update_resources(sim) -> void:
 resources.text="Alimento %d   Madeira %d   Pedra %d   Ouro %d   Influencia %d"%[sim.resources.food,sim.resources.wood,sim.resources.stone,sim.resources.gold,sim.resources.influence]
 status.text="Populacao %d | Dia %d | %s"%[sim.population,1+sim.tick_count/120,"Aldeia em crescimento" if sim.resources.food>10 else "Alimento escasso!"]
func show_person(c) -> void:
 portrait.texture=load("res://assets/portraits/"+str(c.kind)+".png")
 details.text="[b]"+c.citizen_name+"[/b]\n"+["Campones","Camponesa","Lenhador","Minerador","Construtor","Mercador","Guarda","Cavaleiro","Arqueiro","Governante","Nobre","Sacerdote"][c.kind]+"\n"+c.state+"\n\nRetrato: estudo pixel art provisorio.\nDirecao lateral original."
func show_building(b) -> void:
 portrait.texture=null;var data=Catalog.DATA[b.kind]
 details.text="[b]"+data.name+"[/b]\n"+("Em construcao: %.0fs"%b.remaining if b.remaining>0 else "Em funcionamento")+"\nBeneficio: "+data.benefit+"\nProducao por segundo:\n"+str(data.production)+"\n\nNivel "+str(b.level)+"\nTrabalho comunitario."
