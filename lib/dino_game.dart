import 'dart:ui';
import 'package:dino_runner/bird.dart';
import 'package:dino_runner/cloud.dart';
import 'package:dino_runner/grass.dart';
import 'package:dino_runner/ground.dart';
import 'package:dino_runner/player.dart';
import 'package:dino_runner/sunny.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class DinoGame extends FlameGame with TapCallbacks {

  late final Player player;
  late final InfiniteGround ground;
  late final InfiniteClouds clouds;
  late final Sun sun;
  final double gameSpeed = 300;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 187, 177, 177);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Создаем бесконечную дорогу
    ground = InfiniteGround(
      speed: gameSpeed,
      position: Vector2(0, size.y - 100), // Размещаем дорогу снизу экрана
    );
    add(ground);

    // Создаем бесконечные облака - используем clouds вместо cloud
    clouds = InfiniteClouds(
      speed: gameSpeed,
      position: Vector2(0, 450), // Позиция в верхней части экрана
    );
    add(clouds);

    // Создаем солнце в правом верхнем углу
    sun = Sun(
      position: Vector2(250, 350),
    );
    add(sun);

    // void spawnBird() {
    //   final randomHeight = (size.y - 300) + (Random().nextDouble() * 100 - 50);
      final bird = Bird(
        speed: gameSpeed * 1.2,
        position: Vector2(250,  590),
      );
      add(bird);
    // }

    // В классе DinoGame добавляем метод для создания кактусов
    // void spawnGrass() {
      final grass = Grass(
        speed: gameSpeed,
        position: Vector2(250, size.y - 150), // Позиция на уровне земли
    );
    add(grass);
    // }

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