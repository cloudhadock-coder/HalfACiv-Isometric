"""Build thumbnails, the texture atlas and the visual validation gallery from the manifest.

python tools/portrait_pipeline/generate_atlas.py
Every image is copied or cropped at whole pixels; nothing is resampled except integer
nearest-neighbour enlargement in the gallery. When the local official references exist, a
side-by-side comparison is also written to docs/portrait-validation/local/ (ignored by Git).
"""
from pathlib import Path
import sys,json
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import read,ROOT,CANVAS,LEGACY,REFERENCES,REFERENCE_SCALE,REFERENCE_CELL,Image,load_manifest,resolved,digest
from PIL import ImageDraw,ImageFont
UI_BG='#17252b';UI_BORDER='#8d7955';TEXT='#e4dac4';GOLD='#dfbd72';PENDING='#dda176';OK='#a6bb87'
LEGACY_FACE=(16,8,80,72)  # 64×64 head-and-shoulders window inside the 96×112 legacy frame
def thumbnail(entry,root):
 im=read(resolved(entry,root)).convert('RGBA')
 return im if im.size==CANVAS else im.crop(LEGACY_FACE)
def enlarge(im,k):return im.resize((im.width*k,im.height*k),Image.NEAREST)
def checker(size,cell=4):
 im=Image.new('RGBA',size,'#3a4448');d=ImageDraw.Draw(im)
 for y in range(0,size[1],cell):
  for x in range(0,size[0],cell):
   if (x//cell+y//cell)%2:d.rectangle((x,y,x+cell-1,y+cell-1),fill='#545e62')
 return im
def font(size):
 # Label text only (not art): a system font with Latin-1 glyphs, else Pillow's built-in.
 for name in ['C:/Windows/Fonts/segoeui.ttf','/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']:
  if Path(name).exists():return ImageFont.truetype(name,size)
 return ImageFont.load_default(size)
def gallery(entries,root):
 cols=6;cw,ch=232,348;head=64
 rows=(len(entries)+cols-1)//cols;out=Image.new('RGBA',(cols*cw+16,head+rows*ch+8),'#0d1519');d=ImageDraw.Draw(out);d.fontmode='1'
 final=sum(e['status']=='approved' for e in entries)
 d.text((12,10),'HalfACiv Isometric — galeria de validação de retratos',fill=GOLD,font=font(18))
 d.text((12,36),f'{len(entries)} NPCs · {final} aprovados no padrão 64×64 · {len(entries)-final} fallback legado (PENDENTE) · 2× e 1× nearest-neighbor',fill=TEXT,font=font(13))
 for n,e in enumerate(entries):
  x=8+(n%cols)*cw;y=head+(n//cols)*ch;im=read(resolved(e,root)).convert('RGBA')
  d.rectangle((x,y,x+cw-8,y+ch-8),fill=UI_BG,outline=UI_BORDER)
  big=enlarge(im,2);out.alpha_composite(big,(x+(cw-8-big.width)//2,y+8+(224-big.height)))
  small=thumbnail(e,root);out.alpha_composite(small,(x+24,y+272))
  board=checker(CANVAS);board.alpha_composite(small);out.alpha_composite(board,(x+cw-8-24-64,y+272))
  approved=e['status']=='approved'
  d.text((x+8,y+236),f"#{e['id']} {e['npc']} · {e['role']}",fill=TEXT,font=font(12))
  d.text((x+8,y+254),'APROVADO' if approved else 'PENDENTE',fill=OK if approved else PENDING,font=font(11))
 return out
def comparison(entries,root):
 cells=[]
 for name in REFERENCES:
  sheet=read(root/name).convert('RGBA');native=sheet.resize((sheet.width//REFERENCE_SCALE,sheet.height//REFERENCE_SCALE),Image.NEAREST)
  # Sheets are 4×3 grids; the male sheet is trimmed to 253×190, so cells are located by pitch.
  px,py=native.width/4,native.height/3
  for r in range(3):
   for c in range(4):x=min(round(c*px),native.width-REFERENCE_CELL);y=min(round(r*py),native.height-REFERENCE_CELL);cells.append(native.crop((x,y,x+64,y+64)))
 ours=[thumbnail(e,root) for e in entries];cols=12;k=2;gap=8
 rows_ref=(len(cells)+cols-1)//cols;rows_our=(len(ours)+cols-1)//cols
 out=Image.new('RGBA',(cols*(64*k+gap)+gap,40+(rows_ref+rows_our)*(64*k+gap)+40),UI_BG);d=ImageDraw.Draw(out);d.fontmode='1'
 d.text((gap,12),'REFERÊNCIAS OFICIAIS (64×64 nativo, 2×) — uso local, não redistribuir',fill=GOLD,font=font(14))
 for n,im in enumerate(cells):out.alpha_composite(enlarge(im,k),(gap+(n%cols)*(64*k+gap),40+(n//cols)*(64*k+gap)))
 top=40+rows_ref*(64*k+gap)
 d.text((gap,top+10),'RETRATOS DO JOGO (janela 64×64, 2×)',fill=GOLD,font=font(14))
 for n,im in enumerate(ours):out.alpha_composite(enlarge(im,k),(gap+(n%cols)*(64*k+gap),top+40+(n//cols)*(64*k+gap)))
 return out
def build(root=ROOT,docs=True):
 root=Path(root);entries=load_manifest(root)['portraits'];base=root/'assets/portraits'
 for e in entries:thumbnail(e,root).save(base/'thumbnails'/f"{e['id']}.png")
 cols=8;cw,ch=LEGACY;atlas=Image.new('RGBA',(cols*cw,((len(entries)+cols-1)//cols)*ch),(0,0,0,0));rects={}
 for n,e in enumerate(entries):
  im=read(resolved(e,root)).convert('RGBA');x=(n%cols)*cw+(cw-im.width)//2;y=(n//cols)*ch+(ch-im.height)//2
  atlas.alpha_composite(im,(x,y));rects[str(e['id'])]={'npc':e['npc'],'x':x,'y':y,'w':im.width,'h':im.height,'status':e['status'],'sha256':digest(im)}
 atlas.save(base/'generated/portrait_atlas.png')
 (base/'generated/portrait_atlas.json').write_text(json.dumps({'cell':[cw,ch],'columns':cols,'portraits':rects},ensure_ascii=False,indent=1)+'\n',encoding='utf-8',newline='\n')
 if docs:
  (root/'docs/portrait-validation').mkdir(parents=True,exist_ok=True);gallery(entries,root).save(root/'docs/portrait-validation/portrait-gallery.png')
  if all((root/name).exists() for name in REFERENCES):
   (root/'docs/portrait-validation/local').mkdir(exist_ok=True);comparison(entries,root).save(root/'docs/portrait-validation/local/reference-comparison.png')
 return len(entries)
if __name__=='__main__':print(f'PORTRAIT_ATLAS_OK portraits={build()}')
