# Instruções para agentes de programação

Projeto Godot 4.7.2 / GDScript. Testes e build em [README.md](README.md#verificação-e-releases).

## Retratos (regra permanente)

Todo portrait criado ou modificado neste projeto deve seguir obrigatoriamente a direção artística documentada em docs/PORTRAIT_ART_STYLE_GUIDE.md e utilizar as referências oficiais em assets/art_reference/portraits/. É proibido introduzir estilos visuais incompatíveis. Assets novos devem passar por validação antes de serem integrados ao jogo.

Na prática:

- Retratos finais: 64×64 RGBA, desenhados à mão, integrados só por `tools/portrait_pipeline/export.py` (`stage` e depois `promote` com revisor humano). Não gere rostos proceduralmente, não aplique filtros, não converta fotos ou renders, não redimensione de forma fracionária. Rascunhos de ferramentas de IA de pixel art só entram depois da limpeza manual e da revisão da seção 13 do guia, com `--ai-tool` registrado; prompts em `docs/PORTRAIT_PROMPTS.md` (gerados por `tools/portrait_pipeline/prompts.py`). Nunca envie as referências oficiais nem `assets/original/` a ferramentas ou treinamento de IA.
- Se não for possível entregar arte no nível das referências, **mantenha o fallback** (`legacy_placeholder`), registre a pendência em `docs/PORTRAIT_AUDIT.md` e diga isso no relatório. Nunca apresente placeholder como arte final.
- Exceção: o kit de partes (`assets/portraits/kit/`, seção 14 do guia) monta retratos no jogo para moradores gerados, combinando só partes aprovadas uma a uma e recoloridas por rampas gravadas. Cada parte segue as mesmas regras de arte e revisão (`tools/portrait_pipeline/kit.py add` → `promote`). Não acrescente ao kit outra forma de gerar pixels (ruído, interpolação, deformação).
- Todo NPC novo ganha uma entrada em `assets/portraits/portraits.json`, com identidade (sexo, idade, pele, cabelo, roupa, acessório). `portrait_id` indexa esse manifesto e precisa continuar estável por causa dos saves.
- Exiba retratos apenas com `src/ui/portrait_view.gd` (escala inteira de pixels de tela, nearest-neighbor, sem recorte).
- Depois de qualquer mudança: `python tools/portrait_pipeline/validate.py`, `python tools/portrait_pipeline/generate_atlas.py` (galeria e atlas), `python tools/portrait_pipeline/kit.py validate` e `preview` (kit) e `python tests/test_assets.py`. Inspecione a galeria visualmente, porque passar no validador não é aprovação.
- As referências oficiais e `assets/original/` são locais e licenciadas: nunca as adicione ao Git, a releases ou a imagens versionadas.
