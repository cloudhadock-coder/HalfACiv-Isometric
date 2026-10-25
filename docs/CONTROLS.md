# Controles v0.2.1

- **WASD**: mover câmera. **Roda**: zoom. **Botão do meio**: arrastar.
- **Clique**: selecionar morador ou prédio. Em construção: colocar no tile indicado.
- **Casas / Alim. / Ofic. / Vila**: categorias. Os botões mostram custo e descrição ao passar o mouse.
- **Esc**: fechar galeria, cancelar ferramenta ou alternar menu. **Espaço**: pausa.
- **1 / 2 / 4** ou botões no rodapé: velocidade de simulação.
- **F5 / Salvar**: gravar campanha. **Carregar**: recuperar e aplicar offline limitado.
- **Seletor de ofício**: redistribuir profissão do morador selecionado; nome e aparência são preservados.
- **Habitantes e retratos**: abrir galeria; clicar em um retrato inspeciona aquela pessoa.
- **↶ no inspetor**: voltar ao resumo da aldeia.

O pesqueiro exige margem de água. Prédios produtivos precisam de trabalhadores compatíveis e de acesso. O resultado fica no posto até a entrega; confira insumos e estoque no inspetor. Casas com vagas atraem moradores se houver alimento. O sono ocorre no acesso da casa, sem interiores nesta versão.

Novo domínio inicia uma comunidade em memória. O arquivo anterior permanece até o próximo salvar/autosave. Saves antigos recebem backup permanente `.v0.1.bak` ao serem regravados.


**B / I** ou as setas: recolher/expandir construção e informações. A câmera considera a área útil restante. A roda usa passos de zoom 1/1,5/2/3/4, preservando o ponto do cursor quando os limites permitem. O mínimo é ajustado ao viewport; 2× é o padrão. Ao inspecionar os cantos, o contorno do tabuleiro e o fundo de mesa são intencionais.

## Menu e barra de menus

- **Menu principal:** Enter executa a primeira opção (Continuar), N novo mundo aleatório, P personalizar mundo, V mapa clássico, Q sair. No jogo, Esc abre a pausa (Esc volta, F5 salva, L carrega).
- **Personalizar mundo:** nome, semente (número ou palavra), paisagem e recursos, com prévia ao vivo. Enter funda, Esc volta.
- **Barra de menus:** Jogo, Aldeia, Ver, Conselheiros e Ajuda. Cada item mostra o atalho. **C** centraliza a praça.
- **Minimapa** (coluna direita): clique ou arraste para mover a câmera. **I** recolhe a coluna inteira.

Detalhes em [INTERFACE.md](INTERFACE.md).

## Interface (inspirada no Civ2-UI-Additions)

- **Clique do meio** sem arrastar: centraliza o mapa no ponto. **Ctrl + clique do meio**: volta ao zoom 2×.
- **Ctrl** sobre um morador ou prédio: ficha rápida com estado, vigor, posto, carga e produção.
- **Shift**: rota do morador selecionado; com um prédio selecionado, ligações até a equipe; sem seleção, todas as rotas de carga.
- **H** ou **Registro da aldeia**: abas Retratos, Moradores, Edifícios e Mensagens. Os botões de ordenação invertem a ordem no segundo clique. Clicar numa linha seleciona e centraliza.
- Avisos aparecem sobre o mapa e somem sozinhos; o histórico fica em Mensagens. A barra superior mostra a tendência de cada recurso por hora de jogo. Obras que não dá para pagar ficam esmaecidas, e a dica mostra o que falta.

Detalhes e mapeamento em [UI_ADDITIONS.md](UI_ADDITIONS.md).

## Companhia v0.3.0

R abre/fecha contratos e cavalaria. Para equipar, selecione o cavaleiro ou cavalo no mapa, abra R e escolha Cavalaria e heráldica. F5 grava contratos, pelagem, cor, barda, estandarte e ritmo. Escape fecha a companhia antes de pausar.
