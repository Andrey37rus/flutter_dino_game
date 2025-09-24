import 'package:dino_runner/control_button/start_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StartScreen extends Component {
  final VoidCallback onStartPressed;
  
  StartScreen({required this.onStartPressed});

  late StartButton button;
  late double titleFontSize;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Добавляем кнопку при загрузке
    addButton();
  }

  // Этот метод будет вызываться при изменении размера игры
  void updatePosition() {
    // Используем size из родительской игры через findGame()
    final game = findGame();
    if (game == null) return;
    
    final gameSize = game.size;
    
    // ✅ ОДИНАКОВЫЕ ПАРАМЕТРЫ: такие же как в addButton()
    final buttonWidth = gameSize.x * 0.25; // 44% ширины экрана
    final buttonHeight = gameSize.y * 0.08; // 8% высоты экрана (было 0.8 - это 80%!)
    
    if (button.isMounted) {
      button.size = Vector2(buttonWidth, buttonHeight);
      button.position = Vector2(
        gameSize.x / 2 - buttonWidth / 2, // Центрируем по горизонтали
        gameSize.y * 0.45, // Ближе к заголовку (было 0.6)
      );
    }
    
    // ✅ ОДИНАКОВЫЙ размер шрифта
    titleFontSize = gameSize.y * 0.06; // 6% высоты экрана (было 0.45 - это 45%!)
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    print('StartScreen resized to: $size');
    updatePosition();
  }

  void addButton() {
    final game = findGame();
    if (game == null) return;
    
    final gameSize = game.size;
    
    // ✅ ОДИНАКОВЫЕ ПАРАМЕТРЫ
    final buttonWidth = gameSize.x * 0.44; // 44% ширины экрана
    final buttonHeight = gameSize.y * 0.08; // 8% высоты экрана (ИСПРАВЛЕНО: было 0.8)
    
    button = StartButton(
      onPressed: onStartPressed,
      text: 'START GAME',
      position: Vector2(
        gameSize.x / 2 - buttonWidth / 2,
        gameSize.y * 0.45, // Ближе к заголовку (ИСПРАВЛЕНО: было 0.6)
      ),
      size: Vector2(buttonWidth, buttonHeight),
    );
    
    add(button);
    titleFontSize = gameSize.y * 0.06; // 6% высоты экрана (ИСПРАВЛЕНО: было 0.45)
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
    
    canvas.drawRect(Rect.fromLTWH(0, 0, gameSize.x, gameSize.y), backgroundPaint);

    // Заголовок игры
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
        gameSize.y * 0.3, // Заголовок на 30% высоты
      ),
    );
    
    super.render(canvas);
  }
}