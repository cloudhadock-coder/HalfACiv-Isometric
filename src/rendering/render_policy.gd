extends RefCounted
const CHARACTER_FRAME=Vector2(30,35)
const CHARACTER_PIVOT=Vector2(15,35)
const HORSE_FRAME=Vector2(48,48)
const HORSE_PIVOT=Vector2(24,41)

static func before(a: Dictionary,b: Dictionary) -> bool:
 if a.y!=b.y:return a.y<b.y
 if a.type!=b.type:return a.type<b.type
 return a.get("order",0)<b.get("order",0)
