# Changelog

## v0.4.1 — Política e progressão do plano original

- Quatro facções com apoio e legitimidade de 0 a 100.
- Conselho [P] com cinco decisões, custos e efeitos apresentados, uma deliberação por dia e histórico persistente.
- Quatro reformas permanentes com bônus reais de alimento, ouro, influência ou tributos, online e offline.
- Evolução explícita Aldeia → Vila → Cidade Livre → Principado → Reino, com requisitos, custos e confirmação.
- Save schema 2 compatível: política opcional com defaults neutros para saves antigos, validação atômica e cooldown preservado.
- Indicadores políticos na interface existente e janela adaptável com requisitos atualizados sem perder scroll.
- Testes de decisões, reformas, economia, progresso, saves, campanha automatizada sem injeção de recursos e capturas reais.
- Preservados menu, minimapa, registro, mundos por semente e demais recursos da v0.4.0.



## v0.4.0 — Interface, menu e mundos por semente

- Ícone do jogo desenhado à mão (16 e 32 px, ampliações inteiras até 256 px) em `assets/icon/`, gerado por `tools/ui_pipeline/build_icon.py`, aplicado ao executável e à janela.
- O clique do meio passa a distinguir clique de arrasto pela distância entre pressionar e soltar, não pelo movimento acumulado.
- `build_release.py` e o benchmark passaram a usar a versão do projeto, sem caminhos fixos da v0.3.0.

- Disposição dos 4X clássicos: barra de menus (Jogo, Aldeia, Ver, Conselheiros, Ajuda), coluna direita com minimapa clicável, status (recursos com ícones e tendência) e informações da seleção, e construção como janela flutuante.
- Molduras em pixel art com chanfro e ícones de recurso 12×12 em `assets/ui/`, gerados por `tools/ui_pipeline/build_ui.py`. São substituíveis por arte à mão sem mudar código. Tema central em `src/ui/ui_theme.gd`.
- O HUD fica em escala inteira de pixels de tela (1:1 em 1080p, 2× em 1440p).
- Menu principal com cartão do save, atalhos para todas as ações, novo mundo aleatório em um clique, mapa clássico e menu de pausa. Tela "Personalizar mundo" com nome, semente (número ou palavra), paisagem, recursos e prévia ao vivo.
- Geração de mundo por semente (`src/world/world_gen.gd`): lagos, rio ou costa, florestas, estradas e vila inicial distribuída com acesso garantido. O save guarda as opções do mundo; saves antigos continuam no mapa clássico (esquema 2).
- Painel de ajuda com os controles, tecla C para centralizar a praça e rotas fixáveis pelo menu Ver.
- Testes: 90 sementes verificadas por execução, determinismo, salvar e carregar, opções inválidas, tamanhos e reprodutibilidade das peças de UI, além de capturas em `docs/visual-validation/interface/`. Veja `docs/INTERFACE.md`.

### Interface inspirada no Civ2-UI-Additions (incluída na v0.4.0)

- Registro da aldeia [H] com abas Retratos, Moradores, Edifícios e Mensagens, ordenáveis e com totais. Clicar seleciona e centraliza.
- Ficha rápida com Ctrl sobre moradores e prédios. Shift traça rotas (selecionado, equipe do prédio ou todas as cargas).
- Clique do meio centraliza o mapa; Ctrl+meio volta ao zoom 2×.
- Estados com cores de atitude, tendência de recursos por hora, avisos sobrepostos ao mapa com histórico, obras sem recursos esmaecidas com o que falta e período do dia no rodapé.
- Só as ideias vieram do [Civ2-UI-Additions](https://github.com/FoxAhead/Civ2-UI-Additions) (MIT); nenhum código foi reutilizado. Veja `docs/UI_ADDITIONS.md`.
- Testes novos de lógica e integração, e capturas em `docs/visual-validation/ui-additions/`. Retratos, arte e formato de save não mudaram.

## v0.3.0 — Cavalaria e personagens

- Companhia do Vale [R]: quatro contratos únicos para especialistas, com custo, condições e bônus funcionais.
- Cavalo: cinco pelagens, seis mantas heráldicas, barda, capacete/escudo do cavaleiro e estandarte em camadas nativas.
- Seletor de ritmo montado e sincronização com o cavaleiro; os três ritmos reutilizam a animação lateral existente.
- Contratos e equipamentos persistem no schema 2, com valores padrão para saves anteriores e validação atômica.
- Integrado o trabalho local prévio do kit de retratos: receitas persistentes e fallback até a aprovação humana das partes.
- Testes de contratação, custo, bônus, navegação, UI, equipamentos, compatibilidade e assets determinísticos; capturas reais em 720p e 540p.
- Mantidas as correções visuais de câmera, profundidade e tiles da v0.2.1.

Limitações: sem combate, oito direções ou ciclos anatômicos independentes de trote/galope. Retratos finais e partes do kit continuam em revisão; nenhuma arte foi promovida automaticamente.

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
