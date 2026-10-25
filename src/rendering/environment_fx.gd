extends RefCounted

static func smoke(view: Node2D,p: Vector2,time: float) -> void:
 for i in range(4):
  var age=fmod(time*0.28+i*0.25,1.0)
  var at=(p+Vector2(sin(age*5)*4,-age*22)).round()
  var size=2+floor(age*3)
  view.draw_rect(Rect2(at,Vector2(size,size)),Color(0.71,0.73,0.67,(1-age)*0.28))

static func fire(view: Node2D,p: Vector2,time: float) -> void:
 var f=int(time*9)%4
 view.draw_rect(Rect2((p+Vector2(-2,-3-f%2)).round(),Vector2(5,4+f%2)),Color("b45332"))
 view.draw_rect(Rect2((p+Vector2(-1,-3-f/2)).round(),Vector2(3,3+f/2)),Color("e7a94e"))
 view.draw_rect(Rect2((p+Vector2(0,-1)).round(),Vector2(1,2)),Color("f6dfa0"))

static func work_effect(view: Node2D,p: Vector2,time: float,tool: String) -> void:
 if tool in ["hammer","pick","axe","saw"]:
  var frame=int(time*6)%5
  for j in range(2):
   var at=(p+Vector2(8+frame+j*2,-14-frame*2+j)).round()
   view.draw_rect(Rect2(at,Vector2.ONE),Color("ceb476") if frame<3 else Color(0,0,0,0))

static func cargo(view: Node2D,p: Vector2,contents: Dictionary) -> void:
 var colour=Color("a78755")
 if contents.has("food"):colour=Color("a9ad67")
 elif contents.has("stone"):colour=Color("9babae")
 elif contents.has("gold"):colour=Color("d2b56b")
 var at=(p+Vector2(5,-12)).round()
 view.draw_rect(Rect2(at-Vector2.ONE,Vector2(9,8)),Color("3b3830"))
 view.draw_rect(Rect2(at,Vector2(7,6)),colour)
 view.draw_line(at+Vector2(1,0),at+Vector2(1,5),colour.lightened(0.25))
 view.draw_line(at+Vector2(0,3),at+Vector2(6,3),colour.darkened(0.3))

static func held_tool(view: Node2D,p: Vector2,time: float,tool: String) -> void:
 var swing=round(sin(time*5)*2)
 var at=(p+Vector2(5,-14-swing)).round()
 if tool in ["hammer","axe","pick","hoe","saw","rod","crook"]:
  view.draw_line(at+Vector2(-2,4),at+Vector2(4,-4),Color("ad8a54"),2)
  view.draw_line(at+Vector2(1,-5),at+Vector2(7,-4),Color("b3bdb2"),2)
 else:
  view.draw_rect(Rect2(at,Vector2(5,4)),Color("ad9a68"))
