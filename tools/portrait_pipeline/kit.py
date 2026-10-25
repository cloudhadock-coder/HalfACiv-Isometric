"""Portrait parts kit: aligned 64×64 layers (heads, clothing, beards, hair, hats) combined in game.

python tools/portrait_pipeline/kit.py add <id> <slot> <image> [--base HEAD --mask MASK] [--dx N --dy N] [--fits a,b] [--ai-tool T --prompt "…"]
python tools/portrait_pipeline/kit.py bake
python tools/portrait_pipeline/kit.py promote <id> --by NAME --notes "…"
python tools/portrait_pipeline/kit.py preview

add keeps the original in assets/portraits/kit/source/ and writes parts/<id>.png with status
in_review. A head is the whole bust, moved only by whole pixels (--dx/--dy) to the kit's head
anchor. An overlay drawn over a head (an inpaint) is stored as the pixels that differ from that
head inside the mask, so it lines up with it exactly. Each opaque colour belongs to a material
(skin, hair, cloth) or to none (outline, eyes, metal); recolouring swaps whole material ramps
through tables baked here, so the game only looks colours up and never invents pixels.
The game uses a part only after promote (named human review), like any portrait.
"""
from pathlib import Path
import sys,json,shutil,datetime,argparse,colorsys,random
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import read,ROOT,CANVAS,Image,load_manifest,opaque_colors,final_image_errors
KIT='assets/portraits/kit/kit.json'
SLOTS=['head','clothing','beard','hair','hat']
# Material -> recipe key holding the chosen preset colour.
MATERIALS={'skin':'skin','hair':'hair_color','cloth':'cloth'}
TUNIC_TOP=36  # heads share the kit's framing: the eyes sit well above this row; cloth is recoloured only below it
def load_kit(root=ROOT):return json.loads((Path(root)/KIT).read_text(encoding='utf-8'))
def save_kit(doc,root=ROOT):(Path(root)/KIT).write_text(json.dumps(doc,ensure_ascii=False,indent=1)+'\n',encoding='utf-8',newline='\n')
def hexc(c):return '#%02x%02x%02x'%tuple(c[:3])
def rgb(h):return tuple(int(h[i:i+2],16) for i in (1,3,5))
def luma(h):r,g,b=rgb(h);return .299*r+.587*g+.114*b
def part(doc,pid):
 for p in doc['parts']:
  if p['id']==pid:return p
 raise KeyError(f'parte {pid} não existe no kit')
def classify(im,slot,base=None):
 """First guess of materials, to be checked by the reviewer (the kit.json lists are the truth).
 Overlays reuse the head's skin colours where they repaint skin; the rest of a hair or beard
 layer is hair. Heads: warm saturated tones are skin; greys used only below the chin are the
 undyed tunic. Cloth is only recoloured from TUNIC_TOP down (see compose), so a grey shared
 with the eyes never takes the cloth hue."""
 skin=set(base['materials'].get('skin',[])) if base else set();out={};bottom={}
 px=im.convert('RGBA').load()
 for y in range(CANVAS[1]):
  for x in range(CANVAS[0]):
   if px[x,y][3]:bottom[hexc(px[x,y])]=y
 for c in opaque_colors(im):
  h=hexc(c);hh,s,v=colorsys.rgb_to_hsv(*(x/255 for x in c[:3]))
  if v<.2 or (s<.12 and v>.92):continue  # outline, eye white
  if h in skin:out.setdefault('skin',[]).append(h)
  elif slot in('hair','beard'):out.setdefault('hair',[]).append(h)
  elif slot=='head':
   if s<.25:
    if bottom[h]>=TUNIC_TOP:out.setdefault('cloth',[]).append(h)
   elif hh<.13 or hh>.95:out.setdefault('skin',[]).append(h)
 return {k:sorted(v,key=luma) for k,v in out.items()}
def anchors(im,materials):
 """Each head's own midtone per material: the pixel-count-weighted median by luminance."""
 count={}
 for c in im.convert('RGBA').get_flattened_data():
  if c[3]:count[hexc(c)]=count.get(hexc(c),0)+1
 out={}
 for m,cols in materials.items():
  total=sum(count[c] for c in cols);acc=0
  for c in cols:
   acc+=count[c]
   if acc*2>=total:out[m]=c;break
 return out
def shift(h,anchor,target):
 """Move one colour of a material ramp from the kit anchor to a preset, keeping its hue shift
 and relative value/saturation (so the ramp structure drawn by the artist survives)."""
 ch,cs,cv=colorsys.rgb_to_hsv(*(x/255 for x in rgb(h)));ah,as_,av=colorsys.rgb_to_hsv(*(x/255 for x in rgb(anchor)));th,ts,tv=colorsys.rgb_to_hsv(*(x/255 for x in rgb(target)))
 # Greys (the undyed tunic) have no hue of their own: they take the preset's.
 hue=th if cs<.08 or as_<.08 else (ch+th-ah)%1
 sat=min(1,max(0,cs+ts-as_));val=min(1,cv*tv/max(av,.01))
 return hexc([round(x*255) for x in colorsys.hsv_to_rgb(hue,sat,val)])
