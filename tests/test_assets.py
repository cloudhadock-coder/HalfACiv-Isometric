from pathlib import Path
import sys,unittest,hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
class Assets(unittest.TestCase):
 def test_character_frames(self):
  for i in range(24):
   im=Image.open(ROOT/f'assets/characters/{i}.png')
   self.assertEqual(im.size,(384,168))
   for y,n in [(0,5),(1,8),(2,8)]:
    frames=[]
    for x in range(n):
     f=im.crop((x*48,y*56,x*48+48,y*56+56));self.assertIsNotNone(f.getbbox());frames.append(hashlib.sha256(f.tobytes()).hexdigest())
    self.assertGreater(len(set(frames)),1,'animation must actually change')
 def test_portraits(self):
  hashes=set()
  for i in range(24):
   im=Image.open(ROOT/f'assets/portraits/{i}.png');self.assertEqual(im.size,(96,112));hashes.add(hashlib.sha256(im.tobytes()).hexdigest())
  self.assertEqual(len(hashes),24)
 def test_environment_atlases(self):
  for name in ['mill','tower']:
   im=Image.open(ROOT/f'assets/buildings/{name}_animation.png');self.assertEqual(im.size,(256,64))
   frames=[im.crop((f*64,0,f*64+64,64)).tobytes() for f in range(4)]
   self.assertGreater(len(set(frames)),1)
 def test_deterministic_extension(self):
  import importlib.util,tempfile,shutil
  spec=importlib.util.spec_from_file_location('village_art',ROOT/'tools/asset_pipeline/village_art.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   scratch=Path(temp);(scratch/'assets').mkdir();(scratch/'docs').mkdir()
   shutil.copytree(ROOT/'assets/original',scratch/'assets/original')
   for name in ['tilesets','characters','portraits','buildings','ui']:(scratch/'assets'/name).mkdir()
   shutil.copytree(ROOT/'assets/tilesets',scratch/'assets/tilesets',dirs_exist_ok=True)
   module.build(scratch)
   for name in ['portraits/17.png','characters/23.png','tilesets/forge.png','buildings/mill_animation.png']:
    self.assertEqual((scratch/'assets'/name).read_bytes(),(ROOT/'assets'/name).read_bytes(),name)
   (scratch/'assets/horses').mkdir();shutil.copy2(ROOT/'assets/horses/horse.png',scratch/'assets/horses/horse.png')
   patch_spec=importlib.util.spec_from_file_location('visual_patch',ROOT/'tools/asset_pipeline/visual_patch.py');patch=importlib.util.module_from_spec(patch_spec);patch_spec.loader.exec_module(patch);patch.build(scratch)
   for name in ['characters/native/0.png','tilesets/visual_v021/road.png','tilesets/visual_v021/grass.png','buildings/visual_v021/tree_animation.png','horses/horse_native_v021.png']:
    self.assertEqual((scratch/'assets'/name).read_bytes(),(ROOT/'assets'/name).read_bytes(),name)
 def test_v021_surface_masks(self):
  for name in ['grass','grass_1','grass_2','grass_3','road','water','plaza']:
   im=Image.open(ROOT/f'assets/tilesets/visual_v021/{name}.png').convert('RGBA')
   for y in range(64):
    for x in range(64):
     xx=x+.5-32;yy=y+.5-40;u=xx/64+yy/32;v=yy/32-xx/64
     self.assertEqual(im.getpixel((x,y))[3]>0,-.5<=u<.5 and -.5<=v<.5,(name,x,y))
 def test_v021_native_feet_and_roots(self):
  for i in range(24):
   im=Image.open(ROOT/f'assets/characters/native/{i}.png');self.assertEqual(im.size,(240,105))
   for row in range(3):
    for f in range(8):self.assertEqual(im.crop((f*30,row*35,f*30+30,row*35+35)).getbbox()[3],35)
  tree=Image.open(ROOT/'assets/buildings/visual_v021/tree_animation.png')
  roots=[tree.crop((f*64,24,f*64+64,64)).tobytes() for f in range(4)];self.assertEqual(len(set(roots)),1,'wind may not move terrain/trunk')
  horse=Image.open(ROOT/'assets/horses/horse_native_v021.png');self.assertEqual(horse.size,(384,96))
  for row in range(2):
   for f in range(8):
    frame=horse.crop((f*48,row*48,f*48+48,row*48+48));self.assertLessEqual(frame.getbbox()[3],41)
    self.assertTrue(set(frame.getchannel('A').tobytes()) <= {0,255},'no baked second shadow')
 def test_horse(self):
  im=Image.open(ROOT/'assets/horses/horse.png');self.assertEqual(im.size,(512,128))
  for row in range(2):
   frames=[im.crop((f*64,row*64,f*64+64,row*64+64)).tobytes() for f in range(8)]
   self.assertGreater(len(set(frames)),3)
if __name__=='__main__':unittest.main()
