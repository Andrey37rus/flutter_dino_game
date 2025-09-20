import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PauseButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  bool isPaused;

  PauseButton({
    required this.onPressed,
    required this.isPaused,
    required super.position,
    required super.size,
  });

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    // Рисуем фон кнопки
    final backgroundPaint = Paint()..color = const Color(0x80000000);
    final backgroundRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(backgroundRect, backgroundPaint);
    
    // Рисуем иконку паузы/плей
    final iconPaint = Paint()..color = Colors.white;
    if (isPaused) {
      print('PRESS POUSE');
      // Иконка play (треугольник)
      final path = Path()
        ..moveTo(width * 0.3, height * 0.2)
        ..lineTo(width * 0.3, height * 0.8)
        ..lineTo(width * 0.8, height * 0.5)
        ..close();
      canvas.drawPath(path, iconPaint);
    } else {
      print('resume');
      // Иконка pause (две полоски)
      canvas.drawRect(Rect.fromLTWH(width * 0.2, height * 0.2, width * 0.2, height * 0.6), iconPaint);
      canvas.drawRect(Rect.fromLTWH(width * 0.6, height * 0.2, width * 0.2, height * 0.6), iconPaint);
    }
  }
}