def ramp(doc,root,m,target):
 """The preset's fixed ramp: the ramp-source part's material split into RAMP[m] luminance bands
 (pixel-weighted), each band's mean moved to the preset. Every part of every head draws that
 material with these tones only, so a combination stays inside the guide's colour budget."""
 src=next(p for p in doc['parts'] if p['id']==doc['ramp_source'][m]);count={}
 for c in read(Path(root)/src['file']).convert('RGBA').get_flattened_data():
  if c[3] and hexc(c) in src['materials'][m]:count[hexc(c)]=count.get(hexc(c),0)+1
 cols=sorted(count,key=luma);total=sum(count.values());k=doc['ramp_size'][m];bands=[[] for _ in range(k)];acc=0
 for c in cols:bands[min(k-1,int(k*(acc+count[c]/2)/total))].append(c);acc+=count[c]
 tones=[]
 for band in bands:
  if not band:continue
  w=sum(count[c] for c in band);mean=[round(sum(rgb(c)[i]*count[c] for c in band)/w) for i in range(3)]
  tones.append(shift(hexc(mean),src.get('anchors',{}).get(m,doc['anchors'][m]),target))
 return sorted(set(tones),key=luma)
def bake(doc,root=ROOT):
 ramps={m:{t:ramp(doc,root,m,t) for t in doc['presets'][m]} for m in MATERIALS}
 for p in doc['parts']:
  # A part may anchor a material on its own ramp (e.g. a green shirt) instead of the kit's.
  anchor=lambda m:p.get('anchors',{}).get(m,doc['anchors'][m])
  p['recolor']={m:{t:[min(ramps[m][t],key=lambda r:abs(luma(r)-luma(shift(h,anchor(m),t)))) for h in cols] for t in doc['presets'][m]} for m,cols in p['materials'].items()}
 return doc
def layer_from(head,drawn,mask=None):
 """Pixels of an inpainted composite that differ from its head (inside the mask): the overlay."""
 out=Image.new('RGBA',CANVAS,(0,0,0,0));h,d,o=head.load(),drawn.load(),out.load();m=mask.convert('L').load() if mask else None
 for y in range(CANVAS[1]):
  for x in range(CANVAS[0]):
   if d[x,y]!=h[x,y] and (m is None or m[x,y]>127):o[x,y]=d[x,y] if d[x,y][3] else (0,0,0,0)
 return out
def translate(im,dx,dy):
 out=Image.new('RGBA',CANVAS,(0,0,0,0));out.paste(im,(dx,dy));return out
def part_errors(im):
 errors=[]
 if im.mode!='RGBA' or im.size!=CANVAS:errors.append(f'{im.mode} {im.size}; exigido RGBA {CANVAS}')
 elif not set(im.getchannel('A').tobytes())<={0,255}:errors.append('alfa parcial')
 elif im.getbbox() is None:errors.append('camada vazia')
 elif any(im.getpixel((x,0))[3] for x in range(CANVAS[0])):errors.append('linha superior ocupada')
 return errors
def add(pid,slot,image,root=ROOT,base=None,mask=None,dx=0,dy=0,fits=None,ai_tool=None,prompt=None,force=False):
 root=Path(root);doc=load_kit(root)
 if slot not in SLOTS:raise ValueError(f'slot {slot}; use {SLOTS}')
 if any(p['id']==pid for p in doc['parts']) and not force:raise FileExistsError(f'parte {pid} já existe; use --force')
 drawn=read(image).convert('RGBA')
 if drawn.size!=CANVAS:raise ValueError(f'{drawn.size}; exigido {CANVAS}. Não redimensionamos arte.')
 head=None
 if slot=='head':
  if base:raise ValueError('cabeça não tem base')
  layer=translate(drawn,dx,dy)
 else:
  if not base:raise ValueError('camada sobreposta exige --base (a cabeça sobre a qual foi desenhada)')
  head=part(doc,base);layer=layer_from(read(root/head['file']).convert('RGBA'),drawn,read(mask) if mask else None)
 errors=part_errors(layer)
 if errors:raise ValueError('; '.join(errors))
 src=root/'assets/portraits/kit/source'/f'{pid}{Path(image).suffix.lower()}';shutil.copy2(image,src)
 if mask:shutil.copy2(mask,src.with_name(f'{pid}_mask.png'))
 out=root/'assets/portraits/kit/parts'/f'{pid}.png';layer.save(out,optimize=False)
 entry={'id':pid,'slot':slot,'file':out.relative_to(root).as_posix(),'status':'in_review','fits':fits or (['*'] if slot=='head' else [base]),
  'materials':classify(layer,slot,head),'source':{'drawn_over':base,'offset':[dx,dy],'ai_draft':ai_tool,'prompt':prompt},'recolor':{},'review':None}
 if slot=='head':entry['anchors']=anchors(layer,entry['materials'])
 doc['parts']=[p for p in doc['parts'] if p['id']!=pid]+[entry];save_kit(bake(doc,root),root);return out
