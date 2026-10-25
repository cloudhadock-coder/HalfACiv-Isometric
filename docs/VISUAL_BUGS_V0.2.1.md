# Correções visuais — v0.2.1

## Estado inicial e referência
Projeto existente `Repositorios/HalfACiv-Isometric`, branch main limpa no commit `2c043956b1dd1ad91e5684052cedbc4e0792a798` (v0.2.0), sem trabalho local pendente. Nenhum projeto novo foi criado. A gravação **Gravando 2026-10-24 224446.mp4** foi localizada e decodificada: 43,60 s, 1580×846, H.264, 30 FPS. Foram inspecionados quadros em intervalos de três segundos e assets ampliados por nearest-neighbor. O vídeo e seus frames de análise permanecem locais em `tools/visual-reference`, fora do Git.

As capturas `visual-validation/v0.2.1/before/` foram obtidas executando a v0.2.0 antes das alterações. As demais imagens foram obtidas pelo renderizador OpenGL real após as correções. A montagem Before_After apenas reúne capturas reais, com rótulos fora delas. A cena NPC_Depth_Test é um fixture controlado de renderização; não é apresentada como uma caminhada normal através de obstáculos.

## VB-01 — Câmera fora do losango
- **Descrição:** movimento permitia regiões predominantemente vazias e limites incoerentes conforme o zoom.
- **Evidência/reprodução:** gravação em aproximadamente 12–18 s e 33–42 s; before/Camera_North_Edge.png. Pan até um extremo e depois mudar o zoom.
- **Causa:** clamp fixo x=[-800,800], y=[80,950], independente do losango, viewport e HUD.
- **Arquivos:** `src/core/game.gd`, `src/rendering/camera_bounds.gd`, `camera_controller.gd`.
- **Correção:** região convexa calculada a partir da projeção real e do retângulo útil do mapa. A região estritamente inscrita é complementada por posições limitadas de inspeção dos vértices, para que os tiles dos cantos não fiquem inacessíveis. Projeção no segmento mais próximo dá movimento contínuo pela borda, sem overshoot. Mapas menores que a vista são centralizados. Limites são recalculados somente em zoom/layout.
- **Validação:** teste de milhares de posições e idempotência, acesso aos quatro tiles de canto e capturas North/South/East/West. Novas tentativas de pan na borda não ultrapassaram o domínio. Fora do tabuleiro permanece fundo deliberado; não há terreno fictício para escondê-lo.

## VB-02 — Zoom sem âncora e distante demais
- **Descrição:** zoom deslocava o ponto observado e admitia miniaturização excessiva; passos multiplicativos eram pouco previsíveis.
- **Evidência/reprodução:** gravação em 12–18 s e 24–39 s; girar a roda longe do centro.
- **Causa:** zoom era multiplicado por 1,12/0,89 sem compensar a origem da câmera, entre 0,65 e 3,5.
- **Arquivos:** `camera_controller.gd`, `game.gd`.
- **Correção:** passos 1×, 1,5×, 2×, 3× e 4×; padrão 2×. O mínimo respeita a área útil e a projeção. A posição sob o cursor é mantida quando os limites permitem; nas bordas prevalece a restrição geométrica. Input fracionário é acumulado, mas a translação final da câmera é alinhada ao pixel de tela.
- **Validação:** roundtrips concordam com o canvas real, erro de âncora inferior a 1,1 pixel, câmera parada sem deriva, capturas Zoom_In/Zoom_Out e Default.

## VB-03 — Borda recortada e fundo sem acabamento
- **Descrição:** o fim do terreno parecia um corte sem espessura sobre um vazio escuro.
- **Evidência/reprodução:** gravação em 12, 15, 36 e 42 s; aproximar um vértice do viewport.
- **Causa:** somente os 1024 tiles eram desenhados; não existia acabamento externo do mundo.
- **Arquivos:** `ground_layer.gd`, `table_backdrop.gd`.
- **Correção:** estética deliberada de tabuleiro, com faces externas de pedra uniformes de 12 unidades e fundo discreto de mesa/ardósia. A borda acompanha os mesmos quatro vértices da grade. Não foi preenchida a tela de verde nem ampliada a área jogável.
- **Validação:** capturas dos quatro extremos, inclusive água na borda sul/leste; não aparecem tiles independentes fora da grade.

## VB-04 — Origem do terreno oito pixels errada
- **Descrição:** estradas, chão, bases de construções, árvores e seleção não compartilhavam a mesma superfície.
- **Evidência/reprodução:** inspeção PNG ampliada e gravação em 21–27 s. Nos tiles fornecidos a superfície começa em y=24 e tem centro em y=40; o código subtraía y=48. Os terrenos gerados usavam outro diamante, centrado em 48.
- **Causa:** confusão entre a célula PNG de 64×64, sua superfície 64×32 e a extrusão inferior de oito pixels.
- **Arquivos:** `iso.gd`, `ground_layer.gd`, `world_view.gd`, `tools/asset_pipeline/visual_patch.py`.
- **Correção:** origem única `(32,40)`, tiles derivados alinhados à superfície e remoção da extrusão interna dos blocos. A extrusão só permanece no contorno externo do tabuleiro. Bases verdes foram harmonizadas com o terreno. Os arquivos originais e os produtos da v0.2.0 são preservados; o patch usa cópias em `assets/tilesets/visual_v021`.
- **Validação:** testes de conversão, seleção sobre grama/estrada e capturas Default/Closeup/Depth. Terreno, pés, bases e destaque compartilham a mesma coordenada.

