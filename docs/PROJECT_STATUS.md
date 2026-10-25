# Status — v0.3.0

Cavalaria e personagens implementados; validação e publicação registradas no relatório final e em VALIDATION_V0.3.0.md. Base: v0.2.2 publicada, incluindo integralmente o trabalho local de retratos encontrado sem commit no início desta sessão.

Entregue: quatro contratos únicos com bônus, pelagens e heráldica em camadas, barda/equipamento, ritmos e persistência. Pendentes artísticos: oito direções, trote/galope anatômicos, refinamento manual das montarias e aprovação humana dos retratos/partes. Nenhum rascunho foi promovido.

O registro abaixo preserva o histórico do trabalho local anterior. A descrição "sem commit" nesse registro é histórica; esses arquivos integram o commit da v0.3.0.

---

# Status do projeto — 2026-10-25

## Em que etapa estamos

| Versão | Tema | Situação |
|---|---|---|
| v0.1.0 | Fundação: mapa, câmera, construção, economia inicial, NPCs, montaria e saves | publicada |
| v0.2.0 | Vida na aldeia: 24 ofícios, rotinas, logística, 18 construções, retratos e interface | publicada |
| v0.2.1 | Correções visuais: câmera, profundidade, superfícies dos tiles e pixel art | publicada |
| v0.2.2 | Padrão oficial de retratos: guia de estilo, auditoria, pipeline e exibição pixel-exata | publicada (versão atual em `project.godot`, commit `1acf83d`) |
| **pós-v0.2.2** | **Retratos com PixelLab e kit de partes (gerador de personagens no jogo)** | **em andamento, sem commit**, descrito abaixo |
| v0.3.0 | Cavalaria e personagens: armaduras, equipamentos, heráldica, recrutamento e retratos mais fiéis | próxima no [roadmap](ROADMAP.md) |
| v0.4.0 | Política e progressão | planejada |
| v0.5.0 | Expansão territorial | planejada |

O trabalho atual antecipa parte da v0.3.0 (personagens e retratos). Ele pode virar uma v0.2.3 ou entrar na v0.3.0. Antes de qualquer release ainda faltam a revisão humana da arte, o commit, a tag, o build e a publicação ([regras do roadmap](ROADMAP.md)).

