# HalfACiv Isometric v0.1.0
Uma fundacao jogavel para construir uma aldeia medieval em perspectiva isometrica.

## Funcionalidades
- Godot 4.7.2, mapa 32x32 com tiles 64x32, camera com zoom e arraste.
- Casas, hortas, serrarias, pedreiras, feiras e capelas: custos, obra e producao.
- Alimento, madeira, pedra, ouro e influencia; consumo populacional e autosave.
- 12 composicoes modulares GandalfHardcore com idle/walk, 13 entidades incluindo cavalo e cavaleiro.
- Navegacao cardinal com obstaculos e rotas recalculadas apos construir.
- 12 estudos de retratos distintos, selecao de personagem/construcao, menu e pausa.
- Save/load atomico com backup, progresso offline limitado a duas horas.

## Correcoes
Recortes de estrada e agua, escala dos personagens, postura da montaria, protecao de tiles atravessados por NPCs durante obras e tratamento de JSON corrompido.

## Validacao
2.864 verificacoes GDScript e tres testes de assets passaram. Teste integrado com janela verificou clique para construir, economia, zoom, save/load, retrato e pausa. Captura real inspecionada em OpenGL com Radeon RX 580 2048SP. Resultado de exportacao/execucao do build em docs/VALIDATION.md.

## Limitacoes conhecidas
Sprites laterais em uma direcao; oito direcoes ainda exigem arte propria. Cavalo e portraits sao estudos provis?rios, identificados na interface. Cavaleiro sem armadura final. Trabalho comunitario sem simulacao de produtividade individual. Sem recrutamento, faccoes, progressao de era, configuracoes ou combate nesta fundacao. Nenhuma meta de 60 FPS certificada.

## Windows 10/11 x64
Extraia o ZIP e execute HalfACiv-Isometric.exe. Nao precisa instalar Godot. WASD move; roda faz zoom; botao do meio arrasta; clique seleciona/constroi; Esc pausa; F5 salva. Save em %APPDATA%/Godot/app_userdata/HalfACiv Isometric/realm.json.

## Creditos
Tiles: crabcrabcrabs, CC BY 4.0, https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles. Personagens: GandalfHardcore, licenca propria para uso em jogos. Originais e atlas restritos nao incluidos no repositorio fonte. Cavalo e retratos provis?rios originais deste projeto. GIFs de referencia nao distribuidos.

Commit testado: sera registrado pelo script de publicacao a partir do HEAD exato.
