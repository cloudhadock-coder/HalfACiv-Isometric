# HalfACiv Isometric v0.2.1 — Visual Fixes

Patch de câmera, alinhamento isométrico, profundidade, pixel art e interface, preservando o gameplay e saves da v0.2.0.

## Correções
- Câmera com limites convexos do losango, considerando viewport, zoom e painéis. Cantos continuam inspecionáveis; câmera não deriva parada.
- Zoom previsível 1×/1,5×/2×/3×/4×, padrão 2×, com âncora no cursor quando possível. Mínimo depende da área útil.
- Borda de tabuleiro uniforme, fundo discreto e estradas/água/praça sem furos ou pixels fora do diamante.
- Origem real da superfície corrigida de (32,48) para (32,40); bases, seleção e pés alinhados. Extrusões internas removidas em cópias dos assets.
- Profundidade usa o mesmo pé interpolado do desenho; sombras e anéis ficam no chão, abaixo dos objetos.
- Sprites pré-reduzidos por nearest-neighbor no pipeline, pivôs consistentes e uma única sombra para o cavalo. Árvores não deslocam o terreno ao balançar.
- Fumaça, fogo e luzes alinhados aos respectivos emissores.
- Posições fracionárias preservadas ao construir, trocar ofício e carregar. Arraste termina mesmo quando o mouse é solto sobre a UI.
- Painéis recolhíveis (B/I), altura de construção ajustada à categoria e layout responsivo, inclusive janelas largas sem letterboxing.

## Preservação e validação
Economia, receitas, construções, profissões, rotinas, animações e formato de save (esquema 2) mantidos. Save real v0.2.0 carregado com 25 entidades e 22 prédios, sem modificar o arquivo original.

Passaram **7 testes de assets**, **21.111 verificações de lógica**, **22.494 de geometria/câmera**, **23 de integração** e **1.873 verificações GPU**, incluindo 342 pixels de NPC ocultados atrás da casa e 1503 pixels à frente. Capturas reais em 960×540, 1280×720, 1600×720 e 1920×1080; comparações antes/depois e relatório em docs/visual-validation/v0.2.1 e docs/VISUAL_BUGS_V0.2.1.md.

Benchmark local com 64 moradores + cavalo, 360 frames, RX 580 2048SP/OpenGL: **160.4 FPS**, p95 **6.923 ms**, cerca de **41.6 MB de memória estática do motor** e **986 draw calls** no quadro medido. Zoom/enquadramento diferem da v0.2.0; não se afirma ganho percentual nem garantia para outras máquinas.

## Executar no Windows 10/11 x64
Extraia o ZIP e abra HalfACiv-Isometric.exe. WASD move, roda aproxima/afasta, botão do meio arrasta. B/I recolhem os painéis; Esc/Espaço pausam; F5 salva. Não precisa instalar Godot.

## Limitações restantes
Tabuleiro finito: fundo deliberado aparece junto aos vértices. Uma direção lateral, retratos/montaria em desenvolvimento, sem colisão entre NPCs ou interiores. O patch não adiciona recrutamento, combate ou política. A arte e as funcionalidades existentes foram preservadas; não houve reescrita do jogo.

## Créditos
Tiles crabcrabcrabs (CC BY 4.0), personagens GandalfHardcore sob licença de incorporação em jogos. Originais e atlas privados excluídos do código-fonte público. Assets corrigidos são cópias derivadas; GIFs/vídeo de referência não são distribuídos.

Commit testado: `{{COMMIT}}`.