Situação dos retratos: dos 24 NPCs nomeados, 1 tem rascunho em revisão (#9 Jonas) e 23 continuam com o retrato antigo (`legacy_placeholder`). Nenhum retrato nem parte do kit foi aprovado, então **o jogo ainda mostra só os retratos antigos**.

## O que foi feito nesta etapa

Tudo foi gerado no PixelLab **só com prompts de texto**. As referências oficiais não foram enviadas, como exige o [AGENTS.md](../AGENTS.md). A conta era um trial de 40 gerações, e todas foram usadas:

| Uso | Gerações |
|---|---|
| Jonas (modelo Pro, 16 candidatos) | 10 |
| Teste do modelo barato (pixflux), descartado: saiu de perfil, com ruído e roupa moderna | 1 |
| Kit: base careca neutra (Pro, 16 candidatos) | 10 |
| Kit: inpaint de cabelo, barba e roupa (5 cada) | 15 |
| Kit: cabeça feminina | não gerada (trial esgotado) |

### Retrato do Jonas (#9)

- Escolhido 1 de 16 candidatos: coroa com gema vermelha, barba ruiva com fios grisalhos e têmporas grisalhas.
- Arquivo: `assets/portraits/generated/9.png`, status `in_review`. O original intacto está em `assets/portraits/source/9_jonas.png`.
- Falta a limpeza manual da [seção 13 do guia](PORTRAIT_ART_STYLE_GUIDE.md#13-rascunhos-gerados-por-ia). O rascunho tem 45 cores; o validador aceita até 48, e o guia mira em 30–44.
- Para aprovar depois da limpeza:

  ```text
  python tools/portrait_pipeline/export.py promote 9 --by "NOME" --notes "…" --ai-tool PixelLab
  ```

### Kit de partes (gerador de personagens)

Galeria: [kit-preview.png](portrait-validation/kit-preview.png), com as partes e 24 combinações de exemplo.

- **19 partes:** 16 cabeças masculinas carecas (jovens, velhos, sérios), `hair_short`, `beard_full` e `clothing_jerkin`.
- **Encaixe exato:** cabelo, barba e roupa foram pintados por inpaint com máscara sobre `head_09`. O PixelLab preservou exatamente os pixels fora da máscara, então as camadas encaixam pixel a pixel. Cabelo e barba foram conferidos nas 16 cabeças.
- **Cores:** pele, cabelo e roupa trocam de cor usando as cores de identidade de `portraits.json`, com rampas fixas de 7, 5 e 4 tons. As combinações ficam entre 18 e 47 cores, dentro do limite de 48. As tabelas de cor são calculadas antes, por `kit.py bake`, e o jogo só as consulta.
- **No jogo:** o compositor está em `src/ui/portrait_kit.gd`. Cada imigrante além dos 24 fundadores recebe uma aparência sorteada (`Citizen.appearance`), que fica gravada no save, e o HUD a usa. Só partes aprovadas são combinadas; até lá, o morador mostra o retrato antigo.
- **Ferramenta:** `tools/portrait_pipeline/kit.py`, com os comandos `add`, `bake`, `promote`, `validate` e `preview`. Instruções no [README do pipeline](../tools/portrait_pipeline/README.md).
- **Regra:** a exceção à proibição de "gerar rostos proceduralmente" foi aprovada pelo diretor do projeto e está registrada no AGENTS.md e na [seção 14 do guia](PORTRAIT_ART_STYLE_GUIDE.md#14-kit-de-partes-gerador-de-personagens).

## O que falta

Detalhes em [PORTRAIT_AUDIT.md](PORTRAIT_AUDIT.md#rascunhos-pixellab-2026-10-25).

| Pendência | Como resolver | Custo estimado no PixelLab |
|---|---|---|
| 23 retratos de NPCs | modelo Pro, escolher entre 16 candidatos, limpar, `stage` e `promote` | ~10 gerações por NPC (~230 no total) |
| Cabeça feminina | inpaint sobre `head_09` (a máscara está em `assets/portraits/kit/source/head_female_mask.png`) | 5 |
| Cabelos longos, chapéus e outras roupas | inpaint sobre `head_09` | 5 cada |
| `clothing_jerkin` cobre só 6 das 16 cabeças | estender a camada à mão para cobrir a túnica das outras 10 (vazamento de 10 a 65 px) | 0 |
| Preset de cabelo branco `#d9d4cc` puxa para o rosa e o laranja | ajustar a rampa ou trocar o preset no `kit.json` e rodar `bake` | 0 |
| Revisão das 19 partes do kit e do Jonas | revisão humana na galeria e `promote` | 0 |
| Release | commit, tag, build e publicação | 0 |

## Testes

Todos passaram:

| Suíte | Resultado |
|---|---|
| `tests/test_runner.gd` | 21118 asserções, 0 falhas |
| `tests/integration.gd` | 27 asserções, 0 falhas |
| `tests/portrait_ui_capture.gd` | 3 verificações, 0 falhas |
| `tests/visual_tests.gd` | 22482 asserções, 0 falhas |
| `tests/test_assets.py` | 11 testes OK |
| `validate.py` / `kit.py validate` | sem erros |

O mesmo retrato montado pelo Python e pelo jogo dá o mesmo hash, byte a byte.

## Arquivos alterados (sem commit)

- Novos: `src/ui/portrait_kit.gd`, `tools/portrait_pipeline/kit.py`, `assets/portraits/kit/`, `assets/portraits/generated/9.png`, `assets/portraits/source/9_jonas.png`, `docs/portrait-validation/kit-preview.png` e este arquivo.
- Alterados: `src/entities/citizen.gd`, `src/economy/simulation.gd`, `src/persistence/save_store.gd`, `src/ui/hud.gd`, `src/ui/portrait_registry.gd`, `tests/test_runner.gd`, `tests/test_assets.py`, `assets/portraits/portraits.json`, `AGENTS.md`, `docs/PORTRAIT_ART_STYLE_GUIDE.md`, `docs/PORTRAIT_AUDIT.md` e `tools/portrait_pipeline/README.md`.
- Também ficaram sem commit as mudanças de antes desta sessão: `docs/PORTRAIT_PROMPTS.md`, `tools/portrait_pipeline/prompts.py` e `export.py`.
