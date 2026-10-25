# Guia de direção artística dos retratos

Referência permanente para todo retrato de NPC do HalfACiv Isometric, atual ou futuro. Vale para quem desenha, revisa ou integra retratos, inclusive agentes de programação (veja [AGENTS.md](../AGENTS.md)).

**Regra central:** os retratos devem parecer feitos pelo mesmo artista das duas folhas de referência oficiais. A diferença entre personagens vem do rosto, do cabelo, da idade, das roupas, dos acessórios, da expressão e da paleta individual. O estilo não muda de um personagem para outro.

## 1. Referências oficiais

| Arquivo | Origem | SHA-256 |
|---|---|---|
| `assets/art_reference/portraits/female_reference.png` | cópia de `assets/art_reference/bCRFr3.png` | `db9a8939…c5aabe` |
| `assets/art_reference/portraits/male_reference.png` | cópia de `assets/art_reference/DjxKtV.png` | `6ecb96e4…0ddb` |

Os hashes completos ficam em `tools/portrait_pipeline/common.py`. O `validate.py` acusa erro se uma referência presente for alterada.

As referências são **somente locais e ficam fora do Git**. Elas vêm do mesmo conjunto de arte de terceiros que o pacote GandalfHardcore, cuja licença proíbe redistribuir e usar para treinar IA (`assets/original/GandalfHardcore/READ ME.txt`). Quem clonar o repositório precisa ter cópias autorizadas e colocá-las nesses caminhos ([instruções](../assets/art_reference/portraits/README.md)). Nunca copie pixels das referências para um retrato do jogo nem as publique em docs, releases ou galerias versionadas. Elas definem **técnica**, não conteúdo para reaproveitar.

### O que a análise das referências mostrou

Os dados foram medidos nos arquivos com `tools/portrait_pipeline` e inspeção visual na escala nativa:

