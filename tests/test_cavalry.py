from pathlib import Path
import sys,unittest,hashlib,subprocess
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
class CavalryTests(unittest.TestCase):
 def test_native_frames(self):
  for path in (ROOT/'assets/horses/cavalry').glob('*.png'):
   im=Image.open(path).convert('RGBA');self.assertEqual(im.size,(384,96));self.assertLessEqual(set(im.getchannel('A').get_flattened_data()),{0,255})
   for row in range(2):
    for frame in range(8):self.assertIsNotNone(im.crop((frame*48,row*48,(frame+1)*48,(row+1)*48)).getbbox())
 def test_color_and_coat_variations(self):
  for family,count in [('coat',5),('cloth',6),('banner',6)]:
   self.assertEqual(len({(ROOT/f'assets/horses/cavalry/{family}_{i}.png').read_bytes() for i in range(count)}),count)
 def test_deterministic_and_preserves_source(self):
  paths=list((ROOT/'assets/horses/cavalry').glob('*.png'))+[ROOT/'assets/horses/horse_native_v021.png']
  before={p:hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
  subprocess.run([sys.executable,str(ROOT/'tools/asset_pipeline/cavalry.py')],check=True,capture_output=True)
  self.assertEqual(before,{p:hashlib.sha256(p.read_bytes()).hexdigest() for p in paths})
if __name__=='__main__':unittest.main()
