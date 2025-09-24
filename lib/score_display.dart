import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

class ScoreDisplay extends PositionComponent {
  int score = 0;
  late TextComponent scoreText;

  ScoreDisplay() : super(priority: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    scoreText = TextComponent(
      text: 'score: $score',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          color: const Color.fromARGB(255, 63, 60, 60),
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      anchor: Anchor.topLeft, 
    );
    add(scoreText);
  }

  void updateScore(int newScore) {
    score = newScore;
    scoreText.text = 'score: $score';
  }

  void reset() {
    updateScore(0);
  }
}