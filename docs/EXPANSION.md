# Expansão territorial — v0.5.0

## Novos mundos
No menu principal, Personalizar mundo permite escolher **32×32, 48×48 ou 64×64**. O mundo aleatório passa a usar 48×48; o mapa clássico permanece 32×32. A prévia e o minimapa usam a dimensão escolhida.

O núcleo original de 32×32 é mantido e centralizado nas dimensões maiores. O gerador determinístico adiciona território exterior com grama, mata, água, terra batida, areia nas margens e solo pedregoso. A geometria interna de um save antigo não é rerrolada. A praça e os pontos de trabalho/patrulha se deslocam junto do núcleo.

## Ampliar um domínio existente
Menu **Aldeia → Ampliar mapa · 150 ouro + 25 influência**. Amplia 32→48 ou 48→64, cobrando uma vez por ação. Sem recursos ou no limite 64×64, não altera estado nem cobra. Não exige nova campanha.

As construções, moradores, casas, postos e destinos são transladados em oito tiles em cada eixo. Os mesmos objetos/identidades e o estado político permanecem; cargas e equipamentos não são descartados. O território conhecido permanece exatamente igual e as edições de estrada são transladadas. A câmera compensa o deslocamento para manter a aldeia no mesmo ponto da tela. A grade de navegação é reconstruída uma vez neste redimensionamento; inicialização e carregamento também montam a grade. Edições locais atualizam apenas o ponto afetado.

## Estradas
- **T** ou Aldeia → Estrada: clique em um tile de solo livre; custa **1 pedra**.
- **Y** ou Aldeia → Remover estrada: clique em uma estrada; vira **terra batida**, sem reembolso.
- Esc cancela a ferramenta. Selecionar uma construção também cancela a ferramenta de estrada.
- Árvores, água, edifícios e coordenadas externas não podem receber estrada. Não há derrubada de mata, pontes ou pavimentação sobre edifícios.
- Ferramentas trabalham por clique em cada tile, não por arrasto ou desenho automático de uma rota inteira.

A navegação considera custos por tile: estrada 0,85; grama/terra 1,0; areia 1,3; solo pedregoso 1,2. O deslocamento usa o inverso do custo, então estradas são cerca de 18% mais rápidas que grama. Um caminho mais curto ainda pode ser preferível a um desvio longo por estrada. Reformas, insumos, tributos e receitas permanecem iguais; a logística online pode melhorar com caminhos mais rápidos.

## Persistência e compatibilidade
Continua usando schema 2. `world.size` é opcional (default 32); `world.base="classic"` preserva a origem clássica após ampliar; `terrain_edits` guarda coordenadas e tipos alterados. São aceitos os saves anteriores, sem adicionar decisões políticas. Novos campos são validados antes de trocar o estado vivo: dimensões, limites, duplicações, tipos e alterações incompatíveis com água.

A compatibilidade é de leitura dos saves antigos pela v0.5.0. Versões antigas não compreendem mapas ampliados e edições novas. Backups existentes continuam sendo produzidos ao salvar. O save pessoal foi apenas lido no teste, sem ser sobrescrito.

## Arquitetura
`WorldGen` mantém o gerador original como núcleo e usa coordenadas relativas para que regiões geradas em 48 e 64 sejam consistentes entre ampliações. `Simulation.map_size()` e `centre()` são a referência de dimensão/origem. Câmera e minimapa recebem a dimensão efetiva; projeção isométrica/pivôs não mudaram.

`Navigation` usa AStarGrid2D ponderado, heurística Manhattan admissível de 0,85, cache limitado a 256 caminhos e cópias independentes por consumidor. Obras e estradas atualizam só o ponto afetado e invalidam o cache; rollback de construção restaura o ponto. Alterar estrada não arredonda nem teleporta o morador.

O terreno é dividido em blocos de 8×8, com desenho retido e culling pelo retângulo real da câmera. O mapa 64 tem 64 blocos; blocos fora da vista não desenham tiles. O minimapa rebakeia após uma revisão do terreno, evitando manter estradas antigas na imagem. Árvores/prédios/NPCs mantêm a ordenação pela base.

Assets de solo: `python tools/asset_pipeline/terrain.py`, três superfícies nativas 64×64, máscara 64×32 e origem 32,40, quatro cores opacas e transparência. Não toca em retratos, personagens ou referências.

## Limites
Mapa máximo 64×64, população máxima 64 moradores e no máximo 1024 construções (limites explícitos de simulação/save). Ampliação adiciona território; não implementa guerra, fronteiras de facções, descoberta, pontes ou novos recursos. Solo pedregoso não produz pedra sozinho: produção continua nos postos/construções. Pendências de retratos e cavalaria anteriores permanecem.
