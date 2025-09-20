import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:dino_runner/bird.dart';
import 'package:dino_runner/cloud.dart';
import 'package:dino_runner/grass.dart';
import 'package:dino_runner/ground.dart';
import 'package:dino_runner/player.dart';
import 'package:dino_runner/sunny.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

class DinoGame extends FlameGame with TapCallbacks, HasCollisionDetection {

  late final Player player;
  late final InfiniteGround ground;
  late final InfiniteClouds clouds;
  late final Sun sun;
  final double gameSpeed = 300;

    // таймер для спавна кактуса
  late Timer cactusTimer;
  late Timer birdTimer;

    // Random для случайной высоты птиц
  final Random random = Random();

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

    // Создаем бесконечные облака
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

    player = Player(position: Vector2(0, -100));
    add(player); // Добавляем в игру


    // Запускаем таймер для спавна кактусов
    startCactusSpawning();

    // Запуск таймера для спавна птиц
    startBirdSpawning();
  }

  // Метод для запуска таймера кактуса
  void startCactusSpawning() {
    cactusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      spawnGrass();
    });
  }

  // Метод для запуска таймера птицы
  void startBirdSpawning() {
    birdTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      spawnBird();
    });
  }

  // Метод для создания кактусов
  void spawnGrass() {
    final grass = Grass(
      speed: gameSpeed,
      position: Vector2(size.x + 50, size.y - 150), // Спавним за пределами экрана справа
    );
    add(grass);
  }

  void spawnBird() {
    final bird = Bird(
      speed: gameSpeed * 1.2,
      position: Vector2(size.x + 50, 600),
    );
    add(bird);
  }

  // Этот метод срабатывает при тапе в ЛЮБОМ месте экрана
  @override
  void onTapDown(TapDownEvent event) {
    if (player.isAlive) {
      player.jump();
    }
    super.onTapDown(event);
  }

  // Не забываем освободить ресурсы таймера
  @override
  void onRemove() {
    cactusTimer.cancel();
    birdTimer.cancel();
    super.onRemove();
  }
}