# HalfACiv Isometric
Fundacao jogavel em Godot 4.7.2 / GDScript. Versao: **0.1.0**, fundacao. Veja docs/RELEASE_NOTES.md para escopo e limitacoes.

## Executar no Windows
Build: extraia o ZIP da GitHub Release e execute HalfACiv-Isometric.exe, sem instalar a engine.

No projeto fonte local, clique em Jogar.cmd (usa o Godot local em tools/godot) ou abra project.godot no Godot 4.7.2 e pressione F5. O jogo nao depende do HalfACiv original. Assets privados precisam estar presentes.

## Desenvolvimento
Pillow e necessario ao pipeline: `python -m pip install Pillow`. Copie os assets autorizados para assets/original/GandalfHardcore e assets/original/sprite-Sheet.png; execute `python tools/asset_pipeline/build.py`. Os atlas derivados sao privados por restricao de licenca. A instalacao local de Pillow em tools/python_libs e reconhecida automaticamente.

## Presente
Mapa isometrico 32x32, camera/zoom, seis construcoes com custo/tempo, economia com cinco recursos, consumo de comida, 13 entidades, animacoes idle/walk, navegacao AStar com obstaculos, montaria, 12 composicoes e retratos provis?rios, selecao, menu/pausa, autosave, backup e progresso offline de ate duas horas.

## Testes
`python tests/test_assets.py`
`Godot_console.exe --headless --path . --script tests/test_runner.gd`
`Godot_console.exe --headless --path . -- --smoke`
Resultados e limites em docs/VALIDATION.md. Testes de save usam caminho isolado dentro de tests.

## Limites atuais
Uma direcao lateral; sem armaduras finais. Portraits e cavalo sao estudos provis?rios. Sem recrutamento, politica, progressao de era, melhorias ou configuracoes. Trabalho e comunitario, nao associado a produtividade individual. Meta 60 FPS ainda nao medida. Atribuicao do tileset confirmada: crabcrabcrabs (CC BY 4.0).

Veja docs/CONTROLS.md, docs/ARCHITECTURE.md e docs/ROADMAP.md.
