
"""Deterministic extensions of the editable v0.1 art pipeline. No AI inputs."""
from pathlib import Path
from PIL import Image,ImageDraw
import math,json,random
PALETTES=['#668454','#976056','#536e97','#b4995d','#67577e','#467c78']
def shade(c,f):
 if isinstance(c,str):c=tuple(bytes.fromhex(c.lstrip('#')))
 return tuple(max(0,min(255,int(v*f))) for v in c[:3])
def portrait(index,sex,skin,hair,cloth,tool):
 im=Image.new('RGBA',(96,112),'#121e28');d=ImageDraw.Draw(im)
 # Dithered stone alcove and carved brass border, all drawn at native pixel resolution.
 for y in range(5,107):
  for x in range(5,91):
   if (x*13+y*7)%17==0:d.point((x,y),fill='#1e2c34')
 d.rectangle((2,2,93,109),outline='#806846',width=2);d.rectangle((5,5,90,106),outline='#b39a63')
 for x,y in [(7,7),(88,7),(7,104),(88,104)]:d.polygon([(x,y-2),(x+2,y),(x,y+2),(x-2,y)],fill='#dfc487')
 sh=shade(skin,.72);hi=shade(skin,1.13);dark=shade(hair,.65)
 if sex=='Female':d.polygon([(29,26),(39,17),(58,18),(68,29),(70,77),(28,77)],fill=dark)
 d.polygon([(12,105),(17,81),(35,70),(60,70),(79,82),(84,105)],fill=shade(cloth,.62),outline='#101922')
 d.polygon([(18,102),(23,81),(37,73),(48,89),(60,73),(73,82),(78,102)],fill=cloth)
 d.polygon([(23,82),(37,75),(43,83),(38,104),(21,104)],fill=shade(cloth,1.2))
 d.polygon([(57,81),(65,78),(73,83),(77,104),(54,104)],fill=shade(cloth,.8))
 d.rectangle((39,59,56,78),fill=sh);d.polygon([(41,61),(53,61),(54,75),(47,81),(41,74)],fill=skin)
 d.rectangle((29,37,34,51),fill=sh);d.rectangle((61,37,65,50),fill=sh)
 d.polygon([(33,29),(41,23),(56,25),(63,34),(61,56),(55,65),(44,68),(35,60),(31,46)],fill=skin,outline='#312a2a')
 d.polygon([(34,35),(39,30),(44,29),(42,50),(37,55),(34,49)],fill=hi)
 d.polygon([(57,34),(62,36),(59,56),(54,63),(48,65),(49,60),(56,55)],fill=sh)
 d.polygon([(29,33),(32,24),(42,18),(56,19),(64,25),(66,36),(58,30),(49,29),(42,33),(35,32),(31,42)],fill=hair)
 for x in range(33,61,4):d.line((x,25,x+2,22,x+5,24),fill=shade(hair,1.3))
 if sex=='Female':
  d.polygon([(30,31),(36,33),(34,59),(38,76),(30,71),(27,53)],fill=hair)
  d.line((31,37,31,61,35,71),fill=shade(hair,1.3),width=2)
 else:
  d.rectangle((31,34,34,47),fill=hair)
  if index%3==0 or index==17:
   d.polygon([(35,53),(41,58),(53,58),(60,51),(57,64),(47,70),(38,65)],fill=hair)
   d.line((40,61,47,65,54,60),fill=shade(hair,1.25))
 d.line((36,40,43,39),fill=dark,width=2);d.line((51,39,58,40),fill=dark,width=2)
 d.rectangle((37,43,43,45),fill='#e2d5b6');d.rectangle((51,43,57,45),fill='#e2d5b6')
 d.rectangle((40,42,42,46),fill='#31434b');d.rectangle((52,42,54,46),fill='#31434b');d.point((40,43),fill='#faf2d5');d.point((52,43),fill='#faf2d5')
 d.line((47,43,45,53,50,54),fill=sh);d.point((46,51),fill=hi);d.line((43,59,51,59),fill='#8b5650');d.line((44,61,49,61),fill=hi)
 d.line((22,82,36,76,47,87,60,76,73,83),fill='#d0b87b',width=2)
 for y in [88,94,100]:d.rectangle((47,y,49,y+1),fill='#c5a45d')
 if index in [6,7,8,23]:
  d.polygon([(29,32),(33,21),(45,16),(59,20),(66,29),(65,36),(29,36)],fill='#8fa4ac',outline='#283d49');d.line((32,27,45,20,59,24),fill='#dae3d6',width=2);d.rectangle((30,33,64,36),fill='#627b8a')
 elif index==9:
  d.polygon([(32,27),(31,17),(39,22),(45,13),(51,22),(61,17),(62,28)],fill='#c8a447',outline='#6e5033');d.rectangle((33,26,61,29),fill='#ead68a');d.rectangle((45,24,49,27),fill='#b3564f')
 elif index in [12,13,20]:
  d.polygon([(27,31),(34,23),(35,17),(58,17),(60,26),(69,31)],fill='#b49a63',outline='#574c36');d.line((35,25,58,25),fill='#6d5a3e',width=2)
 elif index in [14,15,21]:
  d.polygon([(30,30),(29,22),(36,16),(43,18),(49,14),(60,18),(64,25),(61,31)],fill='#ddd6ba',outline='#817d70');d.rectangle((32,27,61,31),fill='#ece4c8')
 elif index==18:
  d.line((31,28,41,23,58,25,64,30),fill='#547d55',width=3)
  for x in [35,41,55,61]:d.ellipse((x,23,x+3,26),fill='#a1ad63')
 elif index==11:d.rectangle((41,24,55,27),fill=skin)
 # Occupational badge: unique small tool silhouette on the lower corner.
 d.rectangle((68,85,87,103),fill='#223239',outline='#9d8558')
 if tool in ['hammer','axe','pick','hoe','saw','rod','crook']:
  d.line((74,99,82,89),fill='#b28d5a',width=2);d.polygon([(77,88),(84,88),(85,92),(79,92)],fill='#acbdba')
 elif tool in ['bread','sack','crate','basket']:
  d.rounded_rectangle((72,90,84,99),2,fill='#be9259',outline='#715239');d.line((75,91,74,95),fill='#ebce86');d.line((80,91,79,95),fill='#ebce86')
 elif tool in ['herbs','seal','book']:
  d.line((78,99,78,90),fill='#b6c074',width=2);d.ellipse((73,90,78,94),fill='#73915b');d.ellipse((78,87,83,92),fill='#a6b16a')
 else:d.rectangle((73,90,82,99),fill='#bfa066');d.rectangle((76,92,80,96),fill='#efe0a4')
 return im

