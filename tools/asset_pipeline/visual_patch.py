"""v0.2.1: align native 64x64 tiles to their real surface at (32,40).
Sources and v0.2 products remain untouched. Derived copies live in visual_v021/native.
"""
from pathlib import Path
import json,hashlib,sys
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools/python_libs'))
from PIL import Image,ImageDraw
ORIGIN=(32,40)
def clip_surface(image):
 image=image.copy().convert('RGBA');pixels=image.load()
 for y in range(64):
  for x in range(64):
   if y+.5>=56-abs(x+.5-32)*0.5:pixels[x,y]=(0,0,0,0)
 return image

def build(root):
 assets=root/'assets';source=assets/'tilesets';out=source/'visual_v021';out.mkdir(exist_ok=True)
 original=Image.open(assets/'original/sprite-Sheet.png').convert('RGBA')
 grass=original.crop((5*64,0,6*64,64))
 greens={p[:3] for p in (grass.get_flattened_data() if hasattr(grass,"get_flattened_data") else grass.getdata()) if p[3] and p[1]>p[0]*1.05 and p[1]>p[2]*1.05}
 for path in sorted(source.glob('*.png')):
  im=Image.open(path).convert('RGBA')
  if path.stem in ['road','water','plaza']:
   raised=Image.new('RGBA',(64,64));raised.paste(im,(0,-8));im=raised
  elif not path.stem.startswith('grass'):
   pixels=im.load()
   for y in range(24,64):
    for x in range(64):
     r,g,b,a=pixels[x,y]
     if (r,g,b) in greens:pixels[x,y]=(int(r*.84),int(g*.78),int(b*.83),a)
  im=clip_surface(im)
  if path.stem=='forge':
   d=ImageDraw.Draw(im);d.rectangle((29,20,32,26),fill='#475052');d.rectangle((29,19,33,21),fill='#77817b');d.line((30,20,32,20),fill='#263437')
  if path.stem.startswith('grass') or path.stem in ['road','water','plaza']:
   fallback={'road':(148,132,99,255),'water':(53,120,131,255),'plaza':(139,139,120,255)}.get(path.stem,(52,106,59,255))
   pixels=im.load()
   for y in range(64):
    for x in range(64):
     xx=x+.5-32;yy=y+.5-40;u=xx/64+yy/32;v=yy/32-xx/64
     inside=-.5<=u<.5 and -.5<=v<.5
     if not inside:pixels[x,y]=(0,0,0,0)
     elif not pixels[x,y][3]:pixels[x,y]=fallback
  im.save(out/path.name)
 animations=assets/'buildings/visual_v021';animations.mkdir(exist_ok=True)
 # Only the crown above y=24 moves. Ground and trunk never shear.
 tree=Image.open(out/'tree.png').convert('RGBA');atlas=Image.new('RGBA',(256,64))
 for i,offset in enumerate([0,1,0,-1]):
  frame=tree.copy();frame.paste((0,0,0,0),(0,0,64,24));crown=tree.crop((0,0,64,24));frame.alpha_composite(crown,(offset,0)) if offset>=0 else frame.paste(crown,(offset,0),crown)
  atlas.paste(frame,(64*i,0))
 atlas.save(animations/'tree_animation.png')
 native=assets/'characters/native';native.mkdir(exist_ok=True)
 for i in range(24):
  src=Image.open(assets/'characters'/f'{i}.png').convert('RGBA');atlas=Image.new('RGBA',(240,105))
  for row in range(3):
   for frame in range(8):
    crop=src.crop((frame*48,row*56,frame*48+48,row*56+56)).resize((30,35),Image.Resampling.NEAREST)
    assert crop.getbbox() is not None and crop.getbbox()[3]==35
    atlas.paste(crop,(frame*30,row*35))
  atlas.save(native/f'{i}.png')
 src=Image.open(assets/'horses/horse.png').convert('RGBA');atlas=Image.new('RGBA',(384,96))
 for row in range(2):
  for frame in range(8):
   crop=src.crop((frame*64,row*64,frame*64+64,row*64+64));pixels=crop.load()
   for y in range(64):
    for x in range(64):
     if pixels[x,y][3]<128:pixels[x,y]=(0,0,0,0)
   crop=crop.resize((48,48),Image.Resampling.NEAREST);atlas.paste(crop,(frame*48,row*48))
 atlas.save(assets/'horses/horse_native_v021.png')
 policy={'version':'0.2.1','tile_cell':[64,64],'tile_surface_origin':[32,40],'tile_diamond':[64,32],'character_frame':[30,35],'character_pivot':[15,35],'horse_frame':[48,48],'horse_pivot':[24,41],'originals_modified':False,'resampling':'nearest, once during pipeline; runtime 1:1','source_hashes':{str(p.relative_to(assets)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [source/'grass.png',source/'road.png',assets/'characters/0.png',assets/'horses/horse.png']}}
 (assets/'ui/render_policy_v021.json').write_text(json.dumps(policy,indent=2),encoding='utf-8')
 print('VISUAL_PATCH_ASSETS_OK: surface origin 32,40; extrusion clipped; native frames and fixed-root tree wind')
if __name__=='__main__':build(Path(__file__).resolve().parents[2])
