from pathlib import Path
import sys,unittest,tempfile,importlib.util
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
class TerrainTests(unittest.TestCase):
 def test_native_mask_palette_and_distinct_surfaces(self):
  surfaces=[]
  for name in ['dirt','stone','sand']:
   with Image.open(ROOT/f'assets/tilesets/visual_v021/{name}.png') as im:
    self.assertEqual(im.size,(64,64));self.assertLessEqual(len(im.getcolors()),5)
    for y in range(64):
     for x in range(64):
      u=(x+.5-32)/64+(y+.5-40)/32;v=(y+.5-40)/32-(x+.5-32)/64
      self.assertEqual(im.getpixel((x,y))[3],255 if -.5<=u<.5 and -.5<=v<.5 else 0)
    surfaces.append(im.tobytes())
  self.assertEqual(len(set(surfaces)),3)
 def test_reproducible_without_portrait_changes(self):
  spec=importlib.util.spec_from_file_location('terrain',ROOT/'tools/asset_pipeline/terrain.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   module.build(Path(temp))
   self.assertFalse((Path(temp)/'assets/portraits').exists())
   for name in ['dirt','stone','sand']:self.assertEqual((Path(temp)/f'assets/tilesets/visual_v021/{name}.png').read_bytes(),(ROOT/f'assets/tilesets/visual_v021/{name}.png').read_bytes())
if __name__=='__main__':unittest.main()
