# Changelog

## [0.2.2] - 2026-10-25 — Padrão de retratos
### Adicionado
- Direção artística oficial dos retratos (`docs/PORTRAIT_ART_STYLE_GUIDE.md`), baseada em duas folhas de referência analisadas na resolução nativa de 64×64. Referências são locais e ficam fora do Git por licença.
- Auditoria dos 24 retratos (`docs/PORTRAIT_AUDIT.md`): todos classificados como placeholder, com a identidade de cada NPC registrada e o trabalho artístico pendente priorizado.
- Manifesto NPC ↔ retrato (`assets/portraits/portraits.json`) com status `legacy_placeholder`/`in_review`/`approved` e revisão registrada.
- Pipeline `tools/portrait_pipeline/`: validação, stage/promote sem reamostragem, miniaturas, atlas e galeria `docs/portrait-validation/portrait-gallery.png`.
- `AGENTS.md` com a regra permanente de retratos.
### Alterado
- Retratos exibidos por `PortraitView`: maior escala inteira de pixels de tela, nearest-neighbor, centralizado e sem recorte, inclusive sob stretch de janela (1080p). Painel 128×128 e galeria de habitantes em 5 colunas.
- A nota "Retrato em desenvolvimento" passa a depender do status no manifesto.
### Não alterado
- Nenhum retrato novo foi desenhado: os 24 originais seguem como fallback. Sprites do mapa, tilesets, mecânicas e formato de save não mudaram.
### Validação
- 9 testes de assets, 21.111 verificações de lógica, 22.482 de câmera/geometria, 27 de integração, 1.873 GPU e 3 verificações pixel a pixel dos retratos na tela.

## [0.2.1] - 2026-10-24 — Visual Fixes
### Corrigido
- Limites geométricos da câmera, zoom com âncora, acesso aos vértices e arraste liberado sobre a interface.
- Origem dos tiles, máscaras sem furos, extrusões internas e acabamento externo do tabuleiro.
- Profundidade baseada no pé interpolado, sombras no chão e raízes estáveis no vento.
- Escala nativa/pivôs de NPCs e montaria, sombra duplicada e emissores de fogo/fumaça.
- Saltos de posição em construção, troca de profissão e load, sem alterar o formato dos saves.
- Painéis recolhíveis, dimensionamento por categoria e viewport expandido em janelas largas.
### Validação
- 7 testes de assets, 21.111 verificações de lógica, 22.494 de câmera/geometria, 23 de integração e 1.873 verificações GPU aprovados.
- Save real v0.2.0 carregado sem alterar o original; capturas e relatório de bugs em docs/.


## [0.2.0] - 2026-10-24
### Adicionado
- 24 profissões, postos compatíveis com vagas, troca de ofício e identidade individual preservada.
- Rotinas de trabalho, refeição, sono/vigor, patrulha, construção e transporte com entrega efetiva.
- 12 novas construções (18 tipos), receitas com insumos, pesqueiro em margem e imigração por moradia.
- 24 retratos 96×112 e galeria selecionável; ferramentas e cargas visíveis.
- Moinho, bandeiras, árvores, água, fumaça, fogo e iluminação do dia; terreno em cache e paleta revisada.
- Interface por categorias, inspetores de postos/insumos e velocidades 1×/2×/4×.
- Esquema de save 2 com migração v0.1, backup permanente de migração e testes de compatibilidade.
- Scripts reproduzíveis de build/publicação, benchmark e evidências visuais.
### Corrigido
- Obras que poderiam isolar NPCs ou bloquear acessos, inclusive saves com prédio na antiga praça.
- Ordem das identidades ao carregar, seleção após imigração e retrato duplicado detectado em teste.
### Limitações
- Personagens laterais; equipamento completo, novas direções, cavalaria e recrutamento ficam para v0.3.
- Arte de retratos/montaria em desenvolvimento; sem interiores ou colisão entre pessoas.

## [0.1.0] - 2026-10-24
### Adicionado
Projeto Godot isolado, pipeline reproduzivel, mapa isometrico, camera, seis construcoes, economia em ticks, navegacao, personagens compostos, cavalo e montaria, retratos provis?rios, menu, selecao, persistencia e offline limitado.
### Corrigido durante a fundacao
Estradas/agua, escala dos personagens, postura sincronizada de montaria, ocupacao de tiles durante obras e rejeicao de JSON corrompido.
### Limitacoes
Personagens de perfil; portraits e cavalaria provis?rios; recrutamento, politica e evolucao de era planejados para releases futuras. A publicacao remota deve ser confirmada no relatorio final, nao presumida por este arquivo.
