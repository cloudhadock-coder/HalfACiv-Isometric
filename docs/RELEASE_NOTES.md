# HalfACiv Isometric v0.4.2 — Sprites e animações

Atualiza o uso da folha de construções fornecida, preservando a política/progressão da v0.4.1 e todos os sistemas anteriores.

## Implementado
- 18 tipos com sprites derivados da folha nativa, incluindo igreja para a capela, acampamento para a serraria e posto fortificado com bandeira azul para a torre.
- Nove sequências: moinho com 4 frames, bandeiras com 14, fumaça de casas e trigo com 16; FPS e contagens explícitos.
- A torre não alterna mais entre estruturas diferentes.
- Cercas e solo fixos no trigo; fumaça nativa sem camada procedural duplicada nas casas.
- Previews do inspector, da construção e do mapa consistentes; obras e ghosts ficam no frame 0; pausa congela as animações.
- Pipeline isolado e determinístico, sem alterar personagens/retratos nem restaurar os atlas removidos localmente.
- Pivô, bordas, nearest-neighbor, transparência nativa e ordenação preservados. Testes de profundidade com a máscara do frame efetivamente desenhado.

## Executar
Extraia o ZIP e execute HalfACiv-Isometric.exe no Windows 10/11 x64. Salve/feche a versão antiga e use Carregar domínio. Saves mantêm o schema 2; não há mudança das regras de política, produção, recrutamento, progressão ou mundos por semente. Controles anteriores preservados: WASD, roda, meio, minimapa, B/I/H/R/P, F5.

## Validação
Testes e verificações reais em BUILD_INFO.json e docs/VALIDATION_V0.4.2.md. Capturas reais em docs/visual-validation/v0.4.2/. O EXE exportado é executado em headless/OpenGL, com verificação do catálogo de animações embarcado. A folha original completa não acompanha o ZIP como asset solto.

## Limitações
Nem toda célula da folha é animação; variantes estáticas não são reproduzidas como ciclos. Os nove tipos sem sequência continuam com sprite estático e efeitos ambientais aplicáveis. A torre usa o posto fortificado animado da folha. Cavalaria lateral e aprovação dos retratos continuam pendentes, sem alterações nesta versão.

## Créditos
Isometric Strategy - Medieval Pixel Art Tiles, crabcrabcrabs, CC BY 4.0: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles . Recortes, paleta de solo, detalhes ocupacionais e estabilização das hortas descritos em CREDITS.md. GandalfHardcore Character Asset Pack incorporado conforme licença, sem sprites soltos. Godot 4.7.2/MIT. Nenhuma referência licenciada foi enviada a IA.

Commit testado: `{{COMMIT}}`.
