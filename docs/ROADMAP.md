# Releases incrementais

- **v0.1.0 — Fundação:** publicada e aprovada; mapa, câmera, construção, economia inicial, NPCs, montaria e saves.
- **v0.2.0 — Vida na aldeia:** implementação e testes de 24 ofícios, rotinas, postos com vagas, logística, 18 construções, ambientes animados, 24 retratos, interface e migração. Distribuição/publicação verificadas no relatório final.
- **v0.2.1 — Correções visuais:** câmera/zoom/viewport, alinhamento/pivôs, profundidade/sombras e interface; testes e capturas em `visual-validation/v0.2.1`. Publicação verificada pelo pipeline e relatório final.
- **v0.3.0 — Cavalaria e personagens:** contratos de especialistas, equipamento em camadas, cinco pelagens, seis cores heráldicas, ritmos e persistência implementados. Oito direções, ciclos anatômicos novos e aprovação dos retratos são pendências artísticas explícitas para evolução posterior.
- **v0.4.0 — Interface e mundos por semente:** publicada fora da sequência original; preservada integralmente.
- **v0.4.1 — Política e progressão (recuperação do plano original):** quatro facções, conselho com decisões, apoio, legitimidade, quatro reformas econômicas e evolução explícita de Aldeia a Reino. Regras e limitações em `POLITICS.md`; validação e publicação confirmadas no relatório final.
- **v0.5.0 — Expansão territorial:** mapas maiores, estradas editáveis, mais terrenos e navegação incremental.

Toda versão concluída exige testes, VERSION/menu/changelog consistentes, commit e tag semântica, build Windows e GitHub Release verificada no mesmo commit. Não publicar assets com redistribuição proibida. `scripts/build_release.py` e `scripts/publish_release.py` verificam commit/tag e artefatos.
