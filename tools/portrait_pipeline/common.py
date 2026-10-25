"""Shared paths, manifest access and pixel-art checks for the portrait pipeline.
Image processing only: nothing here draws or invents faces.
"""
from pathlib import Path
import sys,json,hashlib,math
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/python_libs'))
from PIL import Image
MANIFEST='assets/portraits/portraits.json'
# Official references are local-only (license forbids redistribution); hashes pin the exact files.
REFERENCES={'assets/art_reference/portraits/female_reference.png':'db9a8939cced9cc098a266e04fd5d0b2f4a1fe9d2e793686fdf94a8950c5aabe',
 'assets/art_reference/portraits/male_reference.png':'6ecb96e4269191495650841ca0d1867979b9c3b7c4d760c6bfadf32c60060ddb'}
REFERENCE_SCALE=3;REFERENCE_CELL=64
CANVAS=(64,64);LEGACY=(96,112);MAX_COLORS=48
def load_manifest(root=ROOT):return json.loads((Path(root)/MANIFEST).read_text(encoding='utf-8'))
def save_manifest(doc,root=ROOT):(Path(root)/MANIFEST).write_text(json.dumps(doc,ensure_ascii=False,indent=1)+'\n',encoding='utf-8',newline='\n')
def resolved(entry,root=ROOT):
 """Approved art wins; otherwise the preserved legacy portrait is the fallback (same rule as the game)."""
 if entry['status']=='approved' and entry.get('approved'):return Path(root)/entry['approved']
 return Path(root)/entry['fallback']
def read(path):
 with Image.open(path) as im:return im.copy()
def digest(im):return hashlib.sha256(im.convert('RGBA').tobytes()).hexdigest()
def block_scale(im):
 """Largest k for which the image is made only of uniform k×k blocks (1 = native pixel art)."""
 im=im.convert('RGBA');w,h=im.size;g=math.gcd(w,h)
 for k in sorted([d for d in range(2,g+1) if g%d==0],reverse=True):
  # Re-expanding one sample per block reproduces the image exactly only if every block is uniform.
  if im.resize((w//k,h//k),Image.NEAREST).resize((w,h),Image.NEAREST).tobytes()==im.tobytes():return k
 return 1
def opaque_colors(im):
 data=im.convert('RGBA').tobytes()
 return {data[i:i+4] for i in range(0,len(data),4) if data[i+3]}
def final_image_errors(im):
 """Technical gate for a final 64×64 portrait. Passing it is necessary, never sufficient, for approval."""
 errors=[]
 if im.mode!='RGBA':errors.append(f'modo {im.mode}; exigido RGBA')
 im=im.convert('RGBA')
 if im.size!=CANVAS:errors.append(f'tamanho {im.size}; exigido {CANVAS}');return errors
 alpha=set(im.getchannel('A').tobytes())
 if not alpha<= {0,255}:errors.append('alfa parcial (antialiasing/blur): use apenas 0 ou 255')
 if 0 not in alpha:errors.append('sem fundo transparente')
 if any(im.getpixel((x,0))[3] for x in range(CANVAS[0])):errors.append('linha superior ocupada: chapéu/coroa/cabelo cortado no topo')
 colors=len(opaque_colors(im))
 if colors>MAX_COLORS:errors.append(f'{colors} cores opacas; máximo {MAX_COLORS} (referências usam ~40)')
 if colors<12:errors.append(f'apenas {colors} cores: detalhamento insuficiente para o padrão')
 if block_scale(im)>1:errors.append('imagem ampliada (blocos uniformes): exporte na resolução lógica')
 box=im.getbbox()
 if box and (box[2]-box[0]<40 or box[3]-box[1]<44):errors.append(f'silhueta pequena {box}: busto deve ocupar o quadro')
 return errors
