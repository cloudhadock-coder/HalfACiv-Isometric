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
  import json
  folder=ROOT/'assets/buildings/native_v042'
  data=json.loads((folder/'manifest.json').read_text())['animations']
  for name in ['mill','tower','house','barracks','farm']:
   entry=data[name];count=entry['count']
   with Image.open(folder/entry['atlas']) as im:
    self.assertEqual(im.size,(64*count,64))
    self.assertGreater(len({im.crop((f*64,0,f*64+64,64)).tobytes() for f in range(count)}),1)
 def test_deterministic_extension(self):
  import importlib.util,tempfile,shutil
  spec=importlib.util.spec_from_file_location('village_art',ROOT/'tools/asset_pipeline/village_art.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   scratch=Path(temp);(scratch/'assets').mkdir();(scratch/'docs').mkdir()
   shutil.copytree(ROOT/'assets/original',scratch/'assets/original')
   for name in ['tilesets','characters','portraits','buildings','ui']:(scratch/'assets'/name).mkdir()
   shutil.copytree(ROOT/'assets/tilesets',scratch/'assets/tilesets',dirs_exist_ok=True)
   module.build(scratch)
   for name in ['portraits/17.png','characters/23.png','tilesets/forge.png']:
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
 def test_portrait_manifest_and_atlas(self):
  sys.path.insert(0,str(ROOT/'tools/portrait_pipeline'))
  import validate,generate_atlas,common
  errors,warnings,pending=validate.validate();self.assertEqual(errors,[])
  doc=common.load_manifest();self.assertEqual(len(doc['portraits']),24)
  # Every pending NPC keeps its v0.2 face as fallback; none is presented as final art.
  self.assertEqual(len(pending),sum(e['status']!='approved' for e in doc['portraits']))
  import tempfile,shutil
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   scratch=Path(temp);shutil.copytree(ROOT/'assets/portraits',scratch/'assets/portraits',ignore=shutil.ignore_patterns('*.import'))
   generate_atlas.build(scratch,docs=False);first=(scratch/'assets/portraits/generated/portrait_atlas.png').read_bytes()
   generate_atlas.build(scratch,docs=False);self.assertEqual(first,(scratch/'assets/portraits/generated/portrait_atlas.png').read_bytes())
   self.assertEqual(first,(ROOT/'assets/portraits/generated/portrait_atlas.png').read_bytes(),'committed atlas is stale')
 def test_portrait_prompts_current(self):
  sys.path.insert(0,str(ROOT/'tools/portrait_pipeline'))
  import prompts,common
  text=prompts.render(common.load_manifest())
  self.assertEqual(text,(ROOT/'docs/PORTRAIT_PROMPTS.md').read_text(encoding='utf-8'),'run tools/portrait_pipeline/prompts.py')
  self.assertEqual(text.count('```text'),25,'24 NPC prompts plus the shared negative')
  self.assertNotIn('art_reference',text.split('## Negativo comum')[1],'prompts never point at the official references')
 def test_portrait_export_gate(self):
  sys.path.insert(0,str(ROOT/'tools/portrait_pipeline'))
  import validate,export,common
  from PIL import ImageDraw
  # Synthetic fixture exercising the gate only; it is not portrait art.
  fixture=Image.new('RGBA',(64,64),(0,0,0,0));d=ImageDraw.Draw(fixture)
  for n in range(16):d.rectangle((8+n*3,4+n,10+n*3,63),fill=(40+n*12,30+n*8,20+n*5,255))
  import tempfile,shutil
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   scratch=Path(temp);shutil.copytree(ROOT/'assets/portraits',scratch/'assets/portraits',ignore=shutil.ignore_patterns('*.import'))
   drawing=scratch/'drawing.png';fixture.resize((192,192),Image.NEAREST).save(drawing)
   out=export.stage(3,drawing,root=scratch);self.assertEqual(Image.open(out).tobytes(),fixture.tobytes(),'3x export must reduce losslessly')
   self.assertEqual(drawing.read_bytes(),(scratch/'assets/portraits/source/3_darin.png').read_bytes(),'source preserved untouched')
   entry=common.load_manifest(scratch)['portraits'][3];self.assertEqual(entry['status'],'in_review')
   self.assertEqual(common.resolved(entry,scratch),scratch/'assets/portraits/3.png','in review still shows fallback')
   with self.assertRaises(ValueError):export.promote(3,'','',root=scratch)
   export.promote(3,'Diretor de arte','Comparado às referências',root=scratch,date='2026-10-25',ai_tool='PixelLab')
   self.assertEqual(common.load_manifest(scratch)['portraits'][3]['review']['ai_draft'],'PixelLab')
   self.assertEqual(validate.validate(scratch)[0],[])
   self.assertEqual(common.resolved(common.load_manifest(scratch)['portraits'][3],scratch),scratch/'assets/portraits/approved/3.png')
   for bad in [fixture.resize((100,100),Image.NEAREST),fixture.resize((128,128),Image.BILINEAR)]:
    with self.assertRaises(ValueError):export.to_native(bad)
   soft=fixture.copy();soft.putpixel((20,30),(90,60,40,128))
   with self.assertRaises(ValueError):export.to_native(soft)
   with self.assertRaises(FileExistsError):export.stage(3,drawing,root=scratch)
   self.assertTrue(common.final_image_errors(fixture.resize((128,128),Image.NEAREST)),'upscaled art must not pass')
 def test_portrait_kit(self):
  sys.path.insert(0,str(ROOT/'tools/portrait_pipeline'))
  import kit,common,hashlib as h
  errors,pending=kit.validate();self.assertEqual(errors,[])
  doc=kit.load_kit()
  probe={'head':'head_02','clothing':'clothing_jerkin','beard':'beard_full','hair':'hair_short','hat':'','skin':'#87563e','hair_color':'#29252b','cloth':'#536e97'}
  face=kit.compose(doc,probe,approved_only=False)
  # Pinned in tests/test_runner.gd too: Python and GDScript composers must agree byte for byte.
  self.assertEqual(h.sha256(face.tobytes()).hexdigest(),'b246898b2d41ea72a07d425760c8212519e1f898012d8a1862b0d4acb2f15cb7')
  self.assertEqual(common.final_image_errors(face),[],'a full combination meets the final portrait gate')
  # Unreviewed parts never compose for the game; layers only ever hold kit or ramp colours.
  if not any(p['status']=='approved' for p in doc['parts']):self.assertIsNone(kit.compose(doc,probe))
  self.assertIsNone(kit.compose(doc,{**probe,'head':'head_13'},approved_only=False),'clothing not drawn for that head')
  allowed={kit.hexc(c) for p in doc['parts'] for c in common.opaque_colors(common.read(ROOT/p['file']))}
  allowed|={c for p in doc['parts'] for m in p['recolor'].values() for tones in m.values() for c in tones}
  self.assertLessEqual({kit.hexc(c) for c in common.opaque_colors(face)},allowed)
  import tempfile,shutil
  with tempfile.TemporaryDirectory(prefix='halfaciv-art-',dir=ROOT/'tests') as temp:
   scratch=Path(temp);shutil.copytree(ROOT/'assets/portraits/kit',scratch/'assets/portraits/kit',ignore=shutil.ignore_patterns('*.import'))
   base=common.read(ROOT/'assets/portraits/kit/parts/head_09.png').convert('RGBA');drawn=base.copy()
   for x in range(20,30):drawn.putpixel((x,10),(90,50,30,255))
   art=scratch/'drawn.png';drawn.save(art)
   out=kit.add('hat_probe','hat',art,root=scratch,base='head_09')
   layer=common.read(out);self.assertEqual(layer.getbbox(),(20,10,30,11),'overlay keeps only what was drawn over the head')
   with self.assertRaises(ValueError):kit.add('bad','head',art,root=scratch,base='head_09')
   with self.assertRaises(ValueError):kit.add('bad2','hair',art,root=scratch)
   up=scratch/'up.png';base.resize((128,128),Image.NEAREST).save(up)
   with self.assertRaises(ValueError):kit.add('bad3','head',up,root=scratch)
   with self.assertRaises(ValueError):kit.promote('hat_probe','','',root=scratch)
   kit.promote('hat_probe','Diretor de arte','Conferido na galeria',root=scratch,date='2026-10-25')
   self.assertEqual(kit.part(kit.load_kit(scratch),'hat_probe')['status'],'approved')
   stale=kit.load_kit(scratch);stale['presets']['skin'].append('#ffffff');kit.save_kit(stale,scratch)
   self.assertTrue(any('desatualizadas' in e for e in kit.validate(scratch)[0]),'recolour tables must be rebaked')
 def test_horse(self):
  im=Image.open(ROOT/'assets/horses/horse.png');self.assertEqual(im.size,(512,128))
  for row in range(2):
   frames=[im.crop((f*64,row*64,f*64+64,row*64+64)).tobytes() for f in range(8)]
   self.assertGreater(len(set(frames)),3)
 def test_ui_chrome(self):
  # HUD chrome: fixed sizes (the 9-slice margins in src/ui/ui_theme.gd depend on them) and a deterministic build.
  import importlib.util,tempfile
  sizes={'panel':(32,32),'bar':(16,16),'title':(16,16),'grabber':(8,16),'button_normal':(16,16),'button_hover':(16,16),'button_pressed':(16,16),'button_disabled':(16,16),'button_field':(16,16)}
  for name in ['food','wood','stone','gold','influence','people']:sizes['icon_'+name]=(12,12)
  before={}
  for name,size in sizes.items():
   path=ROOT/f'assets/ui/{name}.png';self.assertEqual(Image.open(path).size,size,name)
   before[name]=hashlib.sha256(path.read_bytes()).hexdigest()
  spec=importlib.util.spec_from_file_location('build_ui',ROOT/'tools/ui_pipeline/build_ui.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  with tempfile.TemporaryDirectory() as tmp:
   module.OUT=Path(tmp);module.main()
   for name in sizes:self.assertEqual(Image.open(Path(tmp)/f'{name}.png').tobytes(),Image.open(ROOT/f'assets/ui/{name}.png').tobytes(),name+' is reproducible')
 def test_game_icon(self):
  # Every ICO frame is a whole-number enlargement of a hand-drawn master (16 or 32), pixel for pixel.
  import importlib.util
  spec=importlib.util.spec_from_file_location('build_icon',ROOT/'tools/ui_pipeline/build_icon.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  expected=module.frames()
  self.assertEqual(Image.open(ROOT/'assets/icon/icon.png').convert('RGBA').tobytes(),expected[256].tobytes(),'icon.png matches the 32px master at 8x')
  ico=Image.open(ROOT/'assets/icon/halfaciv.ico');self.assertEqual(sorted(ico.info['sizes']),[(s,s) for s in sorted(expected)])
  for size,img in expected.items():
   self.assertEqual(ico.ico.getimage((size,size)).convert('RGBA').tobytes(),img.tobytes(),f'{size}px frame is exact')
if __name__=='__main__':unittest.main()
