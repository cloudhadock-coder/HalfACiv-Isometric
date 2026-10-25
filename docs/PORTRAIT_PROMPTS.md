# Prompts de rascunho por IA — retratos dos NPCs

Gerado por `python tools/portrait_pipeline/prompts.py` a partir de `assets/portraits/portraits.json`. Não edite à mão: ajuste `prompt_brief` no manifesto e gere de novo.

Os prompts produzem **rascunhos**. Um retrato só entra no jogo depois da limpeza manual e da revisão descritas em [PORTRAIT_ART_STYLE_GUIDE.md](PORTRAIT_ART_STYLE_GUIDE.md#13-rascunhos-gerados-por-ia).

## Como usar no PixelLab

1. Gere em **64×64**, fundo transparente. Se a ferramenta oferecer, escolha contorno seletivo (*selective outline*), sombreamento detalhado e detalhe alto. Não gere em resolução maior para reduzir depois.
2. **Comece pelo #9 Jonas.** Gere de 4 a 8 variações, escolha a melhor, limpe no Aseprite e aprove. Use esse retrato aprovado como referência de estilo/imagem inicial para os outros 23, para que o elenco pareça do mesmo artista.
3. **Nunca envie as folhas de referência oficiais** (`assets/art_reference/portraits/`) para a ferramenta: a licença proíbe uso para IA. O estilo é transmitido pelo texto abaixo e pelos retratos já aprovados.
4. Cole o prompt do NPC e o negativo comum. Se a ferramenta limitar o tamanho do texto, mantenha a parte específica do NPC e encurte o bloco de estilo.
5. Exporte o PNG em 1× (ou escala inteira) e siga: limpeza → `export.py stage <id>` → `generate_atlas.py` → revisão com o checklist → `export.py promote <id> --by NOME --notes "…" --ai-tool "PixelLab"`.

Sobre o *Character Creator* do PixelLab: até onde sei, ele foi pensado para sprites de corpo inteiro com direções. Se não oferecer enquadramento de busto, use a geração de imagem comum em 64×64 com estes prompts. Confira na ferramenta.

## Negativo comum

```text
blurry, anti-aliasing, soft gradient, photo, photorealistic, 3d render, painterly, anime, chibi, cartoon, vector outline, uniform black outline, random noise, texture dithering, frame, border, background scenery, text, watermark, cropped head, cropped hat, tool in hand, weapon in hand
```

## Por NPC (em ordem de prioridade)

As cores entre crases são a identidade do manifesto. Na limpeza, corrija a paleta para ficar próxima delas (a rampa pode variar, a cor-base não).

### 1. #9 Jonas — Governante

Identidade: masculino, pele `#c08c66`, cabelo `#9c5436` curto com barba, roupa `#67577e` (Purple Shirt v2), acessório: coroa de ouro com gema vermelha. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, ruler, man in his early 50s, short hair greying at the temples, full beard with a few grey strands, heavy brows, regal composed expression, gold crown with a faceted red gem, robe with simple gold trim, warm olive-tan skin, auburn red short hair, wearing a muted plum purple linen tunic
```

### 2. #6 Gareth — Guarda

Identidade: masculino, pele `#b97a56`, cabelo `#856340` curto com barba, roupa `#668454` (Shirt v2), acessório: elmo/capacete de ferro. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, town guard, man in his mid 40s, simple iron skull-cap helmet with crisp metal highlights, short beard, old scar through one eyebrow, stern disciplined expression, warm medium brown skin, chestnut brown short hair, wearing a muted moss green linen tunic
```

### 3. #7 Hector — Cavaleiro

Identidade: masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, roupa `#536e97` (Blue Shirt v2), acessório: elmo/capacete de ferro. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, knight, man in his early 30s, open-faced iron helmet with nasal guard and crisp metal highlights, clean-shaven, strong cleft chin, proud calm gaze, fair peach skin, straw blond short hair, wearing a muted slate blue linen tunic
```

### 4. #8 Ivar — Arqueiro

Identidade: masculino, pele `#87563e`, cabelo `#29252b` curto, roupa `#668454` (Green Shirt v2), acessório: elmo/capacete de ferro. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, archer, young man in his mid 20s, simple iron cap helmet with crisp metal highlights, lean face, clean-shaven, sharp alert eyes looking off-frame, deep brown skin, black short hair, wearing a muted moss green linen tunic
```

### 5. #23 Cedric — Vigia

Identidade: masculino, pele `#87563e`, cabelo `#29252b` curto, roupa `#536e97` (Blue Shirt v2), acessório: elmo/capacete de ferro. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, watchman, man in his mid 50s, gaunt cheeks, heavy-lidded watchful eyes, grey stubble, simple iron cap helmet with crisp metal highlights, deep brown skin, black short hair, wearing a muted slate blue linen tunic
```

### 6. #10 Klara — Nobre

Identidade: feminino, pele `#d6a47b`, cabelo `#382d26` longo, roupa `#536e97` (Blue Corset v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, noblewoman, woman in her mid 30s, elegant long face, finely arched eyebrows, small silver necklace, long hair braided and pinned up, poised reserved expression, light tan skin, dark brown long hair, wearing a muted slate blue laced bodice over a linen blouse
```

### 7. #11 Lucian — Sacerdote

Identidade: masculino, pele `#b97a56`, cabelo `#856340` curto, roupa `#467c78` (Shirt), acessório: tonsura clerical. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, priest, man in his early 60s, monastic tonsure (shaved crown with a ring of hair), deep wrinkles, kind tired eyes, clean-shaven, clerical robe with hood folded on the shoulders, warm medium brown skin, chestnut brown short hair, wearing a muted teal linen tunic
```

### 8. #14 Odo — Moleiro

Identidade: masculino, pele `#c08c66`, cabelo `#9c5436` curto, roupa `#536e97` (Shirt), acessório: touca branca de ofício. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, miller, man in his early 30s, round full face, light flour dust on the cheeks, white linen cap, clean-shaven, good-humoured grin, warm olive-tan skin, auburn red short hair, wearing a muted slate blue linen tunic
```

### 9. #15 Beatriz — Padeira

Identidade: feminino, pele `#d6a47b`, cabelo `#382d26` longo, roupa `#b4995d` (Corset v2), acessório: touca branca de ofício. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, baker, woman in her mid 40s, full cheeks, smile lines, white linen cap with hair tucked in and a few loose strands, warm motherly expression, light tan skin, dark brown long hair, wearing a ochre laced bodice over a linen blouse
```

### 10. #21 Agnes — Estalajadeira

Identidade: feminino, pele `#b97a56`, cabelo `#856340` longo, roupa `#536e97` (Blue Corset), acessório: touca branca de ofício. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, innkeeper, woman in her early 50s, strong jaw, laugh lines, white linen cap, confident hospitable look, warm medium brown skin, chestnut brown long hair, wearing a muted slate blue laced bodice over a linen blouse
```

### 11. #12 Mara — Agricultora

Identidade: feminino, pele `#f0c69b`, cabelo `#c9ae72` longo, roupa `#668454` (Green Corset v2), acessório: chapéu de palha. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, farmer, woman in her early 20s, round face, sun-warmed cheeks, wide woven straw hat, long braid over one shoulder, cheerful open smile, fair peach skin, straw blond long hair, wearing a muted moss green laced bodice over a linen blouse
```

### 12. #13 Oswin — Pescador

Identidade: masculino, pele `#87563e`, cabelo `#29252b` curto, roupa `#536e97` (Blue Shirt v2), acessório: chapéu de palha. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, fisherman, man in his mid 40s, weathered skin, squinting eyes, wide woven straw hat, clean-shaven, laconic expression, deep brown skin, black short hair, wearing a muted slate blue linen tunic
```

### 13. #20 Rosa — Pastora

Identidade: feminino, pele `#d6a47b`, cabelo `#382d26` longo, roupa `#b18753` (Orange Corset), acessório: chapéu de palha. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, shepherdess, young woman around 20, weather-tanned face, wide woven straw hat, long hair loose in the wind, shy half smile, light tan skin, dark brown long hair, wearing a burnt ochre laced bodice over a linen blouse
```

### 14. #18 Ysabel — Herbalista

Identidade: feminino, pele `#87563e`, cabelo `#29252b` longo, roupa `#668454` (Green Corset), acessório: guirlanda de folhas. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, herbalist, woman in her early 30s, high cheekbones, serene knowing expression, long hair, wreath of green leaves with small pale flowers, deep brown skin, black long hair, wearing a muted moss green laced bodice over a linen blouse
```

### 15. #0 Aldric — Camponês

Identidade: masculino, pele `#d6a47b`, cabelo `#382d26` curto com barba, roupa `#668454` (Shirt), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, peasant, man in his early 40s, broad weathered face, wide flat nose, deep-set tired eyes, full short beard, sun creases on forehead, calm patient expression, light tan skin, dark brown short hair, wearing a muted moss green linen tunic
```

### 16. #1 Elena — Camponesa

Identidade: feminino, pele `#b97a56`, cabelo `#856340` longo, roupa `#976056` (Corset), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, peasant woman, woman in her late 20s, soft oval face, strong dark eyebrows, small straight nose, faint warm smile, long hair loosely tied with strands framing the face, warm medium brown skin, chestnut brown long hair, wearing a dusty rose-brown laced bodice over a linen blouse
```

### 17. #2 Borin — Lenhador

Identidade: masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, roupa `#668454` (Green Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, woodcutter, young man in his early 20s, square jaw, a few freckles on the cheeks, short tousled hair, clean-shaven, determined look, fair peach skin, straw blond short hair, wearing a muted moss green linen tunic
```

### 18. #3 Darin — Minerador

Identidade: masculino, pele `#87563e`, cabelo `#29252b` curto com barba, roupa `#536e97` (Blue Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, miner, man in his mid 30s, heavy brow ridge, broad nose, short dense beard, smudge of soot on one cheek, serious steady stare, deep brown skin, black short hair, wearing a muted slate blue linen tunic
```

### 19. #4 Edwin — Construtor

Identidade: masculino, pele `#c08c66`, cabelo `#9c5436` curto, roupa `#b18753` (orange Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, builder, man in his mid 50s, receding hairline, lined forehead, slightly crooked nose, clean-shaven with stubble shadow, friendly squint, warm olive-tan skin, auburn red short hair, wearing a burnt ochre linen tunic
```

### 20. #5 Farid — Mercador

Identidade: masculino, pele `#d6a47b`, cabelo `#382d26` curto, roupa `#67577e` (Purple Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, merchant, man in his early 30s, narrow face, high cheekbones, sharp hooked nose, shrewd attentive eyes, neatly combed short hair, clean-shaven, slight knowing smile, light tan skin, dark brown short hair, wearing a muted plum purple linen tunic
```

### 21. #16 Ulric — Ferreiro

Identidade: masculino, pele `#b97a56`, cabelo `#856340` curto, roupa `#b18753` (orange Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, blacksmith, man in his early 40s, heavy jaw, thick neck, small burn mark on one cheek, short cropped hair, clean-shaven, intense focused gaze, leather apron strap on the shoulder, warm medium brown skin, chestnut brown short hair, wearing a burnt ochre linen tunic
```

### 22. #17 Tomas — Carpinteiro

Identidade: masculino, pele `#f0c69b`, cabelo `#c9ae72` curto com barba, roupa `#668454` (Green Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, carpenter, man in his mid 30s, long face, light blond beard shaded darker than the skin so it stays readable, thoughtful downward glance, fair peach skin, straw blond short hair, wearing a muted moss green linen tunic
```

### 23. #19 Bruno — Cervejeiro

Identidade: masculino, pele `#c08c66`, cabelo `#9c5436` curto, roupa `#67577e` (Purple Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, brewer, man in his mid 40s, ruddy round cheeks, bulbous nose, broad grin, clean-shaven, warm olive-tan skin, auburn red short hair, wearing a muted plum purple linen tunic
```

### 24. #22 Nuno — Carregador

Identidade: masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, roupa `#67577e` (Shirt v2), acessório: nenhum. Sem ferramenta na mão (o ofício pode mudar no jogo).

```text
pixel art bust portrait, 64x64 canvas, medieval fantasy, three-quarter view facing left, head and shoulders filling the frame, shoulders cut by the bottom edge, top of the head and headwear fully inside the canvas, single top-left key light, hue-shifted color ramps (warm highlights, red-violet shadows on skin), clustered shading, selective dark outline on the shadow side only, hair and beard as large masses with grouped strand highlights, crisp hand-placed pixels, about 40 colors, transparent background, porter, young man around 19, boyish face, wide-set eyes, sweat-matted short hair, clean-shaven, eager expression, fair peach skin, straw blond short hair, wearing a muted plum purple linen tunic
```
