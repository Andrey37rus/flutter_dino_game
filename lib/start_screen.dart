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
    
    // Создаем кнопку старта с относительными размерами
    final buttonWidth = gameSize.x * 0.2; // 50% ширины экрана
    final buttonHeight = gameSize.y * 0.10; // 8% высоты экрана
    final buttonYPosition = gameSize.y * 0.5; // 60% от высоты экрана
    
    final button = StartButton(
      onPressed: onStartPressed,
      text: 'START GAME',
      position: Vector2(
        gameSize.x / 2 - buttonWidth / 2, // Центрируем по горизонтали
        buttonYPosition,
      ),
      size: Vector2(buttonWidth, buttonHeight),
    );
    
    add(button);
  }

  @override
  void render(Canvas canvas) {
    // Полупрозрачный черный фон
    final backgroundPaint = Paint()
      ..color = const Color(0x80000000)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y), backgroundPaint);

    // Заголовок игры с относительным размером шрифта
    final titleFontSize = gameSize.y * 0.06; // 6% высоты экрана
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: titleFontSize,
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
        gameSize.y * 0.3, // 30% от высоты экрана
      ),
    );
    super.render(canvas);
  }
}