def promote(pid,by,notes,root=ROOT,date=None):
 root=Path(root);doc=load_kit(root);p=part(doc,pid)
 errors=part_errors(read(root/p['file']))
 if errors:raise ValueError('; '.join(errors))
 if not by.strip() or not notes.strip():raise ValueError('aprovação exige revisor e notas da revisão visual')
 p.update(status='approved',review={'by':by,'date':date or datetime.date.today().isoformat(),'notes':notes});save_kit(doc,root)
def fits(p,head):return '*' in p['fits'] or head in p['fits'] or p['slot']=='head'
def compose(doc,recipe,root=ROOT,approved_only=True):
 """Same rule as src/ui/portrait_kit.gd: layers in slot order, material colours looked up in
 the baked tables. None when a part is missing, unapproved or not drawn for that head."""
 out=Image.new('RGBA',CANVAS,(0,0,0,0));byid={p['id']:p for p in doc['parts']}
 for slot in SLOTS:
  pid=recipe.get(slot,'')
  if not pid:
   if slot=='head':return None
   continue
  p=byid.get(pid)
  if p is None or p['slot']!=slot or (approved_only and p['status']!='approved') or not fits(p,recipe['head']):return None
  table={};cloth={}
  for m,cols in p['materials'].items():
   target=recipe.get(MATERIALS[m],'')
   if target in p['recolor'].get(m,{}):(cloth if m=='cloth' else table).update(zip(cols,p['recolor'][m][target]))
  layer=read(Path(root)/p['file']).convert('RGBA');px=layer.load();o=out.load()
  for y in range(CANVAS[1]):
   lookup={**table,**cloth} if y>=TUNIC_TOP else table
   for x in range(CANVAS[0]):
    c=px[x,y]
    if c[3]:h=hexc(c);o[x,y]=rgb(lookup[h])+(255,) if h in lookup else c
 return out
def random_recipe(doc,seed,approved_only=True):
 """Deterministic preview recipe; the game draws its own with the same structure."""
 r=random.Random(seed);usable=[p for p in doc['parts'] if p['status']=='approved' or not approved_only]
 heads=[p['id'] for p in usable if p['slot']=='head']
 if not heads:return {}
 recipe={'head':r.choice(heads)}
 for slot in SLOTS[1:]:
  options=[p['id'] for p in usable if p['slot']==slot and fits(p,recipe['head'])]
  recipe[slot]=r.choice(['']+options) if options else ''
 for m,key in MATERIALS.items():recipe[key]=r.choice(doc['presets'][m])
 return recipe
def validate(root=ROOT):
 root=Path(root);doc=load_kit(root);errors=[];pending=[]
 ids=[p['id'] for p in doc['parts']]
 if len(ids)!=len(set(ids)):errors.append('ids de partes repetidos')
 if doc.get('slots')!=SLOTS:errors.append(f'slots devem ser {SLOTS} (ordem de desenho)')
 for m in MATERIALS:
  if m not in doc['anchors'] or not doc['presets'].get(m):errors.append(f'material {m} sem âncora ou presets')
 heads={p['id'] for p in doc['parts'] if p['slot']=='head'}
 fresh=bake(json.loads(json.dumps(doc)),root)
 for p,f in zip(doc['parts'],fresh['parts']):
  tag=f"parte {p['id']}"
  if p['slot'] not in SLOTS:errors.append(f'{tag}: slot inválido');continue
  path=root/p['file']
  if not path.exists():errors.append(f'{tag}: arquivo ausente');continue
  im=read(path);errors+=[f'{tag}: {e}' for e in part_errors(im)]
  colors={hexc(c) for c in opaque_colors(im)}
  for m,cols in p['materials'].items():
   if m not in MATERIALS:errors.append(f'{tag}: material desconhecido {m}')
   if not set(cols)<=colors:errors.append(f'{tag}: {m} lista cores que a camada não tem')
  if p['recolor']!=f['recolor']:errors.append(f'{tag}: tabelas de recoloração desatualizadas; rode kit.py bake')
  for h in p['fits']:
   if h!='*' and h not in heads:errors.append(f'{tag}: encaixa em cabeça inexistente {h}')
  if p['status']=='approved':
   if not (isinstance(p['review'],dict) and p['review'].get('by') and p['review'].get('date')):errors.append(f'{tag}: aprovação sem revisão registrada')
  elif p['status']=='in_review':pending.append(p['id'])
  else:errors.append(f'{tag}: status inválido {p["status"]}')
 # Every approved combination the game can draw must meet the final portrait gate.
 for seed in range(64):
  recipe=random_recipe(doc,seed)
  if not recipe:break
  im=compose(doc,recipe,root)
  for e in final_image_errors(im) if im else ['receita não compõe']:errors.append(f'combinação {recipe}: {e}')
 return errors,pending
