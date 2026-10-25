# Auditoria de assets
Fontes intactas em D:/repositorio/HalfACiv 2. Copias locais em assets/original, excluidas do Git e da exportacao.

## GandalfHardcore
65 PNGs RGBA 800x448. Grade 80x64, dez colunas e sete linhas. Idle: linha 0, cinco frames; walk: linha 1, oito frames. Outras linhas possuem corrida, acoes e morte, ainda nao integradas. Uma direcao lateral disponivel: nao ha oito direcoes. Sem espelhamento de espadas ou rotacao de 45 graus. Camadas: corpos masculinos/femininos em cinco tons, cinco cabelos por sexo, roupas, botas e espadas. Armaduras completas e escudos ausentes. Composicao por alpha, recorte 48x56, desenhado 30x35 para reduzir disparidade de escala com casas.

Licenca do READ ME permite jogos comerciais/nao comerciais e modificacoes, mas proibe redistribuir o pacote, revender pixel art editada, treinamento de IA, NFTs e ferramentas. Originais e atlas derivados nao entram no repositorio publico. Atribuicao: GandalfHardcore. Recursos incorporados ao jogo devem respeitar a licenca; nunca publicar ZIP separado dos sprites.

## Tileset isometricStrategy
PNG RGBA 1024x1280, grade 16x20 com celulas 64x64, diamantes 64x32. Casas, torres, florestas, horta, agua, moinho e muros. Licenca no ZIP: CC BY 4.0. Autor confirmado na pagina original: crabcrabcrabs. Fonte: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles. Atribuicao completa em assets/tilesets/ATTRIBUTION.md. Estrada e agua criadas por script para corrigir repeticao indevida de margens. Paleta original preservada nas demais pecas. Pixel art sem filtro; transparencias conservadas.

## GIFs de referencia
AgD6Fo.gif, tpqMGd.gif e vR4Nwp.gif: 512x444, paleta indexada, duracoes e hashes no inventario JSON. Frames extraidos em folhas de contato locais. AgD6Fo: nove frames a 80ms, cavaleiro de perfil em salto/galope; nao representa idle isometrico. tpqMGd: seis frames a 80ms, galope lateral com extensao alternada das pernas. vR4Nwp: seis frames a 80ms, idle lateral com cauda e postura; lanca vertical exige margem superior. Todos sao vistas laterais e nao possuem oito direcoes. Licencas nao localizadas: excluidos da publicacao e nao utilizados como animacoes finais.

## Arte provisoria
Nao encontrados portraits separados ou atlas de cavalos. Criados 12 estudos originais de busto 64x80, distintos, editaveis no pipeline e identificados como provisorios na interface. Nao sao sprites ampliados. Um cavalo original de perfil, castanho, com manta azul, oito frames de idle/walk; pernas, cabeca, cauda e respiracao variam. Cavaleiro usa roupa azul/espada e duas camadas sincronizadas, ainda sem armadura prateada final. Nenhum desses itens e considerado arte final de oito direcoes.

Inventario reproduzivel em docs/asset_inventory.json: dimensoes, modo, numero/duracao de frames e SHA256. Pipeline: tools/asset_pipeline/build.py. Originais jamais modificados. Paleta detalhada por cor e direcoes adicionais exigem producao artistica futura.


## Atualização v0.2.0
O inventário dos originais permanece com os mesmos hashes. `village_art.py` estende a fonte editável existente, sem enviar assets GandalfHardcore a ferramentas de IA. Gera 24 personagens compostos e 24 retratos originais de 96×112. Os retratos anteriores de 64×80 foram substituídos por versões com sombreamento, cabelo/barba, chapéus e insígnias; a identidade é mantida quando se troca o ofício. Ainda são identificados como arte em desenvolvimento.

Atlas de personagem: 384×168, frames 48×56; idle/walk/work com 5/8/8 fases. A terceira linha é uma composição de pose idle e ferramenta original desenhada por código, não uma animação anatômica completa inédita. Os atlas permanecem excluídos do repositório público.

Adaptações do tileset CC BY: novas seleções de casas/capela/feira, 12 construções adicionais utilizáveis, letreiros, caixas, fornalha, redes, vasos, cercados, quatro variantes de grama e pavimento da praça. Algumas construções compartilham a mesma base com detalhes distintos. Moinho e torre usam atlas de quatro frames nativos, sem inferir direções inexistentes. A paleta do terreno foi atenuada; originais intactos.

Cinco testes Python verificam frames válidos/distintos, 24 retratos únicos, cavalo, atlas ambientais e reprodução byte a byte de uma geração independente. Pipeline e metadados em `assets/ui/identities.json` são públicos; originais, sprites derivados e GIFs de referência continuam privados. Contatos da inspeção foram gerados apenas para análise local.


## Patch v0.2.1 — origem e pivôs confirmados
A inspeção por pixels confirmou a superfície original com topo y=24, centro y=40 e base y=56; as oito linhas inferiores são extrusão, não a origem do chão. A antiga subtração (32,48) estava incorreta. Cópias em `assets/tilesets/visual_v021` usam origem (32,40), removem extrusão interna e mantêm toda a arte acima da superfície. Terrenos são recortados por máscara analítica semiaberta, sem furos. A forja derivada recebe uma pequena saída de fumaça; o original permanece intacto.

Corpos derivados em `assets/characters/native` têm frames 30×35/pivô (15,35), gerados por nearest-neighbor uma vez. Cavalo derivado `horse_native_v021.png`: frames 48×48/pivô (24,41), sem a sombra translúcida duplicada. Árvores derivadas mantêm raízes/solo byte a byte entre frames; só a copa acima de y=24 muda. Metadados e hashes de origem em `assets/ui/render_policy_v021.json`. O conjunto privado continua excluído do Git e incorporado apenas ao jogo.
