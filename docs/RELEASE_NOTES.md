# HalfACiv Isometric v0.2.0 — Vida na aldeia

Os moradores agora têm ofícios, rotinas e produção ligada ao seu trabalho. A aldeia inicial inclui 24 moradores, um cavalo e 22 construções.

## Novidades
- **24 profissões:** 12 novos ofícios, incluindo agricultora, pescador, moleiro, padeira, ferreiro, carpinteiro, herbalista, cervejeiro, pastora, estalajadeira, carregador e vigia.
- **Rotinas:** trabalho pela manhã e à tarde, refeição ao meio-dia, sono, vigor, patrulhas e auxílio do construtor. Ofícios podem ser redistribuídos sem alterar a identidade da pessoa.
- **Logística funcional:** produção exige presença no posto; recursos aguardam coleta e só entram no estoque comum após entrega. Receitas respeitam consumo de insumos.
- **18 construções disponíveis:** adicionados moinho, padaria, pesqueiro, forja, carpintaria, herbário, estalagem, depósito, estábulo, pasto, quartel e torre. Pesqueiros exigem margem de água; casas permitem imigração gradual.
- **Ambiente vivo:** pás de moinho, bandeiras, árvores, água, fumaça, fogo e iluminação conforme o horário. Terreno com cores mais suaves, variantes de grama e praça pavimentada.
- **24 retratos de 96×112:** galeria selecionável, ferramentas e detalhes de ofício; retratos permanecem identificados como arte em desenvolvimento.
- **Interface:** categorias de construção, postos e insumos no inspetor, cargas e entregas do morador, resumo da aldeia e velocidades 1×/2×/4×.

## Compatibilidade e correções
- Saves da v0.1.0 são migrados para esquema 2, preservando recursos e moradores. A primeira gravação mantém uma cópia `realm.json.v0.1.bak`.
- Cargas, estoques dos postos, vigor, ofícios, aparência, horário e entregas são persistidos; rotas são recalculadas.
- Obras não podem prender moradores nem fechar acessos existentes. Saves com um prédio na antiga praça continuam permitindo expansão.
- Corrigidas ordem das identidades ao carregar, duplicação de retrato e seleção após imigração.
- Offline limitado a duas horas com estimativa econômica conservadora, sem mover pessoas, gerar imigração ou criar eventos visuais.

## Validação
21.084 verificações GDScript, cinco testes Python de assets e 18 verificações de integração passaram. O teste integrado cobre clique de construção, troca de ofício, galeria, velocidades, save/load, pausa e inspetores. Capturas inspecionadas em 960×540, 1280×720 e 1920×1080, incluindo noite e galeria.

Benchmark local de 360 frames com 64 moradores, Godot 4.7.2/OpenGL, Radeon RX 580 2048SP: **137.3 FPS de média**, p95 de **8.46 ms por frame**, VSync desativado. Não é garantia para outras máquinas ou cenas.

O empacotamento repete os testes e inicia o EXE Windows exportado; logs e BUILD_INFO.json identificam o commit e o hash do executável.

## Windows 10/11 x64
Extraia o ZIP e execute `HalfACiv-Isometric.exe`, sem instalar Godot. WASD move a câmera; roda faz zoom; botão do meio arrasta. Escolha categoria/construção e clique no terreno. Clique em pessoas para trocar ofício ou inspecionar. 1/2/4 alteram velocidade; Esc/Espaço pausam; F5 salva.

Save em `%APPDATA%/Godot/app_userdata/HalfACiv Isometric/realm.json`. Backup rotativo `.bak`; backup de migração `.v0.1.bak`.

## Limitações conhecidas
Personagens ainda têm uma direção lateral. Trabalho usa poses idle com ferramenta sobreposta; não inclui novos ciclos anatômicos completos. Cavalaria e retratos continuam em desenvolvimento. Algumas construções compartilham bases visuais. Não há interiores, colisão entre NPCs, combate, recrutamento, política, evolução de era ou configurações. Esses sistemas continuam no roadmap.

## Créditos e commit
Tiles: **crabcrabcrabs**, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), [origem](https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles). Personagens: **GandalfHardcore**, licença própria para incorporação em jogos; originais e atlas derivados excluídos do código-fonte público. Retratos, ferramentas e adaptações são produzidos pelo pipeline editável. GIFs de referência não são distribuídos.

Commit testado: `{{COMMIT}}`.
