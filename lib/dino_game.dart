import 'dart:ui';
import 'package:dino_runner/ground.dart';
import 'package:dino_runner/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class DinoGame extends FlameGame with TapCallbacks {

  late final Player player;
  late final InfiniteGround ground;
  final double gameSpeed = 300;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Создаем бесконечную дорогу
    ground = InfiniteGround(
      speed: gameSpeed,
      position: Vector2(0, size.y - 200), // Размещаем дорогу снизу экрана
    );
    add(ground);

    player = Player(position: Vector2(0, -100));
    add(player); // Добавляем в игру
  }

  // Этот метод срабатывает при тапе в ЛЮБОМ месте экрана
  @override
  void onTapDown(TapDownEvent event) {
    player.jump(); // Вызываем прыжок у игрока
    super.onTapDown(event);
  }
}