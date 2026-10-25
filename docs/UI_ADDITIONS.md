# Melhorias de interface inspiradas no Civ2-UI-Additions

O [Civ2-UI-Additions](https://github.com/FoxAhead/Civ2-UI-Additions) (MIT, FoxAhead) é um patch em Delphi injetado no `CIV2.EXE` do Civilization II. **Não usamos nenhum código dele:** a engine e a linguagem são outras. Adotamos as ideias de interface que fazem sentido numa aldeia isométrica e as reescrevemos em GDScript.

| Civ2-UI-Additions | HalfACiv Isometric | Onde |
|---|---|---|
| Clique do meio centraliza o mapa; Ctrl+meio volta ao zoom normal | Clique do meio sem arrastar centraliza no ponto; Ctrl+meio volta ao zoom 2× | `src/core/game.gd` |
| Quickinfo ao segurar Ctrl sobre cidade ou unidade | Ficha flutuante ao segurar Ctrl sobre morador ou edifício | `src/ui/quick_info.gd`, `village_ledger.gd` |
| Shift desenha caminhos e rotas comerciais | Shift desenha a rota do morador selecionado, as ligações de equipe do edifício selecionado ou, sem seleção, todas as rotas de carga | `src/rendering/world_view.gd` |
| City Status e lista de unidades ordenáveis, com total e clique para abrir | **Registro da aldeia [H]**: abas Retratos, Moradores, Edifícios e Mensagens, ordenáveis e com totais; clicar seleciona e centraliza | `src/ui/hud.gd`, `village_ledger.gd` |
| Cores de atitude no texto dos cidadãos | Estados coloridos: trabalho (verde), deslocamento (azul), descanso (cinza), problema (laranja) | `village_ledger.gd` |
| Números de pesquisa no conselheiro de ciência | Tendência de cada recurso por hora de jogo na caixa de status | `village_ledger.gd` |
| Popups no overlay do mapa, sem clicar OK | Avisos empilhados sobre o mapa, que somem sozinhos; o histórico fica na aba Mensagens | `src/ui/message_log.gd` |
| Change Production com custo e Cancelar/Esc | Obras que não dá para pagar ficam esmaecidas e a dica mostra o que falta; categoria ativa destacada | `src/ui/hud.gd` |
| Barra lateral com o turno atual | Caixa de status na coluna direita e barra de menus com dia, hora e período (Trabalho / Refeição / Descanso). A disposição completa está em [INTERFACE.md](INTERFACE.md) | `src/ui/hud.gd` |
| Esc fecha a janela em foco antes do conselheiro | Esc fecha companhia, registro e ferramenta antes de pausar; H reabre o registro na mesma aba e ordem | `src/core/game.gd` |

## Não adotado

- **Patches de executável, CD, multiplayer, limites de unidades e correções de bugs do Civ2:** não se aplicam.
- **Ações em massa** (especialistas, movimento de pilhas, sentinela): a aldeia não tem unidades controladas diretamente.
- **Janelas redimensionáveis e correção de cor:** ficam para um menu de configurações, que ainda não existe.
- **Contadores de trabalho sobre colonos:** as obras já mostram a barra de progresso, e a porcentagem aparece no registro e na ficha Ctrl.

## Validação

- `tests/test_runner.gd`: ordenação estável, cores de estado, períodos do dia, texto do que falta para construir, situação dos edifícios e janela de tendência.
- `tests/integration.gd`: abas do registro, seleção por linha (morador e edifício), avisos e histórico, ficha Ctrl, centralização com o botão do meio e Ctrl+meio.
- `tests/ui_additions_capture.gd`: capturas reais em 1280×720 em [`visual-validation/ui-additions/`](visual-validation/ui-additions/).

Os retratos continuam sendo exibidos só por `PortraitView`, em escala inteira (verificação pixel a pixel em `tests/portrait_ui_capture.gd`). Nenhuma arte foi alterada.