## VB-05 — Furos e pixels fora dos diamantes
- **Descrição:** pequenas lacunas e linhas indevidas nas junções de estrada, água e praça.
- **Evidência/reprodução:** auditoria encontrou 28 pixels vazios no interior da estrada e 101 pixels fora do diamante da praça no primeiro produto de correção; as linhas decorativas antigas não respeitavam a máscara.
- **Causa:** polígonos rasterizados com convenções de borda diferentes e linhas desenhadas fora da superfície.
- **Arquivos:** `visual_patch.py`, `tests/test_assets.py`.
- **Correção:** máscara analítica por centro do pixel, derivada da transformação inversa isométrica, com células semiabertas. Interior é opaco e exterior transparente; buracos são preenchidos com a cor daquele terreno, sem misturar grama na água/estrada.
- **Validação:** cada pixel dos sete terrenos derivados é verificado contra a máscara, sem lacunas internas ou pixels externos. PNGs e capturas ampliadas revisados.

## VB-06 — Chão das árvores balançava
- **Descrição:** terreno e parte da base da árvore sofriam deslocamento durante o vento.
- **Evidência/reprodução:** renderizador dividia o tile na linha 42 e movia toda a parte superior; o chão já começa na linha 24.
- **Causa:** o recorte animado incluía a metade superior da superfície do terreno.
- **Arquivos:** `world_view.gd`, `visual_patch.py`.
- **Correção:** atlas com quatro fases, deslocando somente a copa acima de y=24. Tronco, superfície e pivô permanecem idênticos em todos os frames.
- **Validação:** teste byte a byte das linhas 24–63 de todos os frames e inspeção das árvores nas bordas leste/oeste. Animação de vento mantida.

## VB-07 — Profundidade divergente e sombras sobre objetos
- **Descrição:** NPC podia mudar de camada antes de alcançar visualmente a base de um prédio; sombras/anéis podiam pintar sobre a fachada.
- **Evidência/reprodução:** ordenar um cidadão cuja posição simulada já passou pela base, enquanto a interpolação ainda está atrás. Sombras eram desenhadas no mesmo loop do corpo, depois de construções.
- **Causa:** ordenação usava `c.position`, desenho usava interpolação; sombras não eram uma passagem de chão.
- **Arquivos:** `world_view.gd`, `render_policy.gd`.
- **Correção:** uma única posição de pé interpolada/alinhada serve para profundidade e desenho. Desempates estáveis. Sombras e anéis de chão são desenhados antes dos objetos. Objetos estáticos são ordenados em cache e mesclados com NPCs móveis.
- **Validação:** 342 verificações de pixels ocultados atrás de uma casa e 1503 verificações de pixels do NPC à frente, todas aprovadas; teste independente de ordem e NPC_Depth_Test.png. A árvore utiliza o mesmo comparador e pivô de superfície.

## VB-08 — Reamostragem, pés e sombra duplicada da montaria
- **Descrição:** pixels e contato com o chão variavam com escala; cavalo tinha duas sombras e pivô diferente dos cascos.
- **Evidência/reprodução:** sprites 48×56 eram reduzidos para 30×35 durante o desenho; cavalo 64×64 para 48×48. PNG do cavalo já continha sombra translúcida, somada à sombra desenhada pelo jogo.
- **Causa:** escala fracionária em runtime, pivôs aproximados `(15,33)` e `(24,36)` e sombra embutida.
- **Arquivos:** `visual_patch.py`, `render_policy.gd`, `world_view.gd`.
- **Correção:** redução nearest-neighbor uma única vez no pipeline. Frames nativos 30×35 com pivô `(15,35)` e cavalo 48×48 com pivô `(24,41)`. Sombra embutida removida na cópia; uma sombra de chão permanece. Cavalo e cavaleiro usam o mesmo relógio de fase; torso/pernas acompanham o novo ponto da sela.
- **Validação:** todos os frames de NPC mantêm a linha dos pés; cascos respeitam o limite 41, transparências do cavalo não contêm a sombra anterior. Capturas Cavalry_Closeup e Horse_Closeup. Idle, walk e work continuam animados.

## VB-09 — Fogo e fumaça sem suporte visual
- **Descrição:** partículas apareciam ao lado/por cima da origem correta, agravando a impressão de objetos flutuantes.
- **Evidência/reprodução:** inspeção de casas/padaria/estalagem/forja ampliadas; os offsets fixos de efeitos não correspondiam ao emissor do sprite e não acompanharam a correção de oito pixels.
- **Causa:** offsets independentes do ponto de origem do asset.
- **Arquivos:** `world_view.gd`, `visual_patch.py`.
- **Correção:** fumaça das casas ligada à saída real do telhado; forja derivada recebe pequena chaminé com emissor correspondente. Fogo e luzes foram alinhados à boca da fornalha e à nova superfície.
- **Validação:** Village_Closeup.png mostra a fornalha e a chaminé apoiadas na construção; sprites originais preservados.

