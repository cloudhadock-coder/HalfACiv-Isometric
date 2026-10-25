# Auditoria dos retratos — v0.2.2

Data: 2026-10-25. Padrão aplicado: [PORTRAIT_ART_STYLE_GUIDE.md](PORTRAIT_ART_STYLE_GUIDE.md). Evidências: [galeria](portrait-validation/portrait-gallery.png), capturas da UI ([painel](portrait-validation/ui-detail-panel.png), [galeria de habitantes](portrait-validation/ui-roster.png), [1080p](portrait-validation/ui-detail-panel-1080p.png)) e a comparação local com as referências (`docs/portrait-validation/local/reference-comparison.png`, fora do Git por licença).

## Resultado

| Classificação | Quantidade |
|---|---|
| Compatível | 0 |
| Compatível com ajustes | 0 |
| Incompatível | 0 (todos entram em Placeholder, abaixo) |
| **Placeholder** | **24** |

Os 24 retratos existentes foram gerados por código em `tools/asset_pipeline/village_art.py` (função `portrait`) e já apareciam no jogo como "Retrato em desenvolvimento". Diante das referências, são **incompatíveis** com o padrão. Foram classificados como **Placeholder** porque nunca foram arte final, e não por um defeito pontual que um ajuste resolveria. Nenhum deles chega a "Compatível com ajustes": corrigir paleta ou contorno não resolve o problema central, que é a ausência de rostos individualizados e de modelagem por clusters.

## Critérios verificados (comuns aos 24)

| # | Critério | Medido | Padrão | Situação |
|---|---|---|---|---|
| 1 | Resolução | 96×112 | 64×64 | ✗ |
| 2 | Enquadramento | rosto de ~30×40 px dentro de moldura e fundo embutidos, insígnia de ofício no canto | busto preenchendo 64×64, fundo transparente, sem moldura | ✗ |
| 3 | Proporções | cabeça e ombros plausíveis, pescoço longo e retangular | humanas estilizadas | parcial |
| 4 | Paleta | 27–32 cores, mas metade é moldura e fundo; rampas obtidas multiplicando o valor (`shade(c,0.72/1.13)`), sem deslocamento de matiz | ~40 cores, rampas com deslocamento de matiz | ✗ |
| 5 | Iluminação | luz superior esquerda presente, mas em 2 polígonos chapados por rosto | blocos esculpidos, sombras projetadas | ✗ |
| 6 | Contornos | contorno `#312a2a` uniforme ao redor do rosto; cabelo e roupas sem contorno seletivo | seletivo, lado da sombra | ✗ |
| 7 | Detalhamento | cabelo em retângulos e polígonos; barba em um polígono; orelhas retangulares que parecem fones | massas e mechas, materiais distintos | ✗ |
| 8 | Qualidade do rosto | **mesmo rosto nos 24**: olhos, sobrancelhas, nariz e boca em coordenadas fixas no código; só muda a cor | rostos únicos | ✗ |
| 9 | Consistência artística | consistentes entre si, mas em um estilo diferente das referências | estilo das referências | ✗ |
| 10 | Compatibilidade com a interface | exibição 1:1 pixel-exata (verificada em 720p e 1080p); a moldura embutida duplica a moldura da UI | sem moldura embutida | parcial |

Integridade técnica: todos têm alfa opaco, nenhum foi ampliado (escala de bloco 1), não há duplicatas e todos os NPCs têm arquivo. Nenhuma correção técnica é necessária para servirem de fallback.

## Retratos individuais

Identidade conforme `assets/portraits/portraits.json` (derivada do gerador v0.2 e das camadas do personagem no mapa). A identidade é o **contrato** para o redesenho: sexo, pele, cabelo, roupa e acessório devem ser preservados.

