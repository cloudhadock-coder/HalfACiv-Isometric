# Construções e animações v0.4.2

Regenerar somente o escopo desta versão:

```powershell
python tools/asset_pipeline/buildings.py
python tests/test_buildings.py
& tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --script tests/building_animation_tests.gd
```

O script recebe `--source` e `--root`. A fonte nativa é `assets/art_reference/Buildings/sprite-Sheet.png`, com cópia idêntica em `assets/original/sprite-Sheet.png`. Não envie a IA nem publique as referências/originais. A saída derivada fica em `assets/buildings/native_v042/`: atlas horizontal 64×64 por frame, preview do frame 0 e `manifest.json` com FPS, contagem, origem e hash. O export inclui esse manifesto; originais ficam excluídos.

A lista `SPECS` em `buildings.py` define explicitamente linha e colunas por prédio. Não confunda variantes de direção, construção ou estrutura com ciclos. Moinho: 4 frames/6 FPS; bandeiras: 14/8 FPS; casas: 16/8 FPS; trigo: 16/6 FPS. Nove tipos animados, nove estáticos. Capela é a igreja; torre é o posto fortificado com bandeira azul. Adaptações ocupacionais são aplicadas identicamente em cada frame para não piscar.

`src/rendering/building_art.gd` carrega metadados/texturas uma vez. `WorldView.building_frame()` determina o frame usando o relógio ambiental e um offset determinístico pelo tile. Sem alterações de escala ou pivô em runtime. O pivô continua 32,40 e o sort usa a base. `live=false` congela previews e obras no frame 0. Pausar congela o relógio inteiro. No inspector e nos botões, os previews são os mesmos do catálogo novo.

Os recortes do trigo perdem trechos de cerca em algumas colunas: por isso só as cores de trigo são transferidas dentro de uma silhueta fixa sobre a base original, sem rotação, deformação ou interpolação. A fumaça das casas já está na folha e não recebe uma segunda fumaça procedural. Alfa nativo 68 (além de 0 e 255) é mantido; não é borrão de escala. Bordas inferiores são aparadas na mesma máscara da v0.2.1, mantendo o tabuleiro externo intacto.

Para adicionar um prédio, registre seu ID no catálogo de gameplay e um `SPECS` correspondente, gere o atlas e valide dimensões, frames vazios, estabilidade da base e contorno na transição último→primeiro frame. Não substitua IDs existentes de save. Detalhes da auditoria em ASSET_AUDIT.md.

As remoções locais dos atlas antigos de moinho e torre foram preservadas; os geradores legados não os recriam mais. A regeneração completa de assets continua em `build.py`, mas não é necessária para uma alteração só de construções. Personagens e portraits não foram regenerados nesta atualização.
