# HalfACiv Isometric v0.3.0 — Cavalaria e personagens

## Jogar
Extraia o ZIP e execute HalfACiv-Isometric.exe no Windows 10/11 x64. Salve e feche a versão antiga antes de abrir a nova. Carregar domínio conserva saves anteriores (schema 2; migração de schema 1 mantida).

Pressione R ou use Companhia e cavalaria no painel direito. Em Contratos, contrate Hector (55 ouro, +20% de deslocamento montado), Ulric (45, +25% no trabalho de ferreiro), Beatriz (35, +25% no trabalho de padeira) e Oswin (30, +25% na pesca). O contrato especializa o morador nomeado existente; se ele estiver ausente, chega como morador novo sujeito a vaga de moradia. Não duplica a pessoa. Hector exige um estábulo concluído. Os bônus só funcionam no ofício contratado; aumento produtivo também aumenta seus insumos na mesma proporção, inclusive na aproximação offline.

Selecione um cavaleiro ou o cavalo no mapa, abra R e escolha Cavalaria e heráldica: cinco pelagens, seis cores de manta/estandarte, barda e equipamento do cavaleiro. Escolha o ritmo de deslocamento. F5 salva tudo. Equipamentos são cosméticos; não há combate.

## Implementado
- Contratos únicos, recursos debitados uma vez, bloqueios com motivo e retratos associados.
- Camadas nativas 48×48 para cavalo, manta, barda, cavaleiro e estandarte, nearest-neighbor, sem espelhamento de armamento.
- Ritmos montados sincronizados, com velocidade efetiva em navegação.
- Persistência compatível: contratos, equipamento e receitas de retratos do trabalho local prévio.
- Mantidos construção, economia, rotinas, câmera e ordenação existentes.

## Validação
Testes automatizados e verificações gráficas constam em BUILD_INFO.json. Capturas e relatório no repositório em docs/visual-validation/v0.3.0 e docs/VALIDATION_V0.3.0.md. Save existente carregado sem alterar o arquivo original. Build Windows executado em OpenGL.

## Limites conhecidos
A animação original continua lateral. Trote e galope são ritmos do ciclo de passo; não são ciclos anatômicos novos nem oito direções. A arte das montarias/equipamentos ainda é estilizada e precisa de refinamento manual futuro. Nenhum retrato ou parte do kit recebeu aprovação automática: o jogo mantém os fallbacks sinalizados. Os rascunhos do Jonas e as 19 partes do kit permanecem em revisão. Sem combate, interiores ou colisão entre NPCs. Política permanece no roadmap da v0.4.0.

## Créditos
GandalfHardcore Character Asset Pack: componentes usados dentro do jogo; assets não são distribuídos soltos. Tiles crabcrabcrabs, CC BY 4.0: https://crabcrabcrabs.itch.io/isometric-strategy-medieval-pixel-art-tiles . Engine Godot 4.7.2 (licença MIT no ZIP). Camadas novas: pipeline editável do projeto. Referências licenciadas não foram enviadas a IA. Detalhes em CREDITS.md e licenças anexas.

Commit testado: `{{COMMIT}}`.