| ID | NPC | Papel | Identidade a preservar | Classificação | Observações específicas |
|---|---|---|---|---|---|
| 0 | Aldric | Camponês | masculino, pele `#d6a47b`, cabelo `#382d26` curto com barba, Shirt, nenhum | **Placeholder** | barba em polígono único, sem mechas |
| 1 | Elena | Camponesa | feminino, pele `#b97a56`, cabelo `#856340` longo, Corset, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 2 | Borin | Lenhador | masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, Green Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 3 | Darin | Minerador | masculino, pele `#87563e`, cabelo `#29252b` curto com barba, Blue Shirt v2, nenhum | **Placeholder** | barba em polígono único; pele escura sem rampa própria (mesma multiplicação de valor) |
| 4 | Edwin | Construtor | masculino, pele `#c08c66`, cabelo `#9c5436` curto, orange Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 5 | Farid | Mercador | masculino, pele `#d6a47b`, cabelo `#382d26` curto, Purple Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 6 | Gareth | Guarda | masculino, pele `#b97a56`, cabelo `#856340` curto com barba, Shirt v2, elmo/capacete de ferro | **Placeholder** | elmo lê como gorro de lã: sem reflexo metálico |
| 7 | Hector | Cavaleiro | masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, Blue Shirt v2, elmo/capacete de ferro | **Placeholder** | elmo sem reflexo; cabelo não aparece sob o elmo |
| 8 | Ivar | Arqueiro | masculino, pele `#87563e`, cabelo `#29252b` curto, Green Shirt v2, elmo/capacete de ferro | **Placeholder** | elmo sem reflexo; arqueiro sem traço de ofício além da insígnia |
| 9 | Jonas | Governante | masculino, pele `#c08c66`, cabelo `#9c5436` curto com barba, Purple Shirt v2, coroa de ouro com gema vermelha | **Placeholder** | coroa é o elemento mais legível do conjunto, mas sem rampa de ouro nem gema facetada; barba em polígono |
| 10 | Klara | Nobre | feminino, pele `#d6a47b`, cabelo `#382d26` longo, Blue Corset v2, nenhum | **Placeholder** | nobre sem joia nem traje distinto de camponesa |
| 11 | Lucian | Sacerdote | masculino, pele `#b97a56`, cabelo `#856340` curto, Shirt, tonsura clerical | **Placeholder** | "tonsura" é um retângulo de pele na testa, lê como erro |
| 12 | Mara | Agricultora | feminino, pele `#f0c69b`, cabelo `#c9ae72` longo, Green Corset v2, chapéu de palha | **Placeholder** | chapéu de palha chapado, sem trama |
| 13 | Oswin | Pescador | masculino, pele `#87563e`, cabelo `#29252b` curto, Blue Shirt v2, chapéu de palha | **Placeholder** | chapéu de palha chapado |
| 14 | Odo | Moleiro | masculino, pele `#c08c66`, cabelo `#9c5436` curto, Shirt, touca branca de ofício | **Placeholder** | touca branca lê como massa amorfa |
| 15 | Beatriz | Padeira | feminino, pele `#d6a47b`, cabelo `#382d26` longo, Corset v2, touca branca de ofício | **Placeholder** | touca branca amorfa |
| 16 | Ulric | Ferreiro | masculino, pele `#b97a56`, cabelo `#856340` curto, orange Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 17 | Tomas | Carpinteiro | masculino, pele `#f0c69b`, cabelo `#c9ae72` curto com barba, Green Shirt v2, nenhum | **Placeholder** | barba loura quase some contra a pele |
| 18 | Ysabel | Herbalista | feminino, pele `#87563e`, cabelo `#29252b` longo, Green Corset, guirlanda de folhas | **Placeholder** | guirlanda legível; cabelo longo em faixa lateral única |
| 19 | Bruno | Cervejeiro | masculino, pele `#c08c66`, cabelo `#9c5436` curto, Purple Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 20 | Rosa | Pastora | feminino, pele `#d6a47b`, cabelo `#382d26` longo, Orange Corset, chapéu de palha | **Placeholder** | sem defeito adicional além dos comuns |
| 21 | Agnes | Estalajadeira | feminino, pele `#b97a56`, cabelo `#856340` longo, Blue Corset, touca branca de ofício | **Placeholder** | touca amorfa |
| 22 | Nuno | Carregador | masculino, pele `#f0c69b`, cabelo `#c9ae72` curto, Shirt v2, nenhum | **Placeholder** | sem defeito adicional além dos comuns |
| 23 | Cedric | Vigia | masculino, pele `#87563e`, cabelo `#29252b` curto, Blue Shirt v2, elmo/capacete de ferro | **Placeholder** | elmo sem reflexo |

