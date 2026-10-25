# Política e progressão — v0.4.1

Esta versão recupera o escopo originalmente previsto para a v0.4.0. A interface 4X, o minimapa, o registro e os mundos por semente implementados na v0.4.0 são preservados.

## Conselho [P]
Abra pelo menu Conselheiros → Conselho do domínio ou pressione P durante a campanha. A simulação continua enquanto a janela está aberta. Esc ou Espaço fecha primeiro a janela; sem janelas abertas, Espaço alterna a pausa. Quatro abas: Facções e decisões, Reformas, Evolução e Crônicas. As condições dos botões e as pendências de evolução se atualizam a cada segundo, sem reconstruir a lista nem perder o scroll.

As facções são Camponeses, Guildas, Clero e Nobreza, com apoio de 0 a 100. A legitimidade também vai de 0 a 100. Domínios novos e saves antigos começam em Aldeia, legitimidade 50 e apoio 50 em cada facção. Nada é decidido automaticamente pelo tempo. Há uma deliberação por dia de jogo, para todo o conselho, inclusive após salvar/carregar.

| Decisão | Custo | Apoio (Camponeses / Guildas / Clero / Nobreza) | Legitimidade | Recebe |
|---|---|---|---|---|
| Abrir os celeiros | 40 alimento, 20 ouro | +12 / −4 / +3 / −4 | +5 | 5 influência |
| Encomenda às guildas | 25 madeira, 25 ouro | −3 / +12 / 0 / −5 | +4 | 8 influência |
| Amparar o santuário | 25 alimento, 15 ouro | +3 / −4 / +12 / −3 | +6 | 4 influência |
| Juramento dos nobres | 30 ouro, 5 influência | −6 / −5 / +2 / +14 | +8 | — |
| Tributo extraordinário | 4 influência | −10 / −8 / −3 / +5 | −6 | 45 ouro |

Os efeitos e custos aparecem antes do botão de aprovação. Ações sem recursos, desconhecidas ou repetidas no mesmo dia não debitam nem alteram o estado. Apoio e legitimidade são limitados ao intervalo válido.

## Reformas permanentes

| Reforma | Requisitos | Custo | Efeito |
|---|---|---|---|
| Campos comuns | Vila; Camponeses 55 | 60 madeira, 60 ouro, 20 influência | +15% de alimento produzido; legitimidade +3 |
| Pesos e medidas | Vila; Guildas 55 | 35 pedra, 80 ouro, 25 influência | +15% de ouro nos postos; legitimidade +3 |
| Escolas paroquiais | Cidade Livre; Clero 55 | 45 madeira, 100 ouro, 30 influência | +20% de influência nos postos; legitimidade +5 |
| Assembleia dos estamentos | Cidade Livre; Nobreza 55 | 50 pedra, 120 ouro, 35 influência | +10% de tributos populacionais; +5 de apoio às quatro facções; legitimidade +5 |

Cada reforma só é paga uma vez. Bônus de produção melhoram os produtos, mantendo os insumos existentes. Somam-se de forma multiplicativa ao bônus dos especialistas da v0.3.0. Pesos e medidas afeta a produção de ouro nos postos; só Assembleia afeta os tributos por população. Efeitos também funcionam na aproximação econômica offline já existente, limitada a duas horas. A influência das patrulhas recebe o bônus paroquial tanto online quanto offline.

## Evolução explícita
Todas as etapas exigem moradia para a população atual e prédios concluídos. A promoção cobra o custo uma vez, exige clique e nunca pula etapa. O título é permanente; não bloqueia o acesso anterior às construções, à companhia ou aos mundos. Vila e Cidade Livre liberam as reformas correspondentes. Não há novos sprites de cidade ou mudança automática do mapa ao promover.

| Próximo estágio | População | Legitimidade | Apoio mínimo de cada facção | Edifícios | Custo |
|---|---:|---:|---:|---|---|
| Vila | 24 | 55 | 40 | Feira | 80 ouro, 15 influência |
| Cidade Livre | 32 | 60 | 45 | Feira, Capela, Depósito | 160 ouro, 40 influência |
| Principado | 40 | 70 | 45 | Capela, Forja, Torre | 300 ouro, 80 influência |
| Reino | 48 | 80 | 50 | Capela, Feira, Quartel; 3 reformas | 500 ouro, 140 influência |

## Salvamento e arquitetura
`src/politics/realm.gd` concentra regras e estado, sem depender da UI ou de frames. `src/ui/council_panel.gd` apresenta custos, efeitos, requisitos e histórico das últimas 40 ações. Economia aplica multiplicadores apenas quando a reforma foi aprovada.

O schema continua 2. O campo opcional `politics` guarda estágio, legitimidade, apoio, reformas, último dia deliberado e histórico. Saves anteriores usam valores neutros; nenhuma decisão passada é inventada. Validação rejeita tipos, números não finitos, apoio fora da faixa, IDs de reformas inválidos/repetidos ou de estágio futuro e datas posteriores ao mundo salvo. O estado vivo só recebe o carregamento após validar tudo. Os backups existentes são mantidos.

Offline não muda apoio nem legitimidade, não toma decisões, não promulga reformas e não promove o domínio. O calendário avança, permitindo deliberar novamente quando o jogador retornar em outro dia.

## Escopo e limites
Conclui o núcleo original de quatro facções, conselho, reformas, legitimidade e evolução Aldeia → Reino. Não inclui guerra, diplomacia externa, revoltas, novos territórios ou novos retratos. O balanceamento é inicial e está documentado nesta tabela para ajustes futuros. Cavalaria ainda tem a vista lateral/ciclos reutilizados e os retratos permanecem em revisão. Expansão territorial segue para v0.5.0.
