# Validação v0.4.1 — recuperação do plano original

## Base e escopo
Git limpo no início; base publicada v0.4.0, commit `f1d3875`. Foram preservados interface 4X, minimapa, registro, atalhos, menus, iconografia, mundos por semente, economia, construção, rotinas, cavalaria e retratos. Não houve criação ou alteração de sprites/retratos, nem promoção de partes em revisão.

| Requisito original da etapa política | Implementação |
|---|---|
| Quatro facções | Camponeses, Guildas, Clero, Nobreza; apoio 0–100 |
| Conselho e decisões | Cinco propostas com custos, efeitos e restrição de uma decisão por dia |
| Reformas | Quatro reformas permanentes com efeitos econômicos verificáveis |
| Legitimidade | Estado persistente, ganhos/perdas por decisões e requisitos de promoção |
| Evolução da aldeia | Aldeia, Vila, Cidade Livre, Principado, Reino; critérios e confirmação |
| Offline limitado | Reformas aprovadas afetam a aproximação econômica; nenhuma escolha política automática |

Regras e números completos em POLITICS.md. O título de domínio não altera automaticamente a arte dos prédios. Não foram introduzidas guerras, diplomacia externa ou expansão territorial.

## Testes executados

| Suíte | Resultado observado |
|---|---|
| `tests/politics_tests.gd` com OpenGL | 54 verificações, zero falhas |
| `tests/realm_campaign.gd` headless | Reino alcançado sem injeção de recursos, população ou apoio |
| `tests/test_runner.gd` | 21.235 asserções, zero falhas; inclui economia, obras, saves e 90 sementes |
| `tests/visual_tests.gd` headless | 22.470 asserções, zero falhas |
| `tests/integration.gd` | 38 asserções, zero falhas |
| `tests/visual_validation.gd -- --no-save` | 1.855 checks GPU, zero falhas; 324 pixels de oclusão e 1.503 de NPC à frente |
| `tests/company_tests.gd -- --no-save` | 24 verificações, zero falhas |
| `tests/interface_capture.gd -- --no-save` | zero falhas em menus, mundos e layout |
| `tests/ui_additions_capture.gd -- --no-save` | zero falhas no registro, rotas e fichas rápidas |
| `tests/portrait_ui_capture.gd -- --no-save` | 3 verificações pixel-exatas em 720p/1080p, zero falhas |
| `python tests/test_assets.py` | 13 testes aprovados |
| `python tests/test_cavalry.py` | 3 testes aprovados |
| validadores de retratos/kit | sem erros técnicos; 24 retratos e 19 partes ainda pendentes de revisão |

A suíte política verifica débitos/recompensas exatos, prévia dos efeitos, duplicação, falta de recursos, cooldown após reload, limites de apoio/legitimidade, reformas e gates, multiplicadores reais online/offline, neutralidade de saves antigos, mundos por semente, carregamento atômico, histórico limitado, clique real do mouse em uma decisão, promoção via UI, requisitos atualizados com os recursos e layout em três resoluções.

A campanha automatizada usa apenas `build`, `decide`, `enact`, `promote`, `tick` e `apply_offline`, partindo dos recursos normais. Em 26 ciclos de 240s offline + 20s online (último ciclo termina na promoção), chegou a Reino com 48 moradores, legitimidade 100 e quatro reformas. É um teste de alcançabilidade das regras, não uma alegação de duração ideal de campanha ou teste humano completo de balanceamento.

Save pessoal real v0.4.0, schema 2: 25 entidades e 22 construções carregadas; hash do arquivo original inalterado. Política neutra adicionada apenas na instância em memória; fonte não regravada. Dados de resultado em visual-validation/v0.4.1/existing-save.json, sem publicar o conteúdo do save.

## Validação visual real
Capturas do viewport Godot em `visual-validation/v0.4.1/`: Council.png, Reforms.png, Progression.png, Chronicle.png, Council_960x540.png, Council_1080p.png, Kingdom_Fixture.png e Existing_Save.png. Foram inspecionadas visualmente. O painel usa o tema existente e scroll, mostrando apoio, legitimidade, custos, efeitos e pendências.

Foi detectado um crescimento indevido da primeira abertura: o texto quebrava antes de ter largura definida e a janela ficava maior que o viewport. Corrigido definindo a largura dos rótulos antes do texto; acrescido teste da primeira abertura. Requisitos e botões recebem atualização uma vez por segundo sem recriar as listas ou perder a rolagem.

Kingdom_Fixture é um cenário desenvolvido controlado, explicitamente montado para inspecionar o estágio final; não é apresentado como captura de campanha humana. O teste separado realm_campaign comprova a alcançabilidade sem injeções. Nenhuma screenshot foi inventada.

## Performance
Godot 4.7.2/OpenGL, RX 580 2048SP, VSync desativado, 360 frames, 64 cavaleiros com todas as camadas e mais um cavalo: média **115,7 FPS**, p95 **10,128 ms**, amostra de **1.441 draw calls**, memória estática da engine **46,6 MB**. Não mede RSS/VRAM e não garante o mesmo resultado em outro hardware. Sem alegação de ganho causal entre versões. Painel político atualiza prontidão uma vez por segundo; não há simulação política por frame.

## Build e publicação
O pipeline repete as suítes no commit marcado, exporta Windows, executa o EXE headless e em OpenGL, confirma companhia e decisão real do conselho no binário e valida o ZIP. BUILD_INFO.json registra versão, commit e hash do executável. A confirmação remota da Release/tag e do hash do anexo consta no relatório final e em PUBLICATION.json no diretório local dist, não é presumida por este texto.

## Limitações
Balanceamento político inicial; sem declínio passivo de apoio, revoltas, diplomacia ou guerras. Promoções mudam status e acesso a reformas, sem novos sprites de cidade. Cavalaria e retratos mantêm as pendências anteriores. ResourceWarnings de fechamento de imagens nos testes Python antigos de UI/ícone não indicam falha do jogo nem falha de teste; nenhuma delas foi ocultada nos logs.