## Decisão: correção e recriação

**Nenhum retrato foi recriado nesta versão.** O briefing proíbe "produzir retratos ruins apenas para preencher a quantidade". A arte das referências é feita à mão, pixel a pixel, por um artista experiente: ~40 cores com rampas de matiz deslocado, clusters esculpidos e mechas desenhadas uma a uma. Esse nível não se alcança com desenho procedural, filtros ou conversão automática (todos proibidos pelo guia), e não houve neste ciclo um processo de criação artística capaz de entregar 24 rostos equivalentes com segurança. Em vez disso:

- os 24 retratos v0.2 foram **preservados sem alteração** como fallback (`status: legacy_placeholder`);
- a interface continua exibindo "Retrato em desenvolvimento" para cada NPC pendente, e a nota some automaticamente quando a arte é promovida;
- o pipeline (`tools/portrait_pipeline`) está pronto para receber a arte: o stage reduz exports em escala inteira sem perda e rejeita o que viola o padrão; a promoção exige revisão humana registrada.

## Trabalho artístico pendente

Para cada um dos 24 NPCs, um retrato 64×64 desenhado à mão segundo o guia. Pela ordem de prioridade de exposição na UI:

1. **#9 Jonas, Governante**: aparece no resumo da aldeia; usar o rei coroado como estudo.
2. **#6, #7, #8, #23** (Guarda, Cavaleiro, Arqueiro, Vigia): elmos com reflexos metálicos e malha.
3. **#10 Klara, Nobre** e **#11 Lucian, Sacerdote**: traje distinto (joia; vestes e tonsura legível).
4. **#14, #15, #21** (Moleiro, Padeira, Estalajadeira): touca de ofício com dobras de tecido.
5. **#12, #13, #20** (chapéus de palha) e **#18** (guirlanda).
6. Demais camponeses e artesãos (#0–#5, #16, #17, #19, #22): variar idade, mandíbula, nariz e barba para que não se repitam.

Estimativa aproximada (não medida): um artista de pixel art leva de 2 a 4 horas por busto 64×64 nesse nível, ou seja, de 50 a 100 horas para o elenco, mais revisão.

## Rascunhos PixelLab (2026-10-25)

Gerados no PixelLab só com prompts de texto. As referências oficiais **não** foram enviadas. O trial (40 gerações) foi gasto todo: 10 no Jonas, 1 num teste descartado do modelo barato (perfil, ruído, roupa moderna) e 29 no kit de partes.

| Item | Situação | Pendência |
|---|---|---|
| #9 Jonas | rascunho em `generated/9.png` (`in_review`), original em `source/9_jonas.png`; o jogo continua com o fallback | limpeza da seção 13 (o rascunho tem 45 cores; meta de 30 a 44), revisão e `export.py promote 9 … --ai-tool PixelLab`. Os 15 candidatos alternativos não foram guardados no repositório (job PixelLab `69b2ef2e`) |
| Demais 23 NPCs | `legacy_placeholder` | gerar com o modelo Pro (10 gerações por NPC, 16 candidatos), limpar e promover |
| Kit: 16 cabeças masculinas | `in_review` | revisão e limpeza; conferir os materiais de cada cabeça no `kit.json` |
| Kit: `hair_short`, `beard_full` | `in_review`, conferidos visualmente em todas as cabeças (`fits: *`) | revisão e limpeza |
| Kit: `clothing_jerkin` | `in_review`, encaixa em 6 cabeças | estender a camada para cobrir a túnica das outras 10 (vazamento de 10 a 65 px) |
| Kit: cabeça feminina, cabelos longos, chapéus, outras roupas | **não gerados**: trial esgotado (a máscara da cabeça feminina está em `kit/source/`) | gerar com inpaint sobre `head_09` (5 gerações cada) |
| Kit: preset de cabelo branco `#d9d4cc` | puxa para o rosa e o laranja nas mechas | ajustar a rampa ou trocar o preset |

Galeria do kit: [kit-preview.png](portrait-validation/kit-preview.png).

## Reavaliação

Ao promover qualquer retrato, atualize as tabelas acima, regenere a galeria (`generate_atlas.py`) e registre o revisor no manifesto.
