# Validação v0.2.1

Estado inicial: Git limpo em 2c04395. Gravação de 43,60 s localizada e inspecionada. Capturas antes/depois e reprodução detalhada em [VISUAL_BUGS_V0.2.1.md](VISUAL_BUGS_V0.2.1.md).

Passaram: 7 testes Python de assets; 21.111 verificações GDScript de lógica; 22.494 de geometria/câmera; 23 de integração; 1.873 verificações GPU, incluindo 342 pixels ocultados atrás da casa e 1503 à frente. Capturas reais em 960×540, 1280×720, 1600×720 e 1920×1080 foram inspecionadas. Testes usam saves isolados; campanha real v0.2.0 também abriu, sem alterar o arquivo original. Esquema de save continua 2.

Performance medida na RX 580 2048SP, OpenGL, 64 moradores + cavalo, 360 frames, VSync desligado: **160.42 FPS**, p95 **6.923 ms**, **986 draw calls** no quadro consultado, **41.6 MB** de memória estática do motor. Isso não é RSS/VRAM total. O benchmark antigo usava outro zoom, portanto não é uma comparação causal de ganho percentual. Dados brutos e todas as capturas em `visual-validation/v0.2.1/`.

O EXE Windows pré-commit já iniciou com OpenGL, simulou cinco ticks com 25 entidades/22 prédios e saiu com código 0, sem stderr. A compilação será repetida no commit/tag exatos. A publicação só é confirmada após o EXE Windows, tag/commit e digest do ZIP serem verificados pelo pipeline. Logs da compilação e os resultados repetidos no commit exato ficam em `dist/v0.2.1/`. O relatório final registra o resultado real da Release.

---

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
