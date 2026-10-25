# HalfACiv Isometric v0.2.2 — Padrão de retratos

Versão de direção artística e infraestrutura dos retratos. O gameplay, os sprites do mapa, os tilesets e os saves da v0.2.1 foram preservados.

## O que muda
- **Padrão oficial dos retratos:** guia de estilo permanente derivado de duas folhas de referência de pixel art medieval (bustos 64×64 nativos, ~40 cores, rampas com deslocamento de matiz, contorno seletivo, luz superior). As referências não são distribuídas.
- **Auditoria honesta:** os 24 retratos atuais compartilham o mesmo rosto gerado por código e foram classificados como placeholder. Continuam no jogo como fallback, sinalizados por "Retrato em desenvolvimento". **Nenhum retrato novo foi desenhado nesta versão**; o redesenho à mão está documentado como trabalho pendente.
- **Exibição pixel-exata:** os retratos aparecem na maior escala inteira de pixels de tela, com nearest-neighbor, inclusive em janelas 1920×1080, verificados pixel a pixel.
- **Pipeline para artistas:** manifesto NPC ↔ retrato, validação, importação sem reamostragem, aprovação com revisor registrado, atlas e galeria de validação.

## Validação
9 testes de assets, 21.111 verificações de lógica, 22.482 de geometria/câmera, 27 de integração, 1.873 verificações GPU e 3 verificações de retrato pixel-exato na UI (720p e 1080p), todas sem falhas. Galeria em docs/portrait-validation/.

## Executar no Windows 10/11 x64
Extraia o ZIP e abra HalfACiv-Isometric.exe. WASD move, roda aproxima/afasta, botão do meio arrasta. B/I recolhem os painéis; Esc/Espaço pausam; F5 salva. Não precisa instalar Godot.

## Limitações
Retratos placeholder até a entrega da arte desenhada à mão; uma direção lateral para personagens; montaria provisória; sem colisão entre NPCs, interiores, recrutamento, combate ou política.

## Créditos
Tiles crabcrabcrabs (CC BY 4.0), personagens GandalfHardcore sob licença de incorporação em jogos. Originais, atlas privados e referências de retrato excluídos do código-fonte público.

Commit testado: `{{COMMIT}}`.
