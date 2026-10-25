from pathlib import Path
import sys,unittest,hashlib
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
class Assets(unittest.TestCase):
 def test_character_frames(self):
  for i in range(12):
   im=Image.open(ROOT/f'assets/characters/{i}.png')
   self.assertEqual(im.size,(384,112))
   for y,n in [(0,5),(1,8)]:
    frames=[]
    for x in range(n):
     f=im.crop((x*48,y*56,x*48+48,y*56+56));self.assertIsNotNone(f.getbbox());frames.append(hashlib.sha256(f.tobytes()).hexdigest())
    self.assertGreater(len(set(frames)),1,'animation must actually change')
 def test_portraits(self):
  hashes=set()
  for i in range(12):
   im=Image.open(ROOT/f'assets/portraits/{i}.png');self.assertEqual(im.size,(64,80));hashes.add(hashlib.sha256(im.tobytes()).hexdigest())
  self.assertEqual(len(hashes),12)
 def test_horse(self):
  im=Image.open(ROOT/'assets/horses/horse.png');self.assertEqual(im.size,(512,128))
  for row in range(2):
   frames=[im.crop((f*64,row*64,f*64+64,row*64+64)).tobytes() for f in range(8)]
   self.assertGreater(len(set(frames)),3)
if __name__=='__main__':unittest.main()
