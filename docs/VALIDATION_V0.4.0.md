# Validação v0.4.0

Ambiente: Windows 11, Godot 4.7.2-stable, OpenGL 3.3 (AMD Radeon RX 580 2048SP).

| Suíte | Resultado |
|---|---|
| `tests/test_runner.gd` (lógica, saves, 90 sementes de mundo) | 21.235 verificações, 0 falhas |
| `tests/integration.gd` (entrada real, registro, ficha Ctrl, clique do meio) | 38 verificações, 0 falhas; 5 execuções seguidas sem falha após a correção do clique do meio |
| `tests/visual_tests.gd` (câmera e geometria) | 22.470 verificações, 0 falhas |
| `tests/visual_validation.gd` (GPU e profundidade) | 1.855 verificações, 0 falhas |
| `tests/company_tests.gd` | 24 verificações, 0 falhas |
| `tests/portrait_ui_capture.gd` (retratos pixel-exatos, 720p e 1080p) | 3 verificações, 0 falhas |
| `tests/interface_capture.gd` (menus, HUD em 720p/1080p/540p, paisagens) | 0 falhas |
| `tests/ui_additions_capture.gd` | 0 falhas |
| `tests/test_assets.py` (inclui molduras da UI e ícone) | 13 testes, OK |
| `tests/test_cavalry.py`, `kit.py validate`, `portrait_pipeline/validate.py` | OK, KIT_OK, PORTRAITS_OK (24 pendentes de arte) |

As contagens de `visual_tests` (22.482 → 22.470) e `visual_validation` (1.873 → 1.855) caíram porque a área útil do mapa mudou de formato com a nova disposição. Nenhuma verificação foi removida.

## Desempenho

`benchmark.gd` com 64 moradores montados: 123 fps em média, p95 de 9,1 ms, 1.441 chamadas de desenho ([benchmark.json](visual-validation/v0.4.0/benchmark.json)). Na v0.3.0: 128 fps, p95 de 8,8 ms, 1.400 chamadas. O minimapa grava o terreno numa textura uma vez por mundo. Desenhá-lo célula a célula derrubava o benchmark para 67 fps.

## Inspeção visual

Capturas em [`visual-validation/interface/`](visual-validation/interface/), inspecionadas uma a uma:
- menu inicial e de pausa;
- tela de novo mundo com prévia;
- aldeia em 720p, 1080p (HUD em 1:1 de pixels de tela) e 540p (escala fracionária, esperado);
- painel de ajuda;
- as três paisagens com a mesma semente.

Problemas encontrados na inspeção e corrigidos antes da versão:
- a coluna direita passava da borda inferior;
- os campos da tela de novo mundo eram estreitos demais;
- em 1080p o HUD ficava em 1,5×.
