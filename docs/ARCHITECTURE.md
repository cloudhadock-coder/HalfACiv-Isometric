# Arquitetura
Simulation e independente do render, ticks de um segundo com acumulador delta. Catalogo declarativo define custos, duracoes e beneficios. Iso converte celula/tela. AStarGrid2D cardinal evita cortar quinas; obras recalculam rotas. Entidades alternam repouso e percurso a posto de trabalho. Producao e comunitaria, nao vinculada a animacao.

WorldView desenha terreno e objetos ordenados por profundidade, atlas em cache e culling. Nearest-neighbor e camera com limites. HUD em CanvasLayer. Save JSON versionado, backup e rename; offline de ate 7200 ticks sem mover pessoas. Rotinas reiniciam ao carregar; estado do percurso nao persistido.

Para adicionar personagem: receita em tools/asset_pipeline/build.py e classe no citizen/HUD. Verifique frame, alpha e origem nos pes. Portraits: assets/portraits/N.png 64x80; substitua estudos e remova aviso somente quando finalizados. Cavalo: atlas 512x128, oito frames 64x64 por linha idle/walk. Construcoes: catalog.gd, recorte no pipeline e textura no WorldView. Novas direcoes devem ter arte propria, sem rotacao geometrica.

Pendencias: sistema de empregos, configuracoes, estado de save mais rigoroso, pathfinding incremental, tile cache para mapas maiores e benchmarks.
