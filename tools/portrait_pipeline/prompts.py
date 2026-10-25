"""Write docs/PORTRAIT_PROMPTS.md: one AI-draft prompt per NPC, built from the manifest identity.

python tools/portrait_pipeline/prompts.py
Prompts only describe the style in words; they never embed or upload the official references.
"""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import ROOT,load_manifest
SKIN={'#d6a47b':'light tan','#b97a56':'warm medium brown','#f0c69b':'fair peach','#87563e':'deep brown','#c08c66':'warm olive-tan'}
HAIR={'#382d26':'dark brown','#856340':'chestnut brown','#c9ae72':'straw blond','#29252b':'black','#9c5436':'auburn red'}
CLOTH={'#668454':'muted moss green','#976056':'dusty rose-brown','#536e97':'muted slate blue','#b4995d':'ochre','#b18753':'burnt ochre','#67577e':'muted plum purple','#467c78':'muted teal'}
ROLE={'Camponês':'peasant','Camponesa':'peasant woman','Lenhador':'woodcutter','Minerador':'miner','Construtor':'builder','Mercador':'merchant','Guarda':'town guard','Cavaleiro':'knight','Arqueiro':'archer','Governante':'ruler','Nobre':'noblewoman','Sacerdote':'priest','Agricultora':'farmer','Pescador':'fisherman','Moleiro':'miller','Padeira':'baker','Ferreiro':'blacksmith','Carpinteiro':'carpenter','Herbalista':'herbalist','Cervejeiro':'brewer','Pastora':'shepherdess','Estalajadeira':'innkeeper','Carregador':'porter','Vigia':'watchman'}
# Exposure order in the UI (see docs/PORTRAIT_AUDIT.md): ruler first, then helmets, nobility, caps, hats.
PRIORITY=[9,6,7,8,23,10,11,14,15,21,12,13,20,18,0,1,2,3,4,5,16,17,19,22]
STYLE=('pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, '
 'shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps '
 '(warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses '
 'with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background')
NEGATIVE=('blurry, anti-aliasing, soft gradient, photo, photorealistic, 3d render, painterly, anime, chibi, cartoon, vector outline, uniform black outline, '
 'random noise, texture dithering, frame, border, background scenery, text, watermark, cropped head, cropped hat, tool in hand, weapon in hand')
def garment(entry):
 color=CLOTH[entry['clothing_color']]
 return f'{color} laced bodice over a linen blouse' if 'Corset' in entry['clothing'] else f'{color} linen tunic'
def prompt(e):
 hair='long' if e['sex']=='feminino' else 'short'
 return f"{STYLE}, {ROLE[e['role']]}, {e['prompt_brief']}, {SKIN[e['skin']]} skin, {HAIR[e['hair']]} {hair} hair, wearing a {garment(e)}"
def render(doc):
 entries={e['id']:e for e in doc['portraits']}
 order=[i for i in PRIORITY if i in entries]+[i for i in entries if i not in PRIORITY]
 out=['# Prompts de rascunho por IA — retratos dos NPCs','',
  'Gerado por `python tools/portrait_pipeline/prompts.py` a partir de `assets/portraits/portraits.json`. Não edite à mão: ajuste `prompt_brief` no manifesto e gere de novo.','',
  'Os prompts produzem **rascunhos**. Um retrato só entra no jogo depois da limpeza manual e da revisão descritas em [PORTRAIT_ART_STYLE_GUIDE.md](PORTRAIT_ART_STYLE_GUIDE.md#13-rascunhos-gerados-por-ia).','',
  '## Como usar no PixelLab','',
  '1. Gere em **64×64**, fundo transparente. Se a ferramenta oferecer, escolha contorno seletivo (*selective outline*), sombreamento detalhado e detalhe alto. Não gere em resolução maior para reduzir depois.',
  '2. **Comece pelo #9 Jonas.** Gere de 4 a 8 variações, escolha a melhor, limpe no Aseprite e aprove. Use esse retrato aprovado como referência de estilo/imagem inicial para os outros 23, para que o elenco pareça do mesmo artista.',
  '3. **Nunca envie as folhas de referência oficiais** (`assets/art_reference/portraits/`) para a ferramenta: a licença proíbe uso para IA. O estilo é transmitido pelo texto abaixo e pelos retratos já aprovados.',
  '4. Cole o prompt do NPC e o negativo comum. Se a ferramenta limitar o tamanho do texto, mantenha a parte específica do NPC e encurte o bloco de estilo.',
  '5. Exporte o PNG em 1× (ou escala inteira) e siga: limpeza → `export.py stage <id>` → `generate_atlas.py` → revisão com o checklist → `export.py promote <id> --by NOME --notes "…" --ai-tool "PixelLab"`.','',
  'Sobre o *Character Creator* do PixelLab: até onde sei, ele foi pensado para sprites de corpo inteiro com direções. Se não oferecer enquadramento de busto, use a geração de imagem comum em 64×64 com estes prompts. Confira na ferramenta.','',
  '## Negativo comum','','```text',NEGATIVE,'```','',
  '## Por NPC (em ordem de prioridade)','',
  'As cores entre crases são a identidade do manifesto. Na limpeza, corrija a paleta para ficar próxima delas (a rampa pode variar, a cor-base não).','']
 for n,i in enumerate(order,1):
  e=entries[i]
  out+=[f"### {n}. #{e['id']} {e['npc']} — {e['role']}",'',
   f"Identidade: {e['sex']}, pele `{e['skin']}`, cabelo `{e['hair']}` {e['hair_style']}, roupa `{e['clothing_color']}` ({e['clothing']}), acessório: {e['accessory']}. Sem ferramenta na mão (o ofício pode mudar no jogo).",'',
   '```text',prompt(e),'```','']
 return '\n'.join(out)
def build(root=ROOT):
 path=Path(root)/'docs/PORTRAIT_PROMPTS.md';path.write_text(render(load_manifest(root)),encoding='utf-8',newline='\n');return path
if __name__=='__main__':print('PORTRAIT_PROMPTS_OK',build().relative_to(ROOT).as_posix())
