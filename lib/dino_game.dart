import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:dino_runner/bird.dart';
import 'package:dino_runner/cloud.dart';
import 'package:dino_runner/control_button/pause_button.dart';
import 'package:dino_runner/grass.dart';
import 'package:dino_runner/ground.dart';
import 'package:dino_runner/player.dart';
import 'package:dino_runner/start_screen.dart';
import 'package:dino_runner/sunny.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

class DinoGame extends FlameGame with TapCallbacks, HasCollisionDetection {

  late final Player player;
  late final InfiniteGround ground;
  late final InfiniteClouds clouds;
  late final Sun sun;

  late StartScreen startScreen;
  late PauseButton pauseButton;

  final double gameSpeed = 300;

  late Timer obstacleTimer;


  bool gameStarted = false;
  bool isPaused = false;
  bool gameOver = false;
 
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


    // Создаем стартовый экран
    startScreen = StartScreen(
      onStartPressed: startGame,
      gameSize: size,
    );
    add(startScreen);
  }

  // Метод по таймеру спавнит препятсвие
  void startObstacleSpawning() {
    void scheduleNextSpawn() {
      final randomDuration = Duration(seconds: random.nextInt(4) + 3);
      
      obstacleTimer = Timer(randomDuration, () {
        if (!isPaused && gameStarted && !gameOver) { // Проверяем что игра не на паузе
          // Спавним случайное препятствие
          if (random.nextBool()) {
            spawnGrass();
          } else {
            spawnBird();
          }
        }
        // Планируем следующий спавн
        scheduleNextSpawn();
      });
    }
    // Запускаем первый спавн
    scheduleNextSpawn();
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
      position: Vector2(size.x + 50, 650), // Спавним за пределами экрана справа
    );
    add(bird);
  }

  // Этот метод срабатывает при тапе в ЛЮБОМ месте экрана
  @override
  void onTapDown(TapDownEvent event) {
    if (gameStarted && !isPaused && player.isAlive && !gameOver) {
      player.jump();
    }
    super.onTapDown(event);
  }

  // Start Game
  void startGame() {
    if (gameStarted) return;

    gameStarted = true;
    isPaused = false;
    gameOver = false;
  
    // Удаляем стартовый экран
    remove(startScreen);

    // Добавляем кнопку паузы в правый верхний угол
    pauseButton = PauseButton(
      onPressed: togglePause,
      isPaused: isPaused,
      position: Vector2(size.x - 60, 80), // Позиция в правом верхнем углу
      size: Vector2(40, 40), // Размер кнопки
    );
    add(pauseButton);
    
    // Запускаем спавн препятствий
    startObstacleSpawning();
    
    resumeEngine();
  }

  // Метод для переключения паузы
  void togglePause() {
    if (!gameStarted || gameOver) return; // Нельзя поставить на паузу если игра не началась

    isPaused = !isPaused;

    // ОБНОВЛЯЕМ состояние кнопки!
    pauseButton.isPaused = isPaused;

    
    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  // Метод завершения игры (вызывается при столкновении)
  void endGame() {
    if (gameOver) return;

    gameOver = true;
    isPaused = true;
    
    // Удаляем кнопку паузы
    if (pauseButton.isMounted) {
      remove(pauseButton);
    }
    
    // Останавливаем спавн препятствий
    obstacleTimer.cancel();
    
    // // Ставим игру на паузу
    // pauseEngine();
    
    // Здесь позже добавим экран Game Over
    print('Game Over!');
  }

  // Не забываем освободить ресурсы таймера
  @override
  void onRemove() {
    obstacleTimer.cancel();
    super.onRemove();
  }
}