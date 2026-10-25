# Validação v0.5.0 — Expansão territorial

## Base e preservação
Base publicada v0.4.2, Git limpo no início. A versão mantém economia, política, identidades, retratos, cavalaria, animações de prédios e UI. Projeção 64×32, pivô32,40 e ordenação pela base continuam iguais. A velocidade de deslocamento passa a considerar o terreno; receitas/tributos/reformas não foram reescritos.

## Testes novos
`tests/expansion_tests.gd` executado com janela OpenGL cobre:
- Geração repetível de 32/48/64 em sementes1/17/31337, dimensão da grade, centro e spawns válidos.
- Limites de câmera nos cinco zooms para 48/64 e quatro extremos do mapa 64.
- Ampliação clássica32→48→64 e mundo por semente48→64, verificando cada tile anterior após translação.
- Custos exatos, duplicação, falta de recursos, tamanho máximo, moradia/edifícios preservados e nenhum teleporte por edição de estrada.
- Salvamento/carregamento de ampliados e estradas, estado político/reformas conservados, remoção sem reembolso e rejeição atômica de edições inválidas.
- AStar prefere um desvio por estrada quando o custo é menor, respeita novo obstáculo e devolve cópias independentes do cache.
- Clique real do mouse constrói/remove estrada; clique real no minimapa navega pelo mapa 64; ida/volta de coordenadas.
- Blocos fora da vista ficam invisíveis; câmera e minimapa usam dimensão efetiva.
- Ampliação via UI mantém a aldeia no mesmo ponto da tela; configuração de mundo abre corretamente mesmo com ferramenta ativa.

Resultado observado: **3.667 verificações, zero falhas**, incluindo a persistência da clareira na migração v0.1→schema2 e o acesso ao território exterior nas sementes/tamanhos testados. Os resultados da repetição no commit marcado ficam no log de build e em BUILD_INFO.json.

`python tests/test_terrain.py`:2 testes aprovados, verificando todos os pixels das máscaras, resolução, paleta, texturas distintas e regeneração byte a byte sem criar portraits.

## Regressões
- `tests/test_runner.gd`:21.235 asserções sem falhas, incluindo90 sementes32×32 e migração/saves anteriores.
- `tests/integration.gd`:38 asserções sem falhas.
- `tests/visual_validation.gd -- --no-save`:1.864 checks GPU sem falhas, com 333 pixels de oclusão e 1.503 de NPC à frente.
- `tests/interface_capture.gd -- --no-save`:sem falhas, com o teste da prévia adaptado ao tamanho selecionado, em vez de assumir1024 tiles.
- `python tests/test_assets.py`:13 testes aprovados.
- Validação de retratos/atlas/kit/previews executada; nenhum portrait/parte foi criado ou promovido. 24 retratos e 19 partes continuam pendentes.

O pipeline repete todas essas suítes e as de câmera, política, campanha, recrutamento e animações no commit marcado. BUILD_INFO.json contém as contagens definitivas. O EXE é exportado e executado em headless/OpenGL; o smoke novo inicia64×64, executa construção de estrada e verifica câmera, minimapa e64 blocos embarcados.

## Save real
Arquivo pessoal encontrado: v0.4.1, schema 2,25 entidades e 22 construções. Carregado sem alterar o hash original; resultado em existing-save.json. Não foi ampliado, salvo nem publicado o save pessoal. Saves de testes usam caminhos separados e são removidos ao final.

## Validação visual
Capturas reais em visual-validation/v0.5.0: World_64, Road_Editing, Terrain_dirt, Terrain_sand, Terrain_stone, Expanded_Existing_Realm, UI_960x540, World_Setup e Existing_Save. Foram produzidas pelo viewport do Godot, incluindo input real; não são imagens fictícias. A prévia do mundo e o minimapa mostram as dimensões maiores, os novos solos foram inspecionados e a aldeia permanece ancorada após ampliar.

No primeiro teste de load, o tamanho salvo pelo JSON vinha como float e a lista de tamanhos exigia inteiros; normalização/validação corrigida. O teste de preferência por estrada usava um desvio curto cujo custo era de fato maior que o direto; corrigido para uma situação em que a estrada é a rota ótima. A edição por clique foi testada com a campanha em execução, pois pausa bloqueia comandos no mapa. O menu Novo mundo passou a fechar ferramentas antes de abrir a configuração, evitando a página ficar escondida.

## Performance medida
Godot 4.7.2/OpenGL, RX 580 2048SP, VSync desativado, câmera padrão,360 frames após aquecimento: mapa 64×64 com 64 cavaleiros equipados e mais um cavalo. Média 100,2 FPS, p95 de 11,612 ms, amostra 1.272 draw calls,64 blocos de terreno, memória estática da engine 48,8 MB. Não é RSS/VRAM nem promessa para outro hardware ou todos os zooms. Sem alegação de melhoria percentual em relação a mapas menores.

## Limites
64×64,64 moradores,1024 construções; ferramentas por clique, sem drag, pontes, derrubada de floresta, descoberta ou guerra. Remoção deixa terra batida; não restaura o bioma anterior nem reembolsa. Novos solos não produzem recursos sozinhos. O núcleo antigo é preservado dentro do território maior. Pendências artísticas anteriores continuam. Publicação só é confirmada depois de verificar tag/commit e hash do ZIP remoto.
