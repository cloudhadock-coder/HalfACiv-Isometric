# HalfACiv Isometric v0.4.1 — Política e progressão

Recupera o escopo originalmente previsto para a v0.4.0 e mantém suas melhorias de interface, minimapa, registro e mundos por semente.

## Incluído
- Camponeses, Guildas, Clero e Nobreza, com apoio e legitimidade de 0 a 100.
- Conselho [P] com cinco decisões, prévia dos custos/efeitos, uma decisão por dia e crônicas persistentes.
- Quatro reformas com bônus reais na produção ou nos tributos, aplicados online e offline.
- Aldeia → Vila → Cidade Livre → Principado → Reino: evolução confirmada pelo jogador, com população, moradia, edifícios, apoio, legitimidade e recursos como requisitos.
- Persistência opcional compatível com schema 2; saves anteriores iniciam política neutra. Nenhum evento, decisão ou promoção é inventado offline.
- Testes de política, economia, progressão e saves, além de campanha automatizada usando apenas ações reais e passagem do tempo.

## Executar
Extraia o ZIP e abra HalfACiv-Isometric.exe no Windows 10/11 x64. Salve/feche a versão antiga e use Carregar domínio. P na campanha ou Conselheiros → Conselho do domínio; F5 salva; Esc fecha a janela. Para pausar, feche as janelas e pressione Espaço. O conselho permanece em tempo real e não pausa a economia. P no menu principal continua abrindo Personalizar mundo. Custos e condições estão na própria janela e em docs/POLITICS.md no repositório.

## Validação
Suítes, commit, hashes e benchmark constam em BUILD_INFO.json. O pipeline repete testes no commit marcado, exporta Windows, executa EXE em headless/OpenGL e verifica a companhia e o conselho. Capturas reais em docs/visual-validation/v0.4.1; resultados em docs/VALIDATION_V0.4.1.md. Save real da v0.4.0 carregado com hash original preservado.

## Limitações
Balanceamento inicial de política. Não inclui guerras, diplomacia externa, revoltas, novos territórios ou sprites diferentes de cidade por estágio. Cavalaria ainda lateral, com ritmos reutilizados; retratos e partes do kit continuam em revisão. Nenhuma arte foi promovida. A v0.5.0 continua dedicada à expansão territorial.

## Créditos
GandalfHardcore Character Asset Pack incorporado ao jogo, sem assets licenciados soltos. Tiles crabcrabcrabs, CC BY 4.0: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles . Godot 4.7.2/MIT; licenças e atribuições no ZIP. Nenhuma referência licenciada foi enviada a IA nesta versão.

Commit testado: `{{COMMIT}}`.
