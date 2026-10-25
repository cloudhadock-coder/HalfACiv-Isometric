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
   module.build(scratch)
   for name in ['portraits/17.png','characters/23.png','tilesets/forge.png','buildings/mill_animation.png']:
    self.assertEqual((scratch/'assets'/name).read_bytes(),(ROOT/'assets'/name).read_bytes(),name)
 def test_horse(self):
  im=Image.open(ROOT/'assets/horses/horse.png');self.assertEqual(im.size,(512,128))
  for row in range(2):
   frames=[im.crop((f*64,row*64,f*64+64,row*64+64)).tobytes() for f in range(8)]
   self.assertGreater(len(set(frames)),3)
if __name__=='__main__':unittest.main()