## VB-10 — Saltos de posição ao replanejar ou carregar
- **Descrição:** moradores eram transportados instantaneamente para o centro do tile em obras, troca de ofício e load.
- **Evidência/reprodução:** usar a posição fracionária (15,25; 8,125), construir/trocar profissão/salvar e carregar. O código aplicava `.round()` diretamente à posição.
- **Causa:** quantização de estado de simulação era usada como correção de apresentação/replanejamento.
- **Arquivos:** `simulation.gd`, `save_store.gd`.
- **Correção:** preservar posição fracionária e reiniciar apenas a interpolação/rota. O pathfinder continua usando células inteiras e a validação de obstáculos existente. O save permanece no esquema 2, com a mesma estrutura.
- **Validação:** regressões específicas para os três casos; campanha real v0.2.0 carregada com 25 entidades/22 prédios e arquivo original inalterado. Custos, receitas, consumo, imigração, progressão e duração de trabalho não foram modificados.

## VB-11 — Arraste continuava depois de soltar sobre a UI
- **Descrição:** câmera podia continuar seguindo o mouse após a liberação do botão do meio num painel.
- **Evidência/reprodução:** começar o arraste no mapa e soltar sobre um botão/painel que consome input.
- **Causa:** liberação era tratada apenas em `_unhandled_input`.
- **Arquivos:** `game.gd`.
- **Correção:** liberação global em `_input`, sem consumir ações da interface, e cancelamento ao perder foco da janela.
- **Validação:** teste específico da liberação e integração de câmera/UI; estado de arraste é encerrado.

## VB-12 — Painéis ocupavam espaço excessivo e não acompanhavam a janela
- **Descrição:** painel de construção mostrava uma casa com grande coluna vazia; informações não podiam ser recolhidas; barras podiam disputar espaço com textos maiores.
- **Evidência/reprodução:** gravação inteira; redimensionar e alternar categorias.
- **Causa:** dimensões/posições fixas, altura mínima desnecessária e falta de controle de visibilidade.
- **Arquivos:** `hud.gd`, `game.gd`.
- **Correção:** construção ajusta altura à categoria, ambos os painéis podem ser recolhidos por botão ou B/I. Inspetor/barras ancorados no espaço disponível; texto limitado ao seu espaço e conteúdo do inspetor rolável. A câmera recebe o novo retângulo útil somente quando o layout muda.
- **Validação:** UI_Layout, UI_Collapsed, UI_Layout_960x540, UI_Layout_1080 e integração com seleção/construção/save. Fechar painéis expande a área útil sem deriva posterior.

## VB-13 — Letterboxing em proporções diferentes
- **Descrição:** uma janela larga podia manter conteúdo 1280×720 e barras externas, desperdiçando área da janela.
- **Evidência/reprodução:** primeira captura da janela 1600×720 ainda produziu viewport 1280×720; a gravação também tem proporção diferente de 16:9.
- **Causa:** stretch `canvas_items` com aspect padrão `keep`, enquanto a interface assumia a área total.
- **Arquivos:** `project.godot`, `hud.gd`, `camera_controller.gd`.
- **Correção:** aspect `expand`, com HUD e limites usando a dimensão real do viewport. Nearest-neighbor do mundo preservado; nenhuma mudança global de filtragem foi aplicada.
- **Validação:** UI_Wide_1600x720.png tem exatamente 1600×720, com inspetor no extremo direito; 960×540 e 1920×1080 também aprovados.

## Política de pixel art e limites restantes
Tiles 64×32, célula PNG 64×64 e origem de superfície (32,40). Objetos seguem os pés/bases, não o topo da imagem. Originais e produtos antigos ficam intactos; cópias corrigidas possuem diretórios/nomes de versão. Corpos são desenhados 1:1 em resolução nativa; zoom 2/3/4 dá ampliação inteira, 1,5 é uma opção intermediária com nearest-neighbor (não promete pixels físicos uniformes em toda escala). UI e portraits continuam responsivos.

O mundo é um tabuleiro, portanto há fundo visível ao inspecionar seus vértices, limitado e deliberado; não é uma paisagem infinita. Sprites ainda têm uma direção lateral, retratos/montaria continuam provisórios e NPCs não colidem entre si. Compressão/ghosting de alguns quadros do vídeo não foi atribuída automaticamente ao motor. Recrutamento e política não estavam implementados na v0.2.0 e não foram inventados ou removidos por este patch.

## Resultado consolidado
7 testes Python de assets; 21.111 verificações de lógica; 22.494 verificações de geometria/câmera; 23 de integração; 1.873 verificações no teste GPU de capturas/oclusão. Zero falhas no código validado. Dados brutos em `visual-validation/v0.2.1/validation.json`, `existing-save.json` e `benchmark.json`. A compilação Windows, commit/tag e publicação são registrados pelo pipeline de release e pelo relatório final, não presumidos pela compilação do editor.
