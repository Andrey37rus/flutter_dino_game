import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameOverText extends Component {
  final Vector2 gameSize;

  GameOverText({required this.gameSize});

  @override
  void render(Canvas canvas) {
    // Полупрозрачный черный фон
    final backgroundPaint = Paint()
      ..color = const Color(0x80000000) // Черный с 50% прозрачностью
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y), backgroundPaint);

    // Текст GAME OVER
    final gameOverStyle = TextStyle(
      color: Colors.red,
      fontSize: 64,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 10, 
          color: Colors.black, 
          offset: Offset(2, 2),
        ),
      ],
    );
    
    final gameOverSpan = TextSpan(text: 'GAME OVER', style: gameOverStyle);
    final gameOverPainter = TextPainter(
      text: gameOverSpan,
      textDirection: TextDirection.ltr,
    );
    
    gameOverPainter.layout();
    gameOverPainter.paint(
      canvas,
      Offset(
        gameSize.x / 2 - gameOverPainter.width / 2,
        gameSize.y / 2 - 50,
      ),
    );
    super.render(canvas);
  }
}