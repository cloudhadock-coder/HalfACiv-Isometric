"""Layered, native-grid cavalry variants. Originals are never modified.
Existing lateral horse animation is retained; these are not claimed as eight directions.
"""
from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image,ImageDraw
COLORS=['#b44946','#456eac','#4d855a','#c9a447','#875c9b','#353a46']
COATS=[(1,1,1),(.38,.40,.46),(1.7,1.65,1.5),(1.05,1.12,1.18),(.73,.55,.45)]
def build():
 out=ROOT/'assets/horses/cavalry';out.mkdir(exist_ok=True)
 src=Image.open(ROOT/'assets/horses/horse_native_v021.png').convert('RGBA')
 for n,factors in enumerate(COATS):
  im=src.copy();px=im.load()
  for y in range(im.height):
   for x in range(im.width):
    r,g,b,a=px[x,y]
    # Warm coat only: retain eyes, mane, hooves and tack contrast.
    if a and r>g*1.15 and g>b*1.1:
     px[x,y]=(*[min(240,int(v*f)) for v,f in zip((r,g,b),factors)],a)
  im.save(out/f'coat_{n}.png')
 for name in ['cloth','armor','banner','rider_armor']:
  for color,hexcolor in enumerate(['#aab5bf'] if name in ['armor','rider_armor'] else COLORS):
   atlas=Image.new('RGBA',src.size)
   for row in range(2):
    for frame in range(8):
     # Explicit pixel contours follow the body's breathing/walking cycle.
     bob=([0,0,-1,-1,0,0,1,1] if row else [0,0,0,-1,-1,0,0,0])[frame]
     layer=Image.new('RGBA',(48,48));d=ImageDraw.Draw(layer)
     if name=='cloth':
      d.polygon([(12,23+bob),(27,23+bob),(29,31+bob),(25,35+bob),(21,33+bob),(17,35+bob),(12,32+bob)],fill=hexcolor,outline='#27303b')
      d.line((14,25+bob,26,25+bob),fill='#d8bd79');d.line((20,26+bob,20,32+bob),fill='#dfc78f');d.line((17,29+bob,23,29+bob),fill='#dfc78f')
     elif name=='armor':
      d.polygon([(30,17+bob),(35,16+bob),(39,20+bob),(36,25+bob),(31,22+bob)],fill=hexcolor,outline='#35434f')
      d.line((32,18+bob,36,20+bob),fill='#e4e8dc');d.line((33,22+bob,36,23+bob),fill='#657888')
     elif name=='rider_armor':
      d.polygon([(21,5+bob),(25,3+bob),(29,5+bob),(29,10+bob),(22,10+bob)],fill='#adb8be',outline='#35434f')
      d.line((23,5+bob,26,4+bob),fill='#e6e9db');d.line((25,7+bob,28,7+bob),fill='#34404c')
      d.polygon([(20,13+bob),(25,12+bob),(28,16+bob),(25,21+bob),(21,19+bob)],fill='#8999a8',outline='#35434f')
      d.line((22,14+bob,25,14+bob),fill='#dce1d5')
     else:
      d.line((9,7+bob,9,30+bob),fill='#493c33',width=1)
      wave=[0,1,2,1,0,-1,-2,-1][frame]
      d.polygon([(10,7+bob),(21,8+bob+wave),(18,12+bob+wave),(21,16+bob+wave),(10,15+bob)],fill=hexcolor,outline='#28303a')
      d.line((12,9+bob,12,13+bob),fill='#e3c987');d.point((14,11+bob),fill='#e3c987')
     atlas.alpha_composite(layer,(frame*48,row*48))
   atlas.save(out/f'{name}_{color}.png')
 (out/'metadata.json').write_text(json.dumps({'frame':[48,48],'pivot':[24,41],'layers':['coat','cloth','armor','rider','rider_armor','banner'],'directions':['lateral original'],'animation_rows':['idle','walk'],'gaits':'walk cycle at 7/10/14 fps; no new anatomical gait frames','coats':5,'heraldry':6,'source':'../horse_native_v021.png'},indent=2))
 print('CAVALRY_ASSETS_OK: 5 coats, 6 cloths, armor, 6 banners; native 48px')
if __name__=='__main__':build()
