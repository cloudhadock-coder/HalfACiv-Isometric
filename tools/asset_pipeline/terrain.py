"""Native-grid surfaces for expansion: fixed diamond mask, no character/portrait edits."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
def build(root=ROOT):
 folder=Path(root)/'assets/tilesets/visual_v021';folder.mkdir(parents=True,exist_ok=True)
 for name,palette in {'dirt':['#88734f','#9c855d','#756246','#ac9365'],'sand':['#c0ae7b','#cfbe8c','#ad9b6b','#d9c995'],'stone':['#77858b','#91a0a3','#606f79','#a6b1ac']}.items():
  im=Image.new('RGBA',(64,64))
  for y in range(64):
   for x in range(64):
    u=(x+.5-32)/64+(y+.5-40)/32;v=(y+.5-40)/32-(x+.5-32)/64
    if -.5<=u<.5 and -.5<=v<.5:
     index=0
     if (x*13+y*7)%23==0:index=1
     if (x*3+y*17)%41==0:index=2
     if name=='stone' and (x//3*17+y//2*13)%19==0:index=2
     if name=='stone' and (x//3*17+(y+1)//2*13)%19==0 and y%2==0:index=3
     if name=='sand' and (x-y*2)%19==0:index=3
     im.putpixel((x,y),tuple(bytes.fromhex(palette[index][1:]))+(255,))
  im.save(folder/f'{name}.png')
 print('TERRAIN_ASSETS_OK dirt sand stone native=64x64 pivot=32,40')
if __name__=='__main__':build()
