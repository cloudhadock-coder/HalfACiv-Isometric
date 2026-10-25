# Arquitetura v0.2.0

## Simulação e profissões
`simulation.gd` mantém o estado sem depender do render. `advance` consome passos fixos de 0,1 segundo; `tick` permite rodar o mesmo modelo em testes. `professions.gd` define 24 IDs estáveis, postos compatíveis e ferramentas. `citizen.gd` implementa viagem, trabalho, coleta, entrega, refeição, sono, construção e patrulha. O dia dura 240 segundos de simulação.

A atribuição respeita as vagas e a acessibilidade dos postos. Produção só acontece com o morador no ponto de trabalho. Receitas retiram insumos do estoque comum e acumulam saída em `building.stored`. Cargas de até 12 unidades vão ao depósito ou à feira, sendo creditadas uma única vez. O carregador busca o estoque acessível mais próximo. Guarda, arqueiro e cavaleiro geram a influência de sua base enquanto cumprem o turno de patrulha.

Casas oferecem quatro vagas além das quatro iniciais. A imigração acrescenta um morador a cada 20 segundos com vaga e ao menos 30 de alimento, até 64 moradores. O construtor acelera uma obra em 80% enquanto permanece no canteiro; a comunidade mantém a velocidade básica mesmo sem ele.

## Navegação e construção
AStarGrid2D cardinal evita cortar quinas. Obras são rejeitadas quando ocupam a aresta atravessada por um morador, fecham um acesso existente ou isolam um habitante do centro da aldeia. A validação usa um obstáculo temporário e desfaz mapa e custo em caso de falha. O acesso central adapta-se a saves antigos com um prédio na antiga praça. Pontos e rotas são recalculados após obras e ao carregar.

## Render e interface
`ground_layer.gd` mantém o terreno em comandos de desenho persistentes; só invalida ao trocar o mapa. `world_view.gd` guarda os objetos estáticos em cache, mistura com pessoas e ordena por profundidade. Posições são interpoladas entre passos da simulação; texturas em cache e nearest-neighbor. `environment_fx.gd` contém efeitos pixelados leves. Objetos dinâmicos fora da câmera são descartados do desenho. O ambiente acompanha o horário e para na pausa.

HUD em CanvasLayer, atualizado aproximadamente sete vezes por segundo; retratos pré-carregados. Categorias de construção, inspetor de pessoa/prédio, galeria, velocidades e pausa. O ofício pode mudar sem alterar nome, tom de pele, cabelo ou retrato do indivíduo; ferramenta de trabalho e posto seguem o novo ofício.

## Persistência
Esquema JSON 2. Validação completa em estado candidato antes de substituir a campanha ativa. Escrita temporária, backup e rename. Lê esquema 1; preserva `realm.json.v0.1.bak` na primeira gravação migrada. Pessoas mantêm ordem estável. Carga, estoques, vigor, aparência, ofício e relógio persistem; rotas e pontos são recalculados. Posições bloqueadas ou isoladas são transferidas para acesso seguro.

Offline: no máximo 7200 segundos, sem movimento, imigração ou eventos visuais. Usa fração de trabalhadores atribuídos e fator conservador de 55% durante o turno, respeita insumos, consumo e horário. Obras avançam sem bônus de construtor. Não equivale à simulação visual exata.

## Adicionar conteúdo
Profissão: acrescentar ID em `professions.gd`, receita de aparência em `village_art.py` e testes. Não reordenar IDs existentes. Prédio: entrada em `catalog.gd` e tile/atlas no pipeline; `WorldView` carrega o catálogo automaticamente. Retrato: 96×112 em `assets/portraits/ID.png`; corpo e retrato compartilham uma identidade independente do ofício. Personagem: atlas 384×168, frames 48×56, linhas idle/walk/work, contagens 5/8/8. A linha work usa poses idle com ferramenta sobreposta, não animações direcionais inéditas. Cavalo mantém atlas 512×128 com oito frames por linha. Novas direções exigem produção artística, sem rotação de 45 graus.


## Patch visual v0.2.1
`camera_bounds.gd` calcula região convexa do losango/viewport, incluindo margem limitada para inspecionar seus vértices; `camera_controller.gd` mantém foco, zoom discreto, âncora e translação alinhada ao pixel. Região em cache só muda com layout/zoom. `table_backdrop.gd` é um CanvasLayer fixo, independente da câmera. A borda de pedra pertence apenas ao contorno global.

A superfície nativa é centrada em (32,40), não (32,48). `visual_patch.py` gera cópias alinhadas, máscaras analíticas e frames já reduzidos por nearest-neighbor; não edita fontes anteriores. `render_policy.gd` define pivôs e desempate estável. A posição interpolada é calculada uma vez por pessoa e usada para desenhar/ordenar; a lista estática em cache é mesclada à lista móvel. Sombras são uma passagem anterior aos objetos.

A posição simulada não é mais arredondada por construção/troca de ofício/load; o pathfinder continua a usar células. Nenhum custo, receita, turno, imigração ou regra de progressão mudou. Save continua no esquema 2. `window/stretch/aspect=expand` foi validado por captura real 1600×720, e HUD/rig trabalham no viewport efetivo. Regressões geométricas e oclusão GPU fazem parte do build.

## Interface e mundos por semente

`hud.gd` monta a barra de menus, a coluna direita (`minimap.gd`, status, informações) e as janelas, com o tema de `ui_theme.gd`. `main_menu.gd` cuida do menu principal, da pausa e da tela de novo mundo. `world_gen.gd` gera terreno e vila a partir de `{seed, landscape, bounty, name}`; `Sim.new(settings)` usa o gerador, e `Sim.new()` mantém o mapa clássico. O save guarda `world` e regenera o terreno ao carregar. Detalhes em [INTERFACE.md](INTERFACE.md).

## Companhia v0.3.0

`entities/company.gd` contém catálogo estável, pré-condições, transação de contratação e bônus. `ui/company_panel.gd` é a apresentação. Os contratos reutilizam a identidade do fundador e só criam uma pessoa se ausente e com moradia disponível. O bônus produtivo escala o delta do próprio trabalho (insumos e produção); o de cavalaria escala deslocamento. `Citizen.equipment` guarda índices normalizados e dois booleanos; `specialist` é ID estável. Save schema 2 com campos opcionais: antigos usam defaults e dados inválidos não alteram o estado vivo. Renderização compõe camadas em `world_view.gd`, mantendo a base e o sort corrigidos na v0.2.1.

Gerar equipamento: `python tools/asset_pipeline/cavalry.py`; integrado ao build completo de assets. Atlas 384×96, 8 frames por linha, idle/walk, pivô 24,41; catálogo de pelagens e heráldica no Company. Arte e lógica separadas. Não espelhar unilateralmente escudos e estandartes. A biblioteca original só fornece vista lateral: não fingir oito direções.
