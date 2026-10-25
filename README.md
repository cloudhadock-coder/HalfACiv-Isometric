# HalfACiv Isometric — v0.2.2

**Vida na aldeia**: estratégia e construção medieval em Godot 4.7.2 / GDScript. Um mapa isométrico real, com moradores que trabalham, fazem refeições, descansam e transportam sua produção.

A **v0.2.2** estabelece o padrão artístico oficial dos retratos: [guia de estilo](docs/PORTRAIT_ART_STYLE_GUIDE.md) derivado de duas folhas de referência, [auditoria](docs/PORTRAIT_AUDIT.md) dos 24 retratos, pipeline de validação e integração em `tools/portrait_pipeline/`, exibição em escala inteira pixel-exata e [galeria de validação](docs/portrait-validation/portrait-gallery.png). Os retratos atuais continuam como fallback pendente; nenhuma arte nova foi desenhada nesta versão.

A **v0.2.1** corrige câmera, zoom, alinhamento, profundidade e UI da v0.2.0. [Relatório detalhado](docs/VISUAL_BUGS_V0.2.1.md) e [capturas reais](docs/visual-validation/v0.2.1/Contact_Sheet.png).

![A aldeia corrigida](docs/visual-validation/v0.2.1/Camera_Default.png)

## Executar no Windows
Baixe o ZIP em [GitHub Releases](https://github.com/cloudhadock-coder/HalfACiv-Isometric/releases), extraia e abra **HalfACiv-Isometric.exe**. Windows 10/11 x64; Godot não precisa estar instalado. O build local fica em `dist/v0.2.2/`.

No projeto fonte local, use `Jogar.cmd` ou abra `project.godot` no Godot 4.7.2 e pressione F5. A cópia local da engine está em `tools/godot`. O HalfACiv original não é modificado nem necessário para executar.

## Correções da v0.2.1
Câmera limitada pelo losango e pela área útil, zoom ancorado no cursor, superfície com origem (32,40), sprites nativos com pés alinhados, sombras abaixo dos objetos e vento sem mover o chão. B/I ou as setas recolhem os painéis. Estradas/água/praça não têm furos; o mundo termina num tabuleiro com borda uniforme. Em janelas largas, a vista utiliza a área total. Saves continuam no esquema 2, preservando posições fracionárias.

## Funcionalidades preservadas da v0.2.0
- 24 ofícios e uma comunidade inicial de 24 moradores, além do cavalo. Postos compatíveis têm limite de vagas; ofícios podem ser redistribuídos no inspetor.
- Trabalho de 06h a 12h e de 13h a 20h, refeição ao meio-dia, sono e recuperação de vigor. Guardas patrulham; construtores aceleram obras; carregadores buscam cargas.
- Produção depende da presença no posto. Recursos ficam no local de trabalho até serem entregues ao depósito ou à feira. Forja, padaria, carpintaria e estalagem usam insumos.
- 18 tipos de construção: os seis originais mais moinho, padaria, pesqueiro, forja, carpintaria, herbário, estalagem, depósito, estábulo, pasto, quartel e torre.
- Novas casas permitem imigração gradual, com alimento disponível e limite de 64 moradores. O pesqueiro exige margem de água; obras não podem cortar acessos existentes nem prender moradores.
- 24 retratos de 96×112 pixels (fallback legado, pendentes de redesenho no padrão 64×64), galeria selecionável e identidade visual preservada quando o ofício muda.
- Moinho e bandeiras animados, árvores ao vento, água, fumaça, fogo da forja, cargas visíveis e iluminação conforme o horário.
- Velocidades 1×/2×/4×, resumo da aldeia e inspeção de trabalhadores, insumos e produção em espera.

## Saves e compatibilidade
Saves da v0.1.0 são migrados para o esquema 2. Inventário e moradores são preservados; rotas são recalculadas. A primeira gravação de um save antigo mantém `realm.json.v0.1.bak`, além do backup rotativo `.bak`. Estoques dos postos, cargas, vigor, ofícios, identidade, entregas e horário são salvos. Autosave a cada 60 segundos reais de jogo ativo.

O progresso offline continua limitado a duas horas, com estimativa econômica conservadora de produtividade. Não move NPCs, não gera imigração e não cria decisões políticas.

## Desenvolvimento
Instale Pillow com `python -m pip install Pillow`. A instalação local em `tools/python_libs` também é reconhecida. Use cópias autorizadas do pacote em `assets/original/GandalfHardcore/` e do tileset em `assets/original/sprite-Sheet.png`. Execute `python tools/asset_pipeline/build.py` e importe o projeto no Godot.

Para exportar, mantenha os templates oficiais Windows em `tools/godot/windows_release_x86_64.exe` e `windows_debug_x86_64.exe`.

O pipeline é determinístico. `village_art.py` define roupas, ferramentas, retratos, paleta e adaptações dos edifícios. Os personagens derivados do GandalfHardcore são privados e **não entram no Git**. O repositório público exige que o desenvolvedor forneça seu pacote autorizado; o build já inclui os recursos incorporados.

## Verificação e releases
- `python tests/test_assets.py`
- `python tools/portrait_pipeline/validate.py` e `python tools/portrait_pipeline/generate_atlas.py` (retratos; veja [o pipeline](tools/portrait_pipeline/README.md))
- `Godot_console.exe --path . --script tests/portrait_ui_capture.gd` (retratos pixel-exatos na UI)
- `Godot_console.exe --headless --path . --script tests/test_runner.gd`
- `Godot_console.exe --path . --script tests/integration.gd`
- `Godot_console.exe --headless --path . --script tests/visual_tests.gd`
- `Godot_console.exe --path . --script tests/visual_validation.gd -- --no-save`
- `Godot_console.exe --path . --script tests/benchmark.gd`
- `python scripts/build_release.py` após commit limpo e tag correspondente; os testes são executados novamente antes do empacotamento.

Testes usam saves isolados em `tests/`. Evidências e limites em [docs/VALIDATION.md](docs/VALIDATION.md). Relatório de assets, controles, arquitetura e roadmap também estão em `docs/`.

## Limitações
Personagens ainda têm uma direção lateral; oito direções e cavalaria completa pertencem à v0.3.0. Os 24 retratos são placeholders aguardando arte desenhada à mão no padrão oficial ([pendências](docs/PORTRAIT_AUDIT.md#trabalho-artístico-pendente)); a montaria permanece provisória. Alguns prédios reutilizam bases do tileset com sinais e detalhes próprios. NPCs evitam obstáculos, mas não colidem entre si; casas e postos usam pontos de acesso externos, sem interiores. Não há combate, recrutamento, política, progressão de era ou menu de configurações nesta versão.
