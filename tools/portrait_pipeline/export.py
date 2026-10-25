"""Bring hand-drawn portrait art into the game without altering a single pixel.

Stage:   python tools/portrait_pipeline/export.py stage <id> <drawing.png> [--force]
Promote: python tools/portrait_pipeline/export.py promote <id> --by NAME --notes "visual review"

stage keeps an untouched copy in assets/portraits/source/, reduces an integer upscale (e.g. an
Aseprite 3× export) back to native pixels by sampling whole blocks, and writes
assets/portraits/generated/<id>.png with status in_review. Non-integer scales, wrong canvas,
partial alpha or excess colours are rejected, never resized or filtered.
promote requires a named human visual review against the references and the style guide.
"""
from pathlib import Path
import sys,shutil,datetime,argparse
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import read,ROOT,CANVAS,Image,load_manifest,save_manifest,block_scale,final_image_errors
def to_native(im):
 im=im.convert('RGBA');k=block_scale(im);w,h=im.size
 native=im.resize((w//k,h//k),Image.NEAREST) if k>1 else im
 if native.size!=CANVAS:raise ValueError(f'{im.size} com escala inteira {k} resulta em {native.size}; exigido {CANVAS}. Não redimensionamos arte.')
 errors=final_image_errors(native)
 if errors:raise ValueError('; '.join(errors))
 return native
def stage(index,drawing,root=ROOT,force=False):
 root=Path(root);doc=load_manifest(root);entry=doc['portraits'][index];drawing=Path(drawing)
 native=to_native(read(drawing))
 source=root/'assets/portraits/source'/f'{index}_{entry["npc"].lower()}{drawing.suffix.lower()}'
 out=root/'assets/portraits/generated'/f'{index}.png'
 if out.exists() and not force:raise FileExistsError(f'{out} já existe; use --force para substituir a versão em revisão')
 if drawing.resolve()!=source.resolve():
  if source.exists() and not force:raise FileExistsError(f'{source} já existe')
  shutil.copy2(drawing,source)
 native.save(out,optimize=False)
 if entry['status']!='approved':entry['status']='in_review';entry['approved']=out.relative_to(root).as_posix();entry['review']=None
 save_manifest(doc,root);return out
def promote(index,by,notes,root=ROOT,date=None):
 root=Path(root);doc=load_manifest(root);entry=doc['portraits'][index]
 generated=root/'assets/portraits/generated'/f'{index}.png'
 if not generated.exists():raise FileNotFoundError(f'{generated}: execute stage primeiro')
 errors=final_image_errors(read(generated))
 if errors:raise ValueError('; '.join(errors))
 if not by.strip() or not notes.strip():raise ValueError('aprovação exige revisor e notas da revisão visual')
 approved=root/'assets/portraits/approved'/f'{index}.png';shutil.copy2(generated,approved)
 entry.update(status='approved',approved=approved.relative_to(root).as_posix(),review={'by':by,'date':date or datetime.date.today().isoformat(),'notes':notes})
 save_manifest(doc,root);return approved
def main():
 p=argparse.ArgumentParser();sub=p.add_subparsers(dest='cmd',required=True)
 s=sub.add_parser('stage');s.add_argument('id',type=int);s.add_argument('drawing');s.add_argument('--force',action='store_true')
 a=sub.add_parser('promote');a.add_argument('id',type=int);a.add_argument('--by',required=True);a.add_argument('--notes',required=True)
 args=p.parse_args()
 try:out=stage(args.id,args.drawing,force=args.force) if args.cmd=='stage' else promote(args.id,args.by,args.notes)
 except (ValueError,FileExistsError,FileNotFoundError) as exc:raise SystemExit('REJEITADO: '+str(exc))
 print('OK',out.relative_to(ROOT).as_posix())
if __name__=='__main__':main()
