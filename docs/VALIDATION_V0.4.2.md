# Validação v0.4.2 — Sprites e animações

## Estado inicial preservado
Base v0.4.1. Antes de modificar, o Git registrava oito exclusões locais: atlas e `.import` do moinho/torre, em assets/buildings e assets/buildings/visual_v021. Não foram restaurados. Os novos produtos estão em native_v042, com gerador isolado e remoção das dependências/geração dos arquivos obsoletos. A folha fornecida foi preservada com hash idêntico ao início. Personagens, retratos, economia, política e formato de save não foram modificados.

## Auditoria e correções
Fonte 1024×1280 RGBA, células 64×64, 16 colunas × 20 linhas. Hash `a6af0235f3538458ae65e46d1ed0b515cf1ece6881cd0a3b5d8979b20a0fd31f`. É idêntica à fonte já disponível: a melhoria vem do mapeamento correto e do uso das sequências completas, não de afirmar que a folha é inédita. Coordenadas/FPS em BUILDING_ANIMATIONS.md e ASSET_AUDIT.md.

- Torre anterior alternava tipos de estrutura (linha 0, colunas 6–9). Agora usa 14 frames de bandeira azul sobre posto fortificado constante.
- Moinho usa seus quatro desenhos nativos de pás; quartel usa os 14 frames de bandeira vermelha.
- Casa, herbário, carpintaria, padaria e estalagem usam os 16 frames de fumaça nativa; evitada duplicação de fumaça procedural nas casas.
- Horta usa as cores de trigo dos 16 frames dentro de silhueta fixa, mantendo cerca/solo. Nos recortes brutos a cerca desaparecia em algumas colunas.
- Capela passa a usar a igreja da folha; serraria, acampamento florestal. Ícones/inspector usam os mesmos previews do mapa.
- Retidos pivô 32,40, nearest-neighbor, ordenação pela base, máscara de extrusão interna e tabuleiro externo.
- Alfa parcial 68 presente na própria folha foi preservado. O primeiro teste exigia indevidamente alfa binário; corrigido para verificar os valores nativos 0/68/255, sem aplicar a regra exclusiva de portraits.
- O teste GPU de profundidade usava a opacidade do preview do frame 0 para todas as fases. Fumaça animada muda a máscara. O teste agora amostra o frame efetivamente desenhado e continua verificando oclusão pixel a pixel, sem reduzir a exigência dos pixels opacos.

## Testes e execução
- `python tests/test_buildings.py`: **6 testes**, sem falhas. 18 catálogos/previews/atlas, contagem/dimensões, transparência nativa, extrusão aparada, fundações constantes, cerca estável, transição de loop com diferença de pixels comparável aos passos nativos, determinismo e originais intactos. Também confirma que os atlas obsoletos não reapareceram.
- `tests/building_animation_tests.gd` OpenGL: **187 verificações**, sem falhas. Todos os frames/FPS e wraps, catálogo real, diferença entre dois renders em fases distintas, pausa com pixels constantes, previews/obras fixos e preservação dos pixels da barra superior.
- `python tests/test_assets.py`: **13 testes**, sem falhas. Testes antigos atualizados para o catálogo novo; retratos/personagens continuam byte a byte reproduzíveis no scratch isolado.
- `tests/test_runner.gd`: **21.235 asserções**, sem falhas.
- `tests/visual_tests.gd` headless: **22.470 asserções**, sem falhas.
- `tests/visual_validation.gd -- --no-save`: **1.864 checks GPU**, sem falhas: 333 pixels de oclusão e 1.503 de NPC à frente.
- Validadores de portraits/kit e geração de galeria/previews executados. Nenhum portrait/parte promovido; 24 retratos e 19 partes seguem pendentes.
- Save real **v0.4.1**, schema 2, 25 entidades e 22 edifícios carregado; hash original inalterado. Fonte pessoal não foi regravada nem publicada.

O pipeline de release repete essas suítes e as regressões existentes de integração, política, campanha, companhia, interface, mundos e retratos no commit marcado, além de exportar e iniciar o EXE Windows com verificação do catálogo de animações incorporado. Os resultados definitivos dessas repetições constam em BUILD_INFO.json. ResourceWarnings dos testes Python antigos de UI/ícone não foram ocultados e não são falhas do jogo.

## Capturas inspecionadas
Imagens do viewport em visual-validation/v0.4.2: Village, Buildings_Frame_A, Buildings_Frame_B, Buildings_Paused, Chapel_Closeup, Buildings_1080p e Existing_Save. Buildings_Reviewed é uma cópia da captura A para revisão. A/B diferem no movimento nativo; Paused permanece idêntica a B. O catálogo é uma fixture controlada com as 18 construções para inspecionar os recortes, não uma campanha humana. Não foram criadas screenshots fictícias nem versionada a folha completa de referência.

## Performance medida
Godot 4.7.2/OpenGL, RX 580 2048SP, VSync desligado, 360 frames, 64 cavaleiros equipados mais um cavalo e aldeia: **117,5 FPS médios**, p95 **9,709 ms**, amostra **1.434 draw calls**, memória estática da engine **46,3 MB**. Não é RSS/VRAM nem garantia de desempenho em outro hardware. Sem alegação de ganho causal sobre outras versões.

## Limites
Nove tipos têm animações nativas; os nove sem sequência permanecem estáticos com efeitos ambientais existentes quando aplicáveis. Não reproduzir variantes de estrutura/terreno como se fossem frames. A torre é representada pelo posto fortificado com bandeira azul. Não há novos personagens, retratos, animações de cavalaria ou regras de gameplay nesta atualização. Publicação remota só é confirmada no relatório final após conferir commit/tag e hash do anexo.
