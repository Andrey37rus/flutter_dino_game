import 'package:dino_runner/control_button/start_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StartScreen extends Component {
  final VoidCallback onStartPressed;
  final Vector2 gameSize;

  StartScreen({required this.onStartPressed, required this.gameSize});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Создаем кнопку старта
    final button = StartButton(
      onPressed: onStartPressed,
      text: 'START GAME',
      position: Vector2(gameSize.x / 2 - 100, gameSize.y / 2 + 50),
      size: Vector2(200, 60),
    );
    
    add(button);
  }

  @override
  void render(Canvas canvas) {
    // Полупрозрачный черный фон
    final backgroundPaint = Paint()
      ..color = const Color(0x80000000) // Черный с 50% прозрачностью
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y), backgroundPaint);

    // Заголовок игры
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 36,
      fontWeight: FontWeight.bold,
    );
    
    final titleSpan = TextSpan(text: 'DINO RUNNER', style: titleStyle);
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        gameSize.x / 2 - titlePainter.width / 2,
        gameSize.y / 2 - 100,
      ),
    );

    // Инструкция
    final instructionStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
    );
    
    final instructionSpan = TextSpan(text: 'Tap to jump!', style: instructionStyle);
    final instructionPainter = TextPainter(
      text: instructionSpan,
      textDirection: TextDirection.ltr,
    );
    
    instructionPainter.layout();
    instructionPainter.paint(
      canvas,
      Offset(
        gameSize.x / 2 - instructionPainter.width / 2,
        gameSize.y / 2 - 30,
      ),
    );

    super.render(canvas);
  }
}