- **Resolução nativa: 64×64 por retrato.** As folhas são grades 4×3 ampliadas **3×** (a feminina tem 768×576 = 256×192 nativos; a masculina, 759×570 = 253×190, com a margem direita aparada). O menor segmento horizontal medido é de 3 px de tela, ou seja, 1 px nativo.
- **Cores:** cerca de 40 cores opacas por retrato (o rei coroado tem 40). Cada material tem sua própria rampa de 4 a 6 tons.
- **Fundo transparente**, com alfa binário na arte. O busto ocupa o quadro de lado a lado e os ombros são cortados pela borda inferior.
- **Vista três-quartos** na maioria, com olhar ligeiramente para fora do quadro. Há algumas vistas frontais (elmos, barril).
- **Luz principal superior e lateral**, sempre de cima. O lado sombreado do rosto é um bloco grande e contínuo. Sobrancelha, nariz, lábio inferior e barba projetam sombra.
- **Contorno escuro seletivo:** quase preto (#13131c, #2c221d) na silhueta externa do lado da sombra e nas separações de massa. Nas bordas iluminadas o contorno some ou vira um tom escuro da própria rampa. Não há linha preta uniforme ao redor de tudo.

## 2. Resolução lógica e enquadramento

**Decisão: 64×64 px**, não 96×96. É a resolução real das referências. Desenhar em 96 com a mesma densidade de detalhe exigiria inventar 50% de pixels a mais, o que muda o estilo (traços mais finos, menos massa por pixel). Na consistência, a densidade de pixels da referência pesa mais que o tamanho sugerido.

| Item | Regra |
|---|---|
| Tela | 64×64, RGBA, alfa somente 0 ou 255 |
| Fundo | transparente; a interface fornece fundo e moldura |
| Topo | linha y=0 inteira transparente: coroas, elmos, chapéus e cabelos nunca são cortados (regra mais rígida que a das referências) |
| Base | ombros e peito podem tocar a borda inferior |
| Rosto | da sobrancelha ao queixo, 22 a 28 px; olhos entre y≈24 e y≈32; eixo do rosto entre x≈26 e x≈38 |
| Silhueta | bounding box mínima de 40×44 px; busto de 44 a 64 px de largura |
| Orientação | três-quartos (preferida) ou frontal, com espaço livre do lado para onde o personagem olha |

A escala facial deve ser a mesma em todo o elenco. Um anão, uma criança ou um gigante mudam a proporção do corpo, nunca o tamanho do pixel.

## 3. Paleta e sombreamento

- Use **rampas por material**: pele com 5 a 6 tons (realce, luz, meio-tom, sombra, sombra profunda e um tom de oclusão avermelhado), cabelo com 4 a 5, tecido com 3 a 4, metal com 4 a 5 mais o especular.
- **Desloque o matiz nas rampas:** sombras de pele vão para o vermelho e o violeta (#b86565 → #8e5252 → #633131), realces vão para o amarelo claro (#fbe2c9). Não escureça apenas multiplicando o valor.
- **Sombras em blocos** (clusters) de pixels contíguos. Nada de pixels isolados espalhados, ruído aleatório ou dithering de textura. Dithering só em transições amplas de tecido, com padrão regular, e com moderação.
- **Orçamento de cores:** de 12 a 48 cores opacas por retrato (o validador impõe esse limite). O alvo é 30 a 44.
- Cada personagem tem uma paleta individual (pele, cabelo e roupa vêm do manifesto). A estrutura das rampas é sempre a mesma.

## 4. Iluminação

- Uma luz principal, de cima e de um lado. O padrão é **superior esquerda**, compatível com a luz do mapa ([ART_DIRECTION.md](ART_DIRECTION.md)). A direita só se usa quando a pose exige, e de forma consistente dentro de um mesmo grupo de personagens.
- Diferencie os materiais pela resposta à luz: pele com transição curta e quente; metal com contraste extremo e reflexos em formas recortadas; tecido com transição média, dobras e oclusão; cabelo com faixas de brilho seguindo o fluxo das mechas.
- Realce discreto: 1 a 3 pixels claros no nariz, nas maçãs do rosto e no lábio inferior. Brilho nos olhos de 1 px no máximo.
- O contraste precisa sobreviver a 1×. Teste o retrato na escala nativa sobre o fundo `#17252b` da interface.

## 5. Contornos

- Contorno externo escuro no lado da sombra e onde a silhueta encontra o fundo. Do lado da luz, use um tom escuro da rampa local ou nenhum contorno.
- As separações internas (queixo e pescoço, cabelo e testa, gola e pescoço) são feitas por mudança de tom e sombra projetada, não por linhas.
- Linhas de 1 px, sem "jaggies" (degraus irregulares) nem cantos duplicados. Curvas seguem progressões regulares (1-1-2-3…).
- Nenhum contorno vetorial uniforme e nenhuma linha de espessura variável por antialiasing.

## 6. Rostos e expressões

- Proporções humanas estilizadas, nunca chibi nem anime: olhos pequenos (2 a 3 px de altura, íris de 1 a 2 px), nariz construído por plano de luz e sombra, boca de 1 a 2 px com sombra no lábio inferior.
- Maçãs do rosto, mandíbula e queixo marcados por planos de sombra. A forma do queixo e da mandíbula muda de pessoa para pessoa.
- **Rostos individualizados:** mude a largura do rosto, o formato do nariz, a distância entre os olhos, a espessura das sobrancelhas, as rugas, as cicatrizes e a idade. Nunca reaproveite as mesmas coordenadas de olho, nariz e boca para vários personagens (é o defeito central dos retratos v0.2).
- Idade: jovens têm transições mais limpas; idosos ganham bolsas sob os olhos, sulcos nasolabiais e cabelo e barba grisalhos com rampa dessaturada.
- Expressões sutis: inclinação da sobrancelha, canto da boca e direção do olhar. Nada de caretas, exceto em personagens especiais.

## 7. Cabelos e barbas

- Construa o cabelo como **massas grandes** com 3 a 5 tons, com mechas indicadas por faixas de brilho curvas de 1 px agrupadas, acompanhando a direção do crescimento.
- As pontas terminam em cunhas e grupos, não em franjas de pixels soltos.
- A barba repete a mesma lógica: volume com sombra própria, separação de chumaços e brilho na parte de cima de cada massa.
- O cabelo projeta sombra na testa e no pescoço.

## 8. Armaduras, metais e tecidos

- Metal: rampa de 4 a 5 tons, do quase branco (#f5f5f5) ao azul-acinzentado escuro. Reflexos em **formas recortadas** que seguem o volume (faixa vertical no elmo, ponto no rebite). Cota de malha como padrão regular de anéis de 2×2 a 3×2 px em duas tonalidades.
- Ouro e coroas: rampa quente de amarelo-claro a marrom (#fbe2a0 → #b18f3e → #6e4818), com gemas de 2 a 3 tons e 1 px de brilho.
- Tecidos: dobras em diagonal, com sombra de oclusão nas golas e no interior de capuzes. Capuzes e capas emolduram o rosto com sombra profunda.
- Peles (arminho) e lã: borda irregular em grupos, nunca ruído.
- Vestes religiosas: superfícies amplas e claras, com ornamentos dourados simples.

## 9. Exemplos aprovados

Até esta versão, **nenhum retrato do jogo foi aprovado** no padrão; os 24 atuais são fallback (veja [PORTRAIT_AUDIT.md](PORTRAIT_AUDIT.md)). Os exemplos aprovados por enquanto são as próprias células das referências. Elas valem como modelo de técnica e devem ser consultadas na comparação local `docs/portrait-validation/local/reference-comparison.png`:

| Para desenhar | Estude a célula |
|---|---|
| Governante / nobre coroado | masculina, linha 2, coluna 4 (rei de barba, coroa e arminho); feminina, linha 1, coluna 1 (rainha coroada) |
| Camponeses e artesãos de barba | masculina, linha 1, coluna 3; masculina, linha 2, coluna 3 (anão ruivo, rampa de cabelo e barba) |
| Sacerdote | masculina, linha 2, coluna 1 (mitra, vestes claras, barba grisalha) |
| Guarda / cavaleiro / vigia | masculina, linha 1, coluna 2; linha 2, coluna 2; linha 3, coluna 3 (elmos, malha) |
| Herbalista / pastora / encapuzados | feminina, linha 2, colunas 1 e 4; masculina, linha 1, colunas 1 e 4 (capuzes) |
| Caçador / arqueiro | masculina, linha 3, coluna 1 (chapéu com pena) |
| Mulheres do povo | feminina, linha 1, coluna 3 (véu); linha 1, coluna 4 (cabelo longo) |

Use as células com nudez, vampiros, demônios, Papai Noel ou o barril apenas como estudo de técnica. O conteúdo dos personagens segue o elenco do jogo.

Quando o primeiro retrato for promovido, acrescente-o aqui com o nome do revisor.

## 10. Exemplos rejeitados

- **Retratos v0.2 (`assets/portraits/0.png` a `23.png`)**: o mesmo rosto geométrico em todos, sombras em polígonos chapados, cabelo em retângulos, orelhas retangulares que parecem fones, moldura e insígnia embutidas no PNG, 96×112 opaco. Ficam como fallback até serem substituídos.
- Fotos, renders 3D ou ilustrações reduzidas e quantizadas.
- Imagem de IA gerada em alta resolução e reduzida para 64×64, ou rascunho de IA promovido sem limpeza manual (veja a seção 13).
- Arte ampliada de forma bilinear ou fracionária, ou pixels de tamanhos diferentes no mesmo retrato.
- Ruído aleatório simulando textura; dithering sem regularidade.
- Filtros de pintura, blur, brilho difuso, gradientes suaves e antialiasing (alfa parcial).
- Contorno vetorial uniforme, olhos grandes de anime, proporções chibi.
- Retrato tecnicamente válido (64×64, poucas cores) que não segue as rampas, a luz e os clusters descritos aqui. Passar no validador **não** significa aprovação.

## 11. Regras de exportação

1. Desenhe em 64×64 (Aseprite ou similar), com grade de 1 px e paleta indexada se quiser. Um rascunho de IA pode ser o ponto de partida, desde que siga a seção 13.
2. Exporte em PNG RGBA, na escala 1× ou numa escala inteira (2×, 3×, …), sem fundo.
3. Faça o stage: `python tools/portrait_pipeline/export.py stage <id> desenho.png`. O original é copiado intacto para `assets/portraits/source/`. A versão nativa vai para `assets/portraits/generated/<id>.png` e o status passa a `in_review`. Escala não inteira, tamanho errado, alfa parcial ou excesso de cores são **rejeitados**, nunca redimensionados.
4. Faça a revisão visual: rode `python tools/portrait_pipeline/generate_atlas.py` e compare a galeria e a comparação local com as referências, usando o checklist abaixo.
5. Promova: `python tools/portrait_pipeline/export.py promote <id> --by "Nome" --notes "o que foi comparado"` (acrescente `--ai-tool "Ferramenta"` se o retrato partiu de um rascunho de IA). Só então o jogo passa a usar a arte e a nota "Retrato em desenvolvimento" some.
6. Rode `python tools/portrait_pipeline/validate.py`, os testes e reimporte no Godot (os PNGs em `approved/` ganham `.import`).

No jogo, `src/ui/portrait_view.gd` desenha o retrato com nearest-neighbor, na **maior escala inteira de pixels de tela** que cabe na área (compensando o stretch da janela), centralizado e alinhado ao grid da tela. Não existe escala fracionária nem recorte. O painel de detalhes tem 128×128 lógicos, ou seja, 2× para 64×64 em 1280×720 e 3× em 1920×1080.

## 12. Checklist de qualidade (revisão humana)

- [ ] Colocado lado a lado com as referências na mesma escala, parece do mesmo artista?
- [ ] O rosto é único: nariz, olhos, mandíbula e idade diferem dos outros NPCs?
- [ ] Identidade preservada: sexo, idade aparente, pele, cabelo, roupa e acessório do manifesto?
- [ ] Luz de cima, lado da sombra coerente, sombras em blocos, realces discretos?
- [ ] Rampas com deslocamento de matiz, entre 30 e 44 cores, sem ruído?
- [ ] Contorno seletivo, sem linha preta uniforme e sem jaggies?
- [ ] Cabelo e barba em massas e mechas agrupadas?
- [ ] Metal com reflexos recortados; tecido com dobras?
- [ ] Topo livre, busto centralizado, ombros na base, escala facial igual à do elenco?
- [ ] Legível a 1× sobre `#17252b` e a 2× no painel?
- [ ] `validate.py` sem erros e galeria regenerada?
- [ ] Se partiu de IA: a limpeza da seção 13 foi feita e a ferramenta foi registrada com `--ai-tool`?

## 13. Rascunhos gerados por IA

Ferramentas de pixel art com IA (por exemplo, PixelLab) podem gerar o **rascunho** de um retrato. O retrato final continua sendo responsabilidade de quem limpa e aprova, e precisa cumprir todo este guia. Prompts por NPC: [PORTRAIT_PROMPTS.md](PORTRAIT_PROMPTS.md), gerados do manifesto por `tools/portrait_pipeline/prompts.py`.

**Permitido**
- Gerar diretamente na grade nativa de 64×64, com fundo transparente.
- Usar como referência de estilo/imagem inicial **retratos do jogo já aprovados**, para manter o elenco consistente.
- Descrever o estilo em texto (prompts derivados deste guia).

**Proibido**
- Enviar, carregar ou treinar (LoRA, fine-tune, "style model") com as **referências oficiais** ou qualquer arquivo de `assets/original/`. A licença do pacote proíbe o uso para IA.
- Gerar em alta resolução e reduzir, converter ou quantizar para 64×64.
- Promover um rascunho sem a limpeza abaixo. Saída de IA intocada nunca é arte final.
- Usar uma ferramenta cujos termos não permitam uso comercial do resultado.

**Limpeza manual obrigatória (no Aseprite ou similar)**
1. Conferir a grade: nenhum pixel de tamanho diferente, nenhum alfa parcial; o validador rejeita os dois.
2. Refazer as rampas com deslocamento de matiz (seção 3) e unificar a paleta. Remover tons quase duplicados até ficar entre 30 e 44 cores.
3. Remover pixels órfãos e ruído; transformar sombras em blocos (clusters).
4. Corrigir o contorno para que seja seletivo (seção 5) e eliminar jaggies.
5. Conferir a anatomia: olhos simétricos na perspectiva, orelhas, mãos fora do quadro, acessórios inteiros e topo livre.
6. Conferir a identidade com o manifesto: sexo, idade, pele, cabelo, roupa e acessório. Corrigir as cores-base.
7. Comparar na galeria com os retratos já aprovados e com as referências locais. Ajustar a escala facial e a luz para ficarem iguais.

Registre a origem na promoção: `--ai-tool "PixelLab"` grava `review.ai_draft` no manifesto, e `--notes` descreve o que foi corrigido.

## 14. Kit de partes (gerador de personagens)

Exceção controlada à regra "não gerar rostos proceduralmente", aprovada pelo diretor do projeto em 2026-10-25. Os 24 NPCs nomeados continuam com retrato único (seções 1 a 13). Moradores gerados durante o jogo, como os imigrantes além dos 24 fundadores, recebem um retrato **montado em tempo real a partir de partes desenhadas e aprovadas uma a uma**.

**O que o kit é**
- Camadas 64×64 RGBA alinhadas no mesmo enquadramento: `head` (busto completo: rosto, pescoço e túnica crua), `clothing`, `beard`, `hair` e `hat`, desenhadas nessa ordem. Manifesto: `assets/portraits/kit/kit.json`. Arquivos: `assets/portraits/kit/parts/`.
- Cada parte é arte e passa por este guia inteiro: limpeza da seção 13, revisão humana e `kit.py promote`. O jogo só combina partes `approved`. Sem elas, o morador mostra o retrato de fallback.
- **Recoloração por rampas fixas:** pele (7 tons), cabelo (5) e tecido (4). As cores-alvo são as cores de identidade do manifesto de retratos (`presets`). Cada rampa é derivada da parte de origem (`ramp_source`) mantendo o deslocamento de matiz que o artista desenhou, e as tabelas ficam gravadas no `kit.json` por `kit.py bake`. O jogo só consulta tabelas: não inventa pixels, não filtra, não interpola. O tecido só é recolorido da linha 36 para baixo (`TUNIC_TOP`), para que os olhos nunca peguem a cor da roupa.
- `fits` diz em quais cabeças uma sobreposição foi conferida. Uma roupa que deixa a túnica vazar numa cabeça não é declarada para ela.

**Regras**
- Toda combinação possível de partes aprovadas precisa passar no mesmo portão técnico de um retrato final (64×64, alfa binário, topo livre, 12–48 cores). O `kit.py validate` compõe 64 receitas e falha se alguma não passar.
- Sobreposições nascem desenhadas sobre uma cabeça do kit (inpaint com máscara ou à mão). O `kit.py add --base` guarda só os pixels que mudaram, então a camada encaixa pixel a pixel.
- Cabeças entram só deslocadas por pixels inteiros (`--dx/--dy`) para o enquadramento comum. Nunca redimensione.
- Para mudar uma rampa ou um preset, edite o `kit.json` e rode `kit.py bake`. O validador acusa tabelas desatualizadas.
- Os compositores em Python (`kit.py compose`) e GDScript (`src/ui/portrait_kit.gd`) precisam produzir os mesmos bytes. Os testes fixam o hash de uma combinação.
