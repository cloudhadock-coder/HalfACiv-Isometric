# Validação v0.2.0

## Ambiente e escopo
Windows, Godot 4.7.2 stable oficial, renderizador OpenGL 3.3 Compatibility, AMD Radeon RX 580 2048SP. Testes executados no código da v0.2.0; `scripts/build_release.py` os repete no commit/tag limpos e testa o EXE produzido.

## Resultados obtidos antes do empacotamento
- Cinco testes Python: 24 atlas idle/walk/work não vazios e distintos; 24 retratos únicos; cavalo; animações do moinho/bandeira; reprodução byte a byte do pipeline em pasta isolada.
- **21.084 verificações GDScript, zero falhas:** coordenadas, tipos de conteúdo, custos, conclusão de obras, vagas de moradia/imigração, margem de pesqueiro, produção com presença, estoque/carga/entrega sem duplicação, insumos, troca de profissão preservando aparência, 800 passos de todos os moradores sem atravessar obstáculos, refeição, sono/vigor, rejeição de obra que isola um morador, determinismo em passos fixos, offline limitado, save/load, backup e migração.
- **18 verificações de integração, zero falhas:** menu, economia, zoom, botão real de forja e clique no mapa, galeria com 24 retratos, profissão, identidade, velocidade, salvar/carregar, pausa da simulação e animações e inspeção de prédio/pessoa.
- Migração de fixture v0.1.0 conserva 12 moradores mais cavalo e recursos, sem conceder moradores extras. Caso com casa em (15,15) mantém expansão funcional. A primeira gravação migrada cria backup separado.
- Capturas reais inspecionadas: `gameplay-v0.2.0.png` (1920×1080), `gameplay-v0.2.0-960x540.png` (960×540), noite/galeria (1280×720). Escala, textos, profundidade, ferramentas, cargas, transparências e retratos foram revisados. Animações usam frames distintos validados e ambiente pausa junto com a simulação.

## Performance local
Benchmark de 360 frames com **64 moradores + cavalo**, VSync desativado: **137.31 FPS de média**, **8.465 ms p95**, na RX 580 indicada. Terreno persistente e objetos estáticos em cache, culling de objetos e retratos pré-carregados. Resultado não representa hardware diferente, saves maiores ou todas as situações possíveis. Dados brutos em `benchmark-v0.2.0.json`.

## Distribuição
O script exporta Windows x64 com PCK incorporado, executa smoke do próprio EXE e registra logs, commit, engine, checks e SHA256 em `dist/v0.2.0/BUILD_INFO.json`. O estado real da publicação é confirmado pelo script da Release e pelo relatório final; este documento não presume publicação antes dessa verificação.

## Limitações práticas
Uma direção lateral. Sem interiores nem colisão entre pessoas; pontos externos de casas e postos podem ser compartilhados. Rotas reiniciam ao carregar, mas cargas e estoques persistem. Offline é aproximação econômica de 55% de produtividade dos postos atribuídos durante o turno, sem eventos visuais ou imigração. Algumas bases arquitetônicas são reutilizadas; retratos e montaria são arte em desenvolvimento. Recrutamento/política/progressão continuam ausentes e não são contabilizados como testados. Atlas GandalfHardcore privados; originais intactos e GIFs de referência excluídos da distribuição.