def preview(root=ROOT,count=24):
 """Parts sheet plus sample combinations (in-review parts included and labelled) for review."""
 from generate_atlas import font,enlarge,UI_BG,UI_BORDER,TEXT,GOLD,PENDING,OK
 from PIL import ImageDraw
 root=Path(root);doc=load_kit(root);parts=doc['parts'];cols=8;cw=148
 rows_p=(len(parts)+cols-1)//cols;rows_c=(count+cols-1)//cols
 out=Image.new('RGBA',(cols*cw+16,80+(rows_p+rows_c)*(cw+24)+40),'#0d1519');d=ImageDraw.Draw(out);d.fontmode='1'
 approved=sum(p['status']=='approved' for p in parts)
 d.text((12,10),'HalfACiv Isometric — kit de partes de retrato',fill=GOLD,font=font(18))
 d.text((12,36),f'{len(parts)} partes · {approved} aprovadas · {len(parts)-approved} em revisão (rascunho, não usado no jogo) · 2× nearest-neighbor',fill=TEXT,font=font(13))
 def cell(n,top,im,label,status):
  x=8+(n%cols)*cw;y=top+(n//cols)*(cw+24);d.rectangle((x,y,x+cw-8,y+cw+16),fill=UI_BG,outline=UI_BORDER)
  if im:out.alpha_composite(enlarge(im,2),(x+6,y+6))
  d.text((x+6,y+cw-6),label,fill=TEXT,font=font(11));d.text((x+6,y+cw+4),status,fill=OK if status=='APROVADA' else PENDING,font=font(10))
 for n,p in enumerate(parts):cell(n,72,read(root/p['file']).convert('RGBA'),f"{p['slot']} · {p['id']}",'APROVADA' if p['status']=='approved' else 'EM REVISÃO')
 top=72+rows_p*(cw+24)+8;d.text((12,top),'Combinações de exemplo (inclui partes em revisão)',fill=GOLD,font=font(14))
 for n in range(count):
  recipe=random_recipe(doc,n,approved_only=False);im=compose(doc,recipe,root,approved_only=False) if recipe else None
  colors=len(opaque_colors(im)) if im else 0
  cell(n,top+28,im,' '.join(recipe.get(s,'') or '-' for s in SLOTS[1:4]),f'{colors} cores'+(' (>48)' if colors>48 else ''))
 path=root/'docs/portrait-validation/kit-preview.png';path.parent.mkdir(parents=True,exist_ok=True);out.save(path);return path
def main():
 p=argparse.ArgumentParser();sub=p.add_subparsers(dest='cmd',required=True)
 a=sub.add_parser('add');a.add_argument('id');a.add_argument('slot');a.add_argument('image');a.add_argument('--base');a.add_argument('--mask')
 a.add_argument('--dx',type=int,default=0);a.add_argument('--dy',type=int,default=0);a.add_argument('--fits');a.add_argument('--ai-tool');a.add_argument('--prompt');a.add_argument('--force',action='store_true')
 sub.add_parser('bake');sub.add_parser('preview');sub.add_parser('validate')
 r=sub.add_parser('promote');r.add_argument('id');r.add_argument('--by',required=True);r.add_argument('--notes',required=True)
 args=p.parse_args()
 try:
  if args.cmd=='add':print('OK',add(args.id,args.slot,args.image,base=args.base,mask=args.mask,dx=args.dx,dy=args.dy,fits=args.fits.split(',') if args.fits else None,ai_tool=args.ai_tool,prompt=args.prompt,force=args.force).relative_to(ROOT).as_posix())
  elif args.cmd=='bake':save_kit(bake(load_kit()));print('KIT_BAKED')
  elif args.cmd=='promote':promote(args.id,args.by,args.notes);print('OK',args.id)
  elif args.cmd=='preview':print('OK',preview().relative_to(ROOT).as_posix())
  else:
   errors,pending=validate()
   for e in errors:print('ERRO',e)
   print(f'PENDENTES {len(pending)}: '+', '.join(pending))
   if errors:raise SystemExit(f'KIT_INVALID errors={len(errors)}')
   print('KIT_OK')
 except (ValueError,FileExistsError,FileNotFoundError,KeyError) as exc:raise SystemExit('REJEITADO: '+str(exc))
if __name__=='__main__':main()
