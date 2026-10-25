from pathlib import Path
import sys,json,hashlib
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image,ImageDraw,ImageSequence
OUT=ROOT/'assets'
def run():
 sheet=Image.open(OUT/'original/sprite-Sheet.png').convert('RGBA')
 for name,col,row in [('grass',5,0),('house',0,0),('farm',0,5),('lumber',2,0),('quarry',3,0),('market',6,0),('chapel',1,0),('mill',0,1),('barracks',0,2),('tower',6,0),('wall',0,9),('tree',0,11),('water',7,17),('road',1,17)]:
  frame=sheet.crop((col*64,row*64,col*64+64,row*64+64));assert frame.getbbox(),name;frame.save(OUT/'tilesets'/f'{name}.png')
 # Ground surfaces follow the 64x32 diamond; original road crop was a pond.
 for name in ['road','water']:
  im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im)
  d.polygon([(0,48),(32,32),(63,48),(32,63)],fill='#8e7752' if name=='road' else '#337983')
  for yy in range(33,63):
   for xx in range(64):
    if im.getpixel((xx,yy))[3] and (xx*13+yy*7)%23==0:d.point((xx,yy),fill='#b39a6a' if name=='road' else '#499698')
  im.save(OUT/'tilesets'/f'{name}.png')
 pack=OUT/'original/GandalfHardcore' 
 specs=[('Campones','Male','Shirt','Pants'),('Camponesa','Female','Corset','Skirt'),('Lenhador','Male','Green Shirt v2','Green Pants'),('Minerador','Male','Blue Shirt v2','Blue Pants'),('Construtor','Male','orange Shirt v2','Orange Pants'),('Mercador','Male','Purple Shirt v2','Purple Pants'),('Guarda','Male','Shirt v2','Pants'),('Cavaleiro','Male','Blue Shirt v2','Blue Pants'),('Arqueiro','Male','Green Shirt v2','Pants'),('Governante','Male','Purple Shirt v2','Purple Pants'),('Nobre','Female','Blue Corset v2','Skirt'),('Sacerdote','Male','Shirt','Pants')]
 meta={}
 for i,(name,sex,shirt,pants) in enumerate(specs):
  layers=[pack/'Character skin colors'/f'{sex} Skin{i%5+1}.png',pack/f'{sex} Clothing'/f'{pants}.png',pack/f'{sex} Clothing'/f'{shirt}.png',pack/f'{sex} Clothing'/'Boots.png',pack/f'{sex} Hair'/f'{sex} Hair{i%5+1}.png']
  if name in ['Guarda','Cavaleiro']:layers.append(pack/f'{sex} Hand'/f'{sex} Sword.png')
  composed=Image.new('RGBA',(800,448))
  for layer in layers:
   if layer.exists():composed.alpha_composite(Image.open(layer).convert('RGBA'))
  atlas=Image.new('RGBA',(384,112))
  for row,count in [(0,5),(1,8)]:
   for col in range(8):
    f=composed.crop((col%count*80+16,row*64+8,col%count*80+64,row*64+64));assert f.getbbox(),(name,row,col);atlas.paste(f,(col*48,row*56))
  atlas.save(OUT/'characters'/f'{i}.png')
  meta[str(i)]={'name':name,'frame':[48,56],'idle':5,'walk':8,'directions':['E'],'layers':[str(p.relative_to(pack)) for p in layers]}
  im=Image.new('RGBA',(64,80),'#18252c');d=ImageDraw.Draw(im);d.rectangle((2,2,61,77),outline='#b79b62',width=2)
  skin=['#d6a47b','#b97a56','#f0c69b','#87563e','#c08c66'][i%5];hair=['#382d26','#856340','#c9ae72','#29252b','#9c5436'][i%5];cloth=['#647b55','#737ca0','#9c5447','#b49a54','#775786','#375e70'][i%6]
  d.polygon([(8,75),(12,53),(24,46),(39,46),(52,54),(57,75)],fill=cloth,outline='#101a24');d.rectangle((26,41,36,54),fill=skin);d.rectangle((20,16,43,42),fill=hair);d.polygon([(22,24),(40,23),(40,39),(35,46),(27,46),(22,39)],fill=skin);d.rectangle((22,19,40,26),fill=hair);d.rectangle((21,24,24,33),fill=hair);d.point((27,32),fill='#18242c');d.point((36,32),fill='#18242c');d.line((31,33,30,38),fill='#986044');d.line((28,41,34,41),fill='#754332');d.line((13,57,25,53,31,63,40,53,51,57),fill='#d0b67a',width=2)
  if i in [6,7]:d.rectangle((19,16,44,24),fill='#9daeb5');d.line((20,16,31,11,43,16),fill='#d6e1d9',width=3)
  if i==9:d.rectangle((21,16,42,20),fill='#d6b957');d.rectangle((23,12,25,17),fill='#d6b957');d.rectangle((32,10,34,17),fill='#d6b957')
  im.save(OUT/'portraits'/f'{i}.png')
 (OUT/'characters/manifest.json').write_text(json.dumps(meta,indent=2),encoding='utf-8')
 atlas=Image.new('RGBA',(512,128))
 for row in range(2):
  for f in range(8):
   im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im);y=30+[0,0,-1,-1,0,0,1,1][f];d.ellipse((9,51,56,57),fill=(12,23,26,70))
   for leg,x in enumerate([20,28,39,46]):
    step=([0,2,3,2,0,-2,-3,-2][(f+leg*4)%8] if row else 0);d.line((x,y+9,x+step,51),fill='#372b2a',width=3);d.line((x+step-1,52,x+step+3,52),fill='#19252c',width=2)
   d.polygon([(14,y+2),(19,y-4),(40,y-3),(48,y+3),(44,y+13),(23,y+15),(15,y+9)],fill='#875437',outline='#30272a');d.line((19,y-2,38,y-1),fill='#bb8152',width=2);d.polygon([(40,y+4),(45,y-14),(49,y-19),(56,y-16),(57,y-9),(52,y-5),(49,y+10)],fill='#a36b43',outline='#30272a');d.line((44,y-12,47,y-20),fill='#30272a',width=3);d.line((50,y-17,49,y-23),fill='#30272a',width=2);d.point((53,y-13),fill='#e9d3a1');d.line((15,y+1,9,y+8,7+[0,1,2,1,0,-1,-2,-1][f],y+17),fill='#30272a',width=3);d.rectangle((24,y-2,39,y+9),fill='#476879');d.line((25,y+9,38,y+9),fill='#c7a25e',width=2);d.rectangle((26,y-4,37,y),fill='#463733');atlas.paste(im,(f*64,row*64))
 atlas.save(OUT/'horses/horse.png')
 audit=[]
 for p in sorted((OUT/'original').rglob('*')):
  if p.suffix.lower() not in ['.png','.gif']:continue
  with Image.open(p) as im:
   rec={'file':str(p.relative_to(OUT/'original')),'size':im.size,'mode':im.mode,'frames':getattr(im,'n_frames',1),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
   if p.suffix=='.gif':
    rec['durations_ms']=[frame.info.get('duration',0) for frame in ImageSequence.Iterator(im)];contact=Image.new('RGBA',(im.width*4,im.height*2))
    for j in range(8):im.seek(j*max(1,im.n_frames//8)%im.n_frames);contact.paste(im.convert('RGBA'),((j%4)*im.width,(j//4)*im.height))
    contact.thumbnail((1024,512));contact.save(OUT/'animations'/f'{p.stem}_reference.png')
   audit.append(rec)
 (ROOT/'docs/asset_inventory.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
 print('ASSETS_OK: 14 tiles, 12 characters, 12 portrait studies, horse, GIF contacts')
if __name__=='__main__':
 run()
 from village_art import build
 build(ROOT)

 from visual_patch import build as visual_patch
 visual_patch(ROOT)
