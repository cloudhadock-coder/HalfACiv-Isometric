"""Extract the supplied native sheet, keeping each real sequence separate.
Never regenerates characters/portraits or restores deprecated animation files.
"""
from pathlib import Path
import sys,json,hashlib,argparse
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image,ImageDraw
SPECS={
 'house':(16,list(range(16)),8),'bakery':(15,list(range(16)),8),
 'tavern':(15,list(range(16)),8),'herbalist':(16,list(range(16)),8),
 'workshop':(16,list(range(16)),8),'mill':(1,list(range(4)),6),
 'barracks':(2,list(range(14)),8),'tower':(14,list(range(14)),8),
 'farm':(5,list(range(16)),6),'chapel':(4,[15],0),
 'lumber':(0,[0],0),'quarry':(0,[3],0),'market':(0,[8],0),
 'warehouse':(0,[2],0),'stable':(0,[2],0),'fishery':(1,[10],0),
 'forge':(14,[14],0),'pasture':(0,[5],0)
}
def decorate(im,name):
 im=im.copy();d=ImageDraw.Draw(im)
 if name=='forge':
  d.rectangle((27,38,34,46),fill='#382d2c');d.rectangle((29,41,33,45),fill='#eb9b49')
  d.rectangle((29,20,32,26),fill='#475052');d.rectangle((29,19,33,21),fill='#77817b');d.line((30,20,32,20),fill='#263437')
 if name=='bakery':
  d.rectangle((20,40,27,44),fill='#d5b97e');d.line((22,41,24,42),fill='#795d3b')
 if name=='workshop':
  d.line((20,40,27,44),fill='#c7b993',width=2);d.line((20,42,25,45),fill='#4b3b32')
 if name=='warehouse':
  for x,y in [(20,40),(28,44),(35,40)]:
   d.rectangle((x,y,x+6,y+6),fill='#9e774c',outline='#503f32');d.line((x+1,y+1,x+5,y+5),fill='#d0ae72')
 if name=='stable':
  d.rectangle((21,36,42,47),fill='#5b4536');d.line((22,37,22,46),fill='#a98b57',width=2);d.line((21,44,41,44),fill='#c2a168')
 if name=='fishery':
  d.line((21,37,44,50),fill='#ab8b57',width=2);d.line((43,33,43,51),fill='#554736');d.line((43,33,50,38,49,44),fill='#d2c9a4')
 if name=='herbalist':
  for x,y in [(20,45),(25,48),(39,45)]:
   d.rectangle((x,y,x+3,y+3),fill='#794b3d');d.line((x+1,y,x+1,y-5),fill='#74924c');d.rectangle((x,y-4,x+3,y-3),fill='#a4b16d')
 if name=='market':
  d.polygon([(17,26),(29,20),(45,28),(33,34)],fill='#9c5251');d.line((20,26,31,22),fill='#d8b88a',width=2);d.line((28,30,39,25),fill='#d8b88a',width=2)
 if name=='pasture':
  for x,y in [(16,46),(32,53),(42,45)]:
   d.ellipse((x,y-3,x+7,y+1),fill='#e4dbbc');d.rectangle((x+5,y-2,x+8,y),fill='#534a3c');d.point((x+1,y+2),fill='#514534');d.point((x+5,y+2),fill='#514534')
 return im
def wheat(p):return p[3]>0 and p[0]>150 and p[1]>110 and p[2]<125
def build(root=ROOT,source=None):
 root=Path(root)
 source=Path(source) if source else root/'assets/art_reference/Buildings/sprite-Sheet.png'
 if not source.exists():source=root/'assets/original/sprite-Sheet.png'
 with Image.open(source) as image:sheet=image.convert('RGBA')
 if sheet.size!=(1024,1280):raise ValueError('Expected native sheet 1024x1280, cells 64x64')
 def tile(col,row):return sheet.crop((col*64,row*64,col*64+64,row*64+64))
 grass=tile(5,0)
 greens={p[:3] for p in grass.get_flattened_data() if p[3] and p[1]>p[0]*1.05 and p[1]>p[2]*1.05}
 out=root/'assets/buildings/native_v042';out.mkdir(parents=True,exist_ok=True)
 manifest={'schema':1,'version':'0.4.2','source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source_size':[1024,1280],'frame':[64,64],'pivot':[32,40],'filter':'nearest','animations':{}}
 for name,(row,cols,fps) in SPECS.items():
  atlas=Image.new('RGBA',(64*len(cols),64));fixed=tile(cols[0],row)
  for i,col in enumerate(cols):
   frame=tile(col,row)
   if name=='farm':
    # The row drops fence sections in later frames. Keep the fence/soil from frame 0,
    # transfer only native grain colours within its fixed wheat silhouette.
    original=frame;frame=fixed.copy()
    for y in range(64):
     for x in range(64):
      if wheat(fixed.getpixel((x,y))) and wheat(original.getpixel((x,y))):frame.putpixel((x,y),original.getpixel((x,y)))
   frame=decorate(frame,name);pixels=frame.load()
   for y in range(64):
    for x in range(64):
     r,g,b,a=pixels[x,y]
     if y+.5>=56-abs(x+.5-32)*.5:pixels[x,y]=(0,0,0,0)
     elif y>=24 and (r,g,b) in greens:pixels[x,y]=(int(r*.84),int(g*.78),int(b*.83),a)
   if frame.getbbox() is None:raise ValueError(f'Empty {name}/{i}')
   atlas.paste(frame,(i*64,0))
   if i==0:frame.save(out/f'{name}.png')
  atlas.save(out/f'{name}_atlas.png')
  manifest['animations'][name]={'count':len(cols),'fps':fps,'source_row':row,'source_columns':cols,'atlas':f'{name}_atlas.png','preview':f'{name}.png','native_smoke':row in [15,16]}
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
 print('BUILDING_ASSETS_OK buildings=18 animated=9 source='+manifest['source_sha256'])
 return manifest
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path);parser.add_argument('--root',type=Path,default=ROOT);args=parser.parse_args();build(args.root,args.source)
