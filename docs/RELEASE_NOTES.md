# HalfACiv Isometric v0.4.0 — Interface, menu e mundos por semente

## Jogar
Extraia o ZIP e execute HalfACiv-Isometric.exe no Windows 10/11 x64. Salve e feche a versão antiga antes de abrir a nova. Saves anteriores continuam compatíveis (schema 2): abrem no mapa clássico do Vale da Aurora, com todos os moradores, contratos e equipamentos.

O jogo abre no **menu principal**:
- **Enter** continua o domínio salvo; o cartão mostra nome, dia, moradores e há quanto tempo foi salvo.
- **N** funda um mundo aleatório; **V** abre o mapa clássico.
- **P** abre "Personalizar mundo": nome, semente (número ou qualquer palavra), paisagem (Lagos, Rio ou Costa) e recursos iniciais (Escassos, Normais ou Fartos), com prévia do mapa enquanto você digita.

No jogo, **Esc** abre a pausa (voltar, salvar, carregar e as mesmas opções de mundo).

A tela segue a disposição dos 4X clássicos:
- **Barra de menus:** Jogo, Aldeia, Ver, Conselheiros e Ajuda.
- **Coluna direita:** minimapa (clique ou arraste para mover a vista), caixa de status (recursos com ícones e tendência por hora, moradores, avisos, ritmo) e informações da seleção.
- **Construção:** janela flutuante à esquerda.

**H** abre o Registro da aldeia, com moradores e edifícios ordenáveis e o histórico de mensagens. **Ctrl** sobre o mapa mostra uma ficha rápida, **Shift** traça rotas e o **botão do meio** centraliza num clique.

## Implementado
- Geração de mundo por semente, determinística:
  - lagos, rio sinuoso ou costa recortada, florestas por ruído, estradas em cruz com anel e caminhos;
  - os 22 prédios iniciais distribuídos com acesso garantido, e o pesqueiro sempre na margem;
  - o save guarda só as opções do mundo e o terreno é recriado ao carregar.
- Interface nova:
  - molduras com chanfro e ícones de recurso em pixel art (`assets/ui/`), com tema central;
  - HUD em escala inteira de pixels de tela (1:1 em 1080p, 2× em 1440p).
- Menu principal e de pausa com atalhos para todas as ações. Os atalhos do mapa não agem por trás do menu.
- Ícone do jogo desenhado à mão (16 e 32 px, ampliações inteiras até 256 px), no executável e na janela.
- Ideias de interface do Civ2-UI-Additions (MIT), sem reutilizar código:
  - registro ordenável e ficha Ctrl;
  - rotas com Shift e cores de estado;
  - avisos sobre o mapa e custo em falta nas obras.
- Mantidos contratos, cavalaria, economia, rotinas, câmera e ordenação da v0.3.0.

## Validação
Testes automatizados e verificações gráficas constam em BUILD_INFO.json. Capturas e relatório no repositório em `docs/visual-validation/interface/`, `docs/visual-validation/ui-additions/` e `docs/VALIDATION_V0.4.0.md`. O teste de lógica verifica 90 sementes por execução. Build Windows executado em OpenGL.

## Limites conhecidos
- **Mapa:** 32×32 e com a praça no centro. As molduras e ícones da interface são peças provisórias geradas pelo pipeline, substituíveis por arte à mão sem mudar código.
- **Escala:** abaixo de 1280×720 a interface encolhe com escala fracionária.
- **Retratos:** continuam como fallback em revisão; nenhum foi promovido.
- **Animação:** personagens em uma direção; trote e galope são ritmos do ciclo de passo.
- **Fora desta versão:** combate, política, interiores e colisão entre NPCs.

## Créditos
- **Personagens:** GandalfHardcore Character Asset Pack; componentes usados dentro do jogo, assets não são distribuídos soltos.
- **Tiles:** crabcrabcrabs, CC BY 4.0: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles
- **Engine:** Godot 4.7.2 (licença MIT no ZIP).
- **Interface:** ideias do Civ2-UI-Additions de FoxAhead (MIT), https://github.com/FoxAhead/Civ2-UI-Additions; nenhum código ou arte foi reutilizado. Interface, ícone e camadas novas: pipelines editáveis do projeto.
- **Referências:** as referências licenciadas não foram enviadas a IA.

Detalhes em CREDITS.md e nas licenças anexas.

Commit testado: `{{COMMIT}}`.
