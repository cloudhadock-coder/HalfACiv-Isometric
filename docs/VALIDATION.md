# Validacao v0.1.0

## Ambiente
Windows, Godot 4.7.2 stable oficial, OpenGL 3.3 Compatibility, AMD Radeon RX 580 2048SP. Nao foi realizado benchmark de 60 FPS nem validacao em outros modelos de GPU.

## Resultados obtidos
- Importacao e inicializacao do projeto sem erros.
- 2.864 verificacoes GDScript: coordenadas, custos, sobreposicao, terreno bloqueado, conclusao de obra, populacao, consumo, tick, AStar, 1.800 passos de movimento sem colidir, offline limitado/deterministico, save/load e dados invalidos.
- Tres testes Python de assets: frames nao vazios e distintos, 12 retratos distintos e loops de cavalo com variacao.
- Teste integrado com janela: continuar no menu, producao, zoom, sinal do painel, clique real para colocar horta, salvar/carregar, pausa e retrato; zero falhas.
- Export Windows x64 com recursos incorporados no EXE, sem originais nem GIFs de referencia.
- EXE iniciou com OpenGL, simulou quatro ticks com 13 entidades e encerrou com codigo 0; log final-smoke.log sem erros. Headless do build tambem passou antes dos ultimos ajustes de validacao de saves; build final verificado com OpenGL.
- Capturas reais inspecionadas apos corrigir estrada, agua, escala e montaria. Resolucoes efetivamente capturadas: {'gameplay.png': (1886, 1061), 'gameplay-960x540.png': (960, 540)}. Janela solicitada em 1920x1080 foi ajustada pelo Windows a area util do monitor; nao confundir resolucao solicitada com imagem capturada.

## Limites
A inspecao confirma composicao estatica de frames e execucao de animacoes, mas nao substitui revisao artistica de todos os frames. Retratos e cavalo sao provis?rios; uma direcao lateral. Caminhos evitam tiles bloqueados; NPCs nao possuem colisao entre si. Trabalhadores simbolizam trabalho comunitario, nao producao individual. Sem politica/recrutamento/progressao de era nesta versao, portanto sem testes desses sistemas ainda ausentes. Licenca GandalfHardcore permite incorporacao em jogos; atlas separados excluidos do Git. Atribuicao CC BY verificada para crabcrabcrabs.

## Publicacao
A Release so pode ser declarada publicada apos o script verificar o endpoint GitHub, o commit da tag e o tamanho/digest do ZIP. O relatorio final registra o resultado real.
