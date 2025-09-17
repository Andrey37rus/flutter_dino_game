import 'dart:ui';
import 'package:dino_runner/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class DinoGame extends FlameGame with TapCallbacks {

  late final Player player;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    player = Player(position: Vector2(100, 300));
    add(player); // Добавляем в игру
  }

  // Этот метод срабатывает при тапе в ЛЮБОМ месте экрана
  @override
  void onTapDown(TapDownEvent event) {
    player.jump(); // Вызываем прыжок у игрока
    super.onTapDown(event);
  }
}