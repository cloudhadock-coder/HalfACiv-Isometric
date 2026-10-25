# Validação v0.3.0 — Cavalaria e personagens

## Base preservada
Base publicada v0.2.2 (`1acf83d`). O diretório já tinha trabalho local de retratos, kit, persistência e testes. Essas alterações foram mantidas e integradas; nenhum retrato ou parte foi promovido. As correções visuais da v0.2.1 e o schema 2 permanecem.

## Testes executados
- `python tests/test_assets.py`: 11 testes, sem falhas, incluindo kit e determinismo.
- `python tests/test_cavalry.py`: 3 testes, sem falhas; dimensões, alfa binário, frames não vazios, variantes distintas e regeneração idêntica sem alterar o original.
- `tests/test_runner.gd`: 21.118 asserções, sem falhas (economia, obras, rotinas, saves, kit).
- `tests/visual_tests.gd` headless: 22.482 asserções, sem falhas (câmera, zoom, picking, limites).
- `tests/integration.gd`: 27 asserções, sem falhas; construção e UI real.
- `tests/company_tests.gd` OpenGL: 24 verificações, sem falhas; botão de contratação, custo, duplicação, falta de ouro, estábulo, fundador ausente, bônus e insumos online/offline, ritmo na navegação, equipamento via OptionButton, saves antigos e atuais, rejeição atômica de inválidos, resolução e animação.
- `tests/visual_validation.gd -- --no-save`: 1.873 checks GPU, sem falhas. 342 pixels de oclusão e 1.503 de NPC à frente confirmam profundidade.
- `tests/portrait_ui_capture.gd -- --no-save`: 3 verificações pixel-exatas, sem falhas, em 720p/1080p.
- `validate.py`, `generate_atlas.py`, `kit.py validate` e `kit.py preview`: sem erros técnicos. 24 retratos finais e 19 partes continuam pendentes; validação técnica não é aprovação artística.
- Save real encontrado, origem v0.2.1, schema 2: 25 entidades e 22 construções carregadas. Hash do arquivo original inalterado; nenhum save pessoal foi substituído.

O pipeline de release repete os testes no commit marcado, exporta Windows, executa smoke headless e smoke OpenGL da companhia no EXE exportado, valida a inclusão do manifesto do kit e registra o commit e hashes em BUILD_INFO.json. A publicação só é confirmada no relatório final após verificar GitHub.

## Capturas reais inspecionadas
Em `visual-validation/v0.3.0/`: Recruitment, Equipment, Equipment_960x540, Heraldry, Village e Existing_Save. Foram obtidas do viewport do Godot em execução, sem montar screenshots fictícios. Heraldry é uma fixture controlada de seis cavaleiros para comparar camadas, explicitamente criada no teste; não é uma campanha com seis contratações. A inspeção encontrou sobreposição do retrato legado na lista de contratos; a largura nativa 96 foi restaurada e a captura corrigida foi reinspecionada. Atlas de heráldica e cores também inspecionado no mapa.

## Performance medida
RX 580 2048SP, Godot 4.7.2/OpenGL, VSync desligado, 360 frames: 64 cavaleiros com barda, equipamento e estandarte, mais um cavalo. Média **114,3 FPS**, p95 **9,89 ms**, amostra de **1.400 draw calls**, memória estática da engine **42,8 MB**. Estes valores são desta máquina e desta cena; não constituem garantia de 60 FPS em todo hardware nem medem RSS/VRAM. Um ensaio anterior com moradores comuns mediu 148,7 FPS. Sem alegação de ganho em relação a versões anteriores com outra carga.

## Limitações assumidas
Sem combate ou oito direções. Passo é o ciclo original lateral; trote/galope mudam velocidade e ritmo, sem frames anatômicos novos. Camadas novas são editáveis e estilizadas; precisam de refinamento artístico futuro. Jonas e partes PixelLab previamente existentes continuam em revisão, sem envio de referências licenciadas ou aprovação automática. A companhia especializa os moradores nomeados existentes e não cria duplicatas deles. Não há novos sistemas políticos nesta versão.
