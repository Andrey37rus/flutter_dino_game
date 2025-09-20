import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class StartButton extends RectangleComponent with TapCallbacks {
  final VoidCallback onPressed;
  final String text;

  StartButton({
    required this.onPressed,
    required this.text,
    required super.position,
    required super.size,
  }) {
    paint = Paint()..color = const Color(0xFF4CAF50);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Рисуем прямоугольный фон

    // Рисуем текст
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width / 2 - textPainter.width / 2,
        height / 2 - textPainter.height / 2,
      ),
    );
  }
}