# Pipeline de retratos

Processamento e validação de retratos já desenhados. **Não cria arte.** Os rostos são desenhados à mão segundo [docs/PORTRAIT_ART_STYLE_GUIDE.md](../../docs/PORTRAIT_ART_STYLE_GUIDE.md). Requer Pillow (`tools/python_libs` ou `pip install Pillow`).

```text
assets/portraits/
├── portraits.json     manifesto: NPC ↔ retrato, identidade, status, revisão (lido pelo jogo)
├── 0.png … 23.png     retratos v0.2 preservados: fallback legado (96×112)
├── source/            desenhos originais copiados intactos pelo stage
├── generated/         versões nativas em revisão + portrait_atlas.png/.json
├── approved/          arte final promovida (64×64) usada pelo jogo
└── thumbnails/        janelas 64×64 de cada retrato resolvido, sem reamostragem
```

`source/`, `generated/` e `thumbnails/` têm `.gdignore` e não entram no build. Status: `legacy_placeholder` → `in_review` → `approved`. O jogo (`src/ui/portrait_registry.gd`) usa `approved/` apenas quando o status é `approved`; nos demais casos, usa o fallback.

## Comandos

| Comando | Faz |
|---|---|
| `python tools/portrait_pipeline/validate.py` | valida o manifesto (ids 0..N-1, campos, status), arquivos ausentes, tamanhos, alfa binário, linha do topo livre, 12–48 cores, arte não ampliada, silhueta mínima, duplicatas, órfãos, revisão registrada e hash das referências. Com `--require-final`, também falha se houver pendentes |
| `python tools/portrait_pipeline/export.py stage <id> desenho.png [--force]` | copia o original para `source/`, reduz uma ampliação inteira (2×, 3×…) por amostragem de blocos, sem perda, e grava `generated/<id>.png` com status `in_review`. Rejeita escala fracionária, tamanho errado, alfa parcial e excesso de cores |
| `python tools/portrait_pipeline/export.py promote <id> --by NOME --notes "…" [--ai-tool FERRAMENTA]` | copia para `approved/`, marca `approved` e registra revisor, data, notas e, se houver, a ferramenta de IA do rascunho |
| `python tools/portrait_pipeline/prompts.py` | gera `docs/PORTRAIT_PROMPTS.md`: um prompt de rascunho por NPC, a partir da identidade e do `prompt_brief` do manifesto |
| `python tools/portrait_pipeline/generate_atlas.py` | gera miniaturas, `generated/portrait_atlas.png/.json`, `docs/portrait-validation/portrait-gallery.png` e, se as referências locais existirem, `docs/portrait-validation/local/reference-comparison.png` |

## Kit de partes (gerador de personagens no jogo)

```text
assets/portraits/kit/
├── kit.json      slots, rampas (ramp_source/ramp_size), presets de cor, partes, materiais e tabelas de recoloração
├── parts/        camadas 64×64 alinhadas, usadas pelo jogo quando approved
└── source/       originais intactos e máscaras de inpaint (.gdignore)
```

| Comando | Faz |
|---|---|
| `python tools/portrait_pipeline/kit.py add <id> head <img> [--dx N --dy N]` | nova cabeça, só deslocada por pixels inteiros para o enquadramento comum |
| `python tools/portrait_pipeline/kit.py add <id> <hair\|beard\|clothing\|hat> <img> --base <cabeça> [--mask m.png] [--fits a,b]` | sobreposição desenhada sobre uma cabeça do kit: guarda só os pixels alterados (dentro da máscara) |
| `python tools/portrait_pipeline/kit.py bake` | recalcula as tabelas de recoloração depois de editar materiais, âncoras, rampas ou presets |
| `python tools/portrait_pipeline/kit.py promote <id> --by NOME --notes "…"` | aprova a parte depois da revisão visual |
| `python tools/portrait_pipeline/kit.py validate` | arquivos, materiais, tabelas atualizadas, `fits` e portão de retrato final em 64 combinações aprovadas |
| `python tools/portrait_pipeline/kit.py preview` | `docs/portrait-validation/kit-preview.png`: todas as partes e 24 combinações (inclui as em revisão) |

Os materiais (`skin`, `hair`, `cloth`) são um primeiro palpite do `add`. Quem revisa confere e corrige as listas no `kit.json` e depois roda `bake`. No jogo, `src/ui/portrait_kit.gd` compõe a receita gravada no save de cada imigrante (`Citizen.appearance`). Enquanto alguma parte da receita não estiver aprovada, aparece o retrato de fallback.

## Adicionar um personagem

1. Acrescente uma entrada ao final de `portraits.json`, com o próximo id, a identidade completa (incluindo `clothing_color` e `prompt_brief`), `status: legacy_placeholder` e um `fallback` existente. O id é o `portrait_id` do NPC e não pode mudar depois que saves existirem. Hoje o save aceita ids de 0 a 23 (`src/persistence/save_store.gd`); amplie esse limite junto.
2. Desenhe o retrato em 64×64 seguindo o guia, faça o `stage`, regenere a galeria, revise e use `promote`.
3. Rode `validate.py` e `python tests/test_assets.py`, reimporte no Godot e faça o commit de `approved/<id>.png` com o `.import` dele.

Testes: `tests/test_assets.py` (manifesto, atlas determinístico, stage/promote e rejeições) e `tests/portrait_ui_capture.gd` (retrato pixel a pixel idêntico na tela em 720p e 1080p).
