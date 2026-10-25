"""Validate the portrait manifest and every file it resolves to.

python tools/portrait_pipeline/validate.py [--require-final]
Exit 1 on errors. Placeholders are reported as pending, never as approved art.
"""
from pathlib import Path
import sys,hashlib
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import read,ROOT,REFERENCES,CANVAS,LEGACY,Image,load_manifest,resolved,digest,final_image_errors
REQUIRED=['id','npc','role','sex','apparent_age','skin','hair','hair_style','clothing','accessory','status','fallback','approved','review']
def validate(root=ROOT):
 root=Path(root);doc=load_manifest(root);errors=[];warnings=[];pending=[]
 entries=doc['portraits']
 if [e.get('id') for e in entries]!=list(range(len(entries))):errors.append('ids devem ser 0..N-1 em ordem (o jogo indexa portrait_id)')
 seen={};referenced=set()
 for e in entries:
  tag=f"#{e.get('id')} {e.get('npc','?')}"
  missing=[k for k in REQUIRED if k not in e]
  if missing:errors.append(f'{tag}: campos ausentes {missing}');continue
  if e['status'] not in doc['statuses']:errors.append(f"{tag}: status inválido {e['status']}");continue
  fallback=root/e['fallback'];referenced.add(fallback.resolve())
  if not fallback.exists():errors.append(f'{tag}: fallback ausente {e["fallback"]}')
  elif read(fallback).size!=LEGACY:errors.append(f'{tag}: fallback fora de {LEGACY}')
  if e['status']=='legacy_placeholder':
   pending.append(tag)
   if e['approved'] or e['review']:errors.append(f'{tag}: placeholder não pode declarar arte aprovada/revisão')
  else:
   if not e['approved']:errors.append(f'{tag}: status {e["status"]} sem arquivo');continue
   folder='assets/portraits/approved/' if e['status']=='approved' else 'assets/portraits/generated/'
   if not e['approved'].startswith(folder):errors.append(f'{tag}: arquivo {e["approved"]} deve estar em {folder}')
   art=root/e['approved'];referenced.add(art.resolve())
   if not art.exists():errors.append(f'{tag}: arquivo ausente {e["approved"]}');continue
   errors+=[f'{tag}: {msg}' for msg in final_image_errors(read(art))]
   if e['status']=='in_review':pending.append(tag+' (em revisão)')
   elif not (isinstance(e['review'],dict) and e['review'].get('by') and e['review'].get('date')):errors.append(f'{tag}: aprovação exige revisão visual registrada (by/date)')
  target=resolved(e,root)
  if target.exists():
   h=digest(read(target))
   # Two NPCs sharing final art is an error; a new NPC may borrow a fallback until drawn.
   if h in seen:(errors if e['status']=='approved' or seen[h][1]=='approved' else warnings).append(f'{tag}: imagem duplicada de {seen[h][0]}')
   seen[h]=(tag,e['status'])
 for folder in ['approved','generated']:
  for f in sorted((root/'assets/portraits'/folder).glob('*.png')):
   if f.resolve() not in referenced and not f.name.startswith('portrait_atlas'):warnings.append(f'arquivo órfão sem NPC: {f.relative_to(root).as_posix()}')
 for name,expected in REFERENCES.items():
  path=root/name
  if not path.exists():warnings.append(f'referência oficial ausente nesta cópia: {name} (arquivo local, fora do Git)')
  elif hashlib.sha256(path.read_bytes()).hexdigest()!=expected:errors.append(f'referência oficial alterada: {name}')
 return errors,warnings,pending
def main():
 errors,warnings,pending=validate()
 for w in warnings:print('AVISO',w)
 for e in errors:print('ERRO',e)
 print(f'PENDENTES {len(pending)}: '+', '.join(pending) if pending else 'PENDENTES 0')
 if '--require-final' in sys.argv and pending:errors.append('portraits pendentes')
 if errors:raise SystemExit(f'PORTRAITS_INVALID errors={len(errors)}')
 print(f'PORTRAITS_OK warnings={len(warnings)} pending={len(pending)}')
if __name__=='__main__':main()
