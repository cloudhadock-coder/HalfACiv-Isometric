# Releases incrementais

- **v0.1.0 — Fundação:** publicada e aprovada; mapa, câmera, construção, economia inicial, NPCs, montaria e saves.
- **v0.2.0 — Vida na aldeia:** implementação e testes de 24 ofícios, rotinas, postos com vagas, logística, 18 construções, ambientes animados, 24 retratos, interface e migração. Distribuição/publicação verificadas no relatório final.
- **v0.2.1 — Correções visuais:** câmera/zoom/viewport, alinhamento/pivôs, profundidade/sombras e interface; testes e capturas em `visual-validation/v0.2.1`. Publicação verificada pelo pipeline e relatório final.
- **v0.3.0 — Cavalaria e personagens:** armaduras, equipamentos separados, heráldica, novos ciclos e direções artísticas, recrutamento. Retratos mais fiéis aos componentes individuais.
- **v0.4.0 — Política e progressão:** quatro facções, conselho, reformas, legitimidade e evolução de Aldeia a Reino.
- **v0.5.0 — Expansão territorial:** mapas maiores, estradas editáveis, mais terrenos e navegação incremental.

Toda versão concluída exige testes, VERSION/menu/changelog consistentes, commit e tag semântica, build Windows e GitHub Release verificada no mesmo commit. Não publicar assets com redistribuição proibida. `scripts/build_release.py` e `scripts/publish_release.py` verificam commit/tag e artefatos.
