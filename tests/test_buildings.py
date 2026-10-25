from pathlib import Path
import sys,json,unittest,tempfile,hashlib,importlib.util
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
DIRECTORY=ROOT/'assets/buildings/native_v042'
spec=importlib.util.spec_from_file_location('building_pipeline',ROOT/'tools/asset_pipeline/buildings.py')
pipeline=importlib.util.module_from_spec(spec);spec.loader.exec_module(pipeline)
class Buildings(unittest.TestCase):
 def test_catalog_and_sequences(self):
  doc=json.loads((DIRECTORY/'manifest.json').read_text());self.assertEqual(len(doc['animations']),18)
  self.assertEqual(doc['pivot'],[32,40]);self.assertEqual(doc['frame'],[64,64])
  for name,data in doc['animations'].items():
   with Image.open(DIRECTORY/data['atlas']) as im:
    self.assertEqual(im.size,(64*data['count'],64))
    frames=[im.crop((i*64,0,i*64+64,64)) for i in range(data['count'])]
    self.assertTrue(all(f.getbbox() for f in frames))
    self.assertGreater(len({f.tobytes() for f in frames}),1 if data['count']>1 else 0)
    with Image.open(DIRECTORY/data['preview']) as preview:self.assertEqual(frames[0].tobytes(),preview.tobytes())
    for frame in frames:
     # Alpha 68 is present in the native sheet (smoke/shadow); preserve it without filtering.
     self.assertLessEqual(set(frame.getchannel('A').get_flattened_data()),{0,68,255})
     for y in range(64):
      for x in range(64):
       if y+.5>=56-abs(x+.5-32)*.5:self.assertEqual(frame.getpixel((x,y))[3],0)
 def test_real_frames_not_different_buildings(self):
  for name in ['tower','barracks','house','bakery','tavern','workshop','herbalist']:
   with Image.open(DIRECTORY/f'{name}_atlas.png') as im:
    foundations={im.crop((i*64,32,i*64+64,64)).tobytes() for i in range(im.width//64)}
    self.assertEqual(len(foundations),1,name+' foundation/roof must not change structure')
 def test_loop_seam_is_comparable_to_native_frame_steps(self):
  data=json.loads((DIRECTORY/'manifest.json').read_text())['animations']
  for name,entry in data.items():
   if entry['count']<2:continue
   with Image.open(DIRECTORY/entry['atlas']) as image:
    frames=[list(image.crop((i*64,0,i*64+64,64)).get_flattened_data()) for i in range(entry['count'])]
    steps=[sum(a!=b for a,b in zip(frames[i],frames[(i+1)%len(frames)])) for i in range(len(frames))]
    self.assertLessEqual(steps[-1],max(steps[:-1])*1.25,name+' loop seam pixel change')
 def test_wheat_fence_is_fixed(self):
  source=Image.open(ROOT/'assets/original/sprite-Sheet.png').convert('RGBA').crop((0,320,64,384))
  with Image.open(DIRECTORY/'farm_atlas.png') as im:
   for y in range(64):
    for x in range(64):
     if not pipeline.wheat(source.getpixel((x,y))):
      self.assertEqual(len({im.getpixel((i*64+x,y)) for i in range(16)}),1,'fence/soil must stay fixed')
 def test_deterministic_and_source_preserved(self):
  source=ROOT/'assets/art_reference/Buildings/sprite-Sheet.png';before=hashlib.sha256(source.read_bytes()).hexdigest()
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   pipeline.build(Path(temp),source)
   for file in DIRECTORY.glob('*'):
    if file.suffix in ['.png','.json']:self.assertEqual(file.read_bytes(),(Path(temp)/'assets/buildings/native_v042'/file.name).read_bytes())
  self.assertEqual(before,hashlib.sha256(source.read_bytes()).hexdigest())
 def test_deprecated_atlases_not_restored(self):
  for path in ['assets/buildings','assets/buildings/visual_v021']:
   for name in ['mill','tower']:self.assertFalse((ROOT/path/f'{name}_animation.png').exists())
if __name__=='__main__':unittest.main()