def build(root):
 out=root/'assets';pack=out/'original/GandalfHardcore';sheet=Image.open(out/'original/sprite-Sheet.png').convert('RGBA')
 def tile(col,row):return sheet.crop((col*64,row*64,col*64+64,row*64+64))
 crops={'house':(0,16),'chapel':(0,15),'mill':(0,1),'barracks':(0,2),'tower':(6,0),'forge':(14,14),'warehouse':(2,0),'fishery':(10,1),'workshop':(13,16),'tavern':(15,16),'stable':(2,0),'bakery':(0,16),'herbalist':(0,16),'pasture':(5,0),'market':(8,0)}
 for name,(col,row) in crops.items():
  im=tile(col,row);d=ImageDraw.Draw(im)
  if name=='forge':d.rectangle((27,38,34,46),fill='#382d2c');d.rectangle((29,41,33,45),fill='#eb9b49')
  if name=='bakery':d.rectangle((20,40,27,44),fill='#d5b97e');d.line((22,41,24,42),fill='#795d3b')
  if name=='warehouse':
   for x,y in [(20,40),(28,44),(35,40)]:d.rectangle((x,y,x+6,y+6),fill='#9e774c',outline='#503f32');d.line((x+1,y+1,x+5,y+5),fill='#d0ae72')
  if name=='stable':d.rectangle((21,36,42,47),fill='#5b4536');d.line((22,37,22,46),fill='#a98b57',width=2);d.line((21,44,41,44),fill='#c2a168')
  if name=='fishery':d.line((21,37,44,50),fill='#ab8b57',width=2);d.line((43,33,43,51),fill='#554736');d.line((43,33,50,38,49,44),fill='#d2c9a4')
  if name=='herbalist':
   for x,y in [(20,45),(25,48),(39,45)]:d.rectangle((x,y,x+3,y+3),fill='#794b3d');d.line((x+1,y,x+1,y-5),fill='#74924c');d.rectangle((x,y-4,x+3,y-3),fill='#a4b16d')
  if name=='market':
   d.polygon([(17,26),(29,20),(45,28),(33,34)],fill='#9c5251');d.line((20,26,31,22),fill='#d8b88a',width=2);d.line((28,30,39,25),fill='#d8b88a',width=2)
  if name=='pasture':
   for x,y in [(16,46),(32,53),(42,45)]:d.ellipse((x,y-3,x+7,y+1),fill='#e4dbbc');d.rectangle((x+5,y-2,x+8,y),fill='#534a3c');d.point((x+1,y+2),fill='#514534');d.point((x+5,y+2),fill='#514534')
  im.save(out/'tilesets'/f'{name}.png')
 # Building animations are extracted by buildings.py with explicit sequences.
 # Muted, consistent ground and deterministic little meadow variants.
 grass=tile(5,0)
 for i in range(4):
  im=grass.copy();pixels=im.load()
  for y in range(64):
   for x in range(64):
    rr,gg,bb,aa=pixels[x,y]
    if aa:pixels[x,y]=(int(rr*.84),int(gg*.78),int(bb*.83),aa)
  d=ImageDraw.Draw(im);rng=random.Random(240+i)
  for _ in range(12):
   x=rng.randrange(10,54);y=rng.randrange(38,57)
   if abs(x-32)/32+abs(y-48)/16<.8:
    d.point((x,y),fill=['#aba56b','#8c985d','#b6a477','#7f9461'][i])
  im.save(out/'tilesets'/('grass.png' if i==0 else f'grass_{i}.png'))
 # Seamless road/water: surface only, no raised edges between identical neighbours.
 for name,base in [('road','#948463'),('water','#357883'),('plaza','#8b8b78')]:
  im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im);d.polygon([(0,48),(32,32),(63,48),(32,63)],fill=base)
  for y in range(33,63):
   for x in range(64):
    if im.getpixel((x,y))[3] and (x*13+y*7)%37==0:d.point((x,y),fill=shade(base,1.16))
  if name=='plaza':
   for v in range(-16,17,8):d.line((0,48+v,63,48+v),fill='#777c6b')
  im.save(out/'tilesets'/f'{name}.png')
 specs=[('Male','Shirt','Pants'),('Female','Corset','Skirt'),('Male','Green Shirt v2','Green Pants'),('Male','Blue Shirt v2','Blue Pants'),('Male','orange Shirt v2','Orange Pants'),('Male','Purple Shirt v2','Purple Pants'),('Male','Shirt v2','Pants'),('Male','Blue Shirt v2','Blue Pants'),('Male','Green Shirt v2','Pants'),('Male','Purple Shirt v2','Purple Pants'),('Female','Blue Corset v2','Skirt'),('Male','Shirt','Pants'),('Female','Green Corset v2','Skirt'),('Male','Blue Shirt v2','Blue Pants'),('Male','Shirt','Pants'),('Female','Corset v2','Skirt'),('Male','orange Shirt v2','Pants'),('Male','Green Shirt v2','Orange Pants'),('Female','Green Corset','Skirt'),('Male','Purple Shirt v2','Pants'),('Female','Orange Corset','Skirt'),('Female','Blue Corset','Skirt'),('Male','Shirt v2','Orange Pants'),('Male','Blue Shirt v2','Pants')]
 tools=['hoe','basket','axe','pick','hammer','coins','sword','sword','bow','seal','seal','book','hoe','rod','sack','bread','hammer','saw','herbs','mug','crook','mug','crate','lantern']
 identities=[]
 for i,(sex,shirt,pants) in enumerate(specs):
  layers=[pack/'Character skin colors'/f'{sex} Skin{i%5+1}.png',pack/f'{sex} Clothing'/f'{pants}.png',pack/f'{sex} Clothing'/f'{shirt}.png',pack/f'{sex} Clothing'/'Boots.png',pack/f'{sex} Hair'/f'{sex} Hair{i%5+1}.png']
  if i in [6,7]:layers.append(pack/f'{sex} Hand'/f'{sex} Sword.png')
  composed=Image.new('RGBA',(800,448))
  for layer in layers:
   if not layer.exists():raise FileNotFoundError(layer)
   composed.alpha_composite(Image.open(layer).convert('RGBA'))
  atlas=Image.new('RGBA',(384,168))
  for row,count in [(0,5),(1,8),(2,5)]:
   for frame in range(8):
    # Work is a deliberate tool overlay on idle poses; not relabelled attack frames.
    source_row=0 if row==2 else row
    f=composed.crop((frame%count*80+16,source_row*64+8,frame%count*80+64,source_row*64+64))
    if row==2 and i not in [6,7]:
     d=ImageDraw.Draw(f);swing=[0,1,3,1,0,-1,-2,-1][frame];x=31+swing;y=34-abs(swing)
     if tools[i] in ['hoe','axe','pick','hammer','saw','rod','crook']:d.line((28,41,x+6,y-5),fill='#9a7951',width=2);d.line((x+1,y-5,x+9,y-4),fill='#a8b5b0',width=2)
     else:d.rectangle((29,y,35,y+5),fill='#b09660',outline='#524432')
    assert f.getbbox();atlas.paste(f,(frame*48,row*56))
  atlas.save(out/'characters'/f'{i}.png')
  skin=['#d6a47b','#b97a56','#f0c69b','#87563e','#c08c66'][i%5];hair=['#382d26','#856340','#c9ae72','#29252b','#9c5436'][i%5];cloth=PALETTES[i%6]
  # Shirt colour is the identity's actual layer colour family.
  if 'Blue' in shirt:cloth='#536e97'
  elif 'Green' in shirt:cloth='#668454'
  elif 'Purple' in shirt:cloth='#67577e'
  elif 'Orange' in shirt or 'orange' in shirt:cloth='#b18753'
  portrait(i,sex,skin,hair,cloth,tools[i]).save(out/'portraits'/f'{i}.png')
  identities.append({'id':i,'sex':sex,'skin':i%5+1,'hair':i%5+1,'shirt':shirt,'tool':tools[i],'portrait_size':[96,112],'portrait_status':'editable_pixel_art'})
 (out/'ui/identities.json').write_text(json.dumps(identities,ensure_ascii=False,indent=2),encoding='utf-8')
 (out/'characters/manifest.json').write_text(json.dumps({'frame':[48,56],'rows':{'idle':0,'walk':1,'work':2},'counts':{'idle':5,'walk':8,'work':8},'directions':['E'],'identities':identities},indent=2),encoding='utf-8')
 preview=Image.new('RGBA',(96*8,112*3))
 for i in range(24):preview.paste(Image.open(out/'portraits'/f'{i}.png'),((i%8)*96,(i//8)*112))
 preview.save(root/'docs/portraits-v0.2.0.png')
 print('VILLAGE_ART_OK: 24 characters, 24 legacy portraits, 18 base buildings; animation extraction in buildings.py')
