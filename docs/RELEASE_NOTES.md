# HalfACiv Isometric v0.5.0 — Expansão territorial

## Incluído
- Escolha de mapas 32×32,48×48 e64×64; novos mundos aleatórios usam48 e o clássico continua32.
- Ampliação32→48→64 de domínio existente por 150 ouro+25 influência por etapa, mantendo terreno conhecido, moradores, edifícios, equipamentos, cargas, política e edições. Câmera compensa a translação da aldeia.
- T constrói estrada por clique (1 pedra/tile); Y remove (terra batida, sem reembolso). Água, árvores e prédios são protegidos. Esc cancela.
- Terra, areia e solo pedregoso com custos próprios; estradas mais rápidas. AStar ponderado com atualização incremental de tiles, cache de caminhos e cópias por consumidor.
- Terreno em blocos 8×8 com culling; minimapa, limites da câmera e nova prévia respeitam a dimensão efetiva.
- Saves antigos são lidos; novos campos opcionais guardam tamanho/base e edições com validação antes de alterar o estado vivo.

## Executar
Extraia o ZIP e abra HalfACiv-Isometric.exe no Windows10/11 x64. Salve e feche a versão antiga e use Carregar domínio. Para ampliar um save, menu Aldeia→Ampliar mapa. Para um mundo novo, Personalizar mundo→Tamanho. WASD, roda, meio, minimapa, B/I/H/R/P e F5 continuam disponíveis; T/Y são as ferramentas novas.

## Validação
Testes no commit marcado, inclusive expansão/persistência, input real, câmera em vários zooms, solos e navegação. Capturas em docs/visual-validation/v0.5.0 e regras em EXPANSION.md. BUILD_INFO.json registra commit, hashes, suítes e benchmark64×64 com 64 cavaleiros. O EXE é executado em headless/OpenGL e confirma mapa, grade e recursos de expansão incorporados.

## Compatibilidade e limites
Máximo64×64,64 moradores e1024 construções. Estradas por clique, sem arrasto, pontes ou derrubada de mata. Novos solos afetam deslocamento; produção segue os postos existentes. Sem guerra, descoberta ou fronteiras de facções. Versões antigas não compreendem edições/mapas ampliados: a compatibilidade é de leitura de saves anteriores pela nova versão. Retratos e cavalaria mantêm as pendências artísticas documentadas.

## Créditos
Terrenos novos: arte nativa determinística do projeto. Tiles originais crabcrabcrabs/CC BY4.0: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles . GandalfHardcore incorporado conforme licença, sem assets soltos; Godot 4.7.2/MIT. Licenças e créditos anexados. Nenhuma referência licenciada foi enviada a IA.

Commit testado: `{{COMMIT}}`.
