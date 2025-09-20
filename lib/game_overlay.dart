import 'package:flutter/widgets.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('GAME OVER', style: TextStyle(fontSize: 40)),
          Text('Tap to restart', style: TextStyle(fontSize: 20)),
          // Кнопка рестарта и т.д.
        ],
      ),
    );
  }
}