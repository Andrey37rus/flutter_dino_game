import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameOverText extends PositionComponent {
  GameOverText({required this.score});

  late double gameOverFontSize;
  late TextPainter gameOverPainter;
  final int score;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    size = Vector2.zero();
    position = Vector2.zero();
    updateFontSize();
    _createTextPainter();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    updateFontSize();
    _createTextPainter();
  }

  void updateFontSize() {
    gameOverFontSize = size.y * 0.08;
  }

  void _createTextPainter() {
    final gameOverStyle = TextStyle(
      color: Colors.red,
      fontSize: gameOverFontSize,
      fontWeight: FontWeight.bold,
    );
    
    final gameOverSpan = TextSpan(text: 'GAME OVER', style: gameOverStyle);
    gameOverPainter = TextPainter(
      text: gameOverSpan,
      textDirection: TextDirection.ltr,
    );
    gameOverPainter.layout();
  }

  @override
  void render(Canvas canvas) {

    final game = findGame();
    if (game == null) return;
    
    final gameSize = game.size;

    // Полупрозрачный черный фон
    final backgroundPaint = Paint()
      ..color = const Color(0x80000000)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    // ✅ ИДЕАЛЬНОЕ ЦЕНТРИРОВАНИЕ
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    
    final textX = centerX - gameOverPainter.width / 2;
    final textY = centerY - gameOverPainter.height / 2;
    
    gameOverPainter.paint(canvas, Offset(textX, textY));

    // Заголовок игры
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    final titleSpan = TextSpan(text: 'DINO SCORE: $score', style: titleStyle);
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        gameSize.x / 2 - titlePainter.width / 2,
        gameSize.y * 0.3,
      ),
    );
    
    super.render(canvas);
  }
}