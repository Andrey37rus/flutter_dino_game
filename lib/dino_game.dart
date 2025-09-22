import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:dino_runner/bird.dart';
import 'package:dino_runner/cloud.dart';
import 'package:dino_runner/control_button/pause_button.dart';
import 'package:dino_runner/game_over_text.dart';
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
    
    ground = InfiniteGround(
      speed: gameSpeed,
      position: Vector2(
        0, 
        size.y  *  0.7,
      ),
    );
    add(ground);

    clouds = InfiniteClouds(
      speed: gameSpeed,
      position: Vector2(
        size.x *  - 0.50,
        size.y * 0.2,
      ),
    );
    add(clouds);

    sun = Sun(position: Vector2(
      size.x * 0.8,
      size.y * 0.15,
    ));
    add(sun);

    player = Player(position: Vector2(
      size.x * 0.1, 
      size.y * 0.59,
    ));
    add(player);

    startScreen = StartScreen(
      onStartPressed: startGame,
      gameSize: size,
    );
    add(startScreen);
  }

  void startObstacleSpawning() {
    void scheduleNextSpawn() {
      final randomDuration = Duration(seconds: random.nextInt(4) + 3);
      
      obstacleTimer = Timer(randomDuration, () {
        if (!isPaused && gameStarted && !gameOver) {
          if (random.nextBool()) {
            spawnGrass();
          } else {
            spawnBird();
          }
        }
        scheduleNextSpawn();
      });
    }
    scheduleNextSpawn();
  }

  void spawnGrass() {
    final grass = Grass(
      speed: gameSpeed,
      position: Vector2(
        size.x + 50, 
        size.y - 175
      ),
    );
    add(grass);
  }

  void spawnBird() {
    final bird = Bird(
      speed: gameSpeed * 1.2,
      position: Vector2(
        size.x * 1.0, 
        size.y * 0.6,
      ),
    );
    add(bird);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameStarted && !isPaused && player.isAlive && !gameOver) {
      player.jump();
    }
    super.onTapDown(event);
  }

  void startGame() {
    if (gameStarted) return;

    gameStarted = true;
    isPaused = false;
    gameOver = false;
  
    remove(startScreen);

    pauseButton = PauseButton(
      onPressed: togglePause,
      isPaused: isPaused,
      position: Vector2(
        size.x - 60, 
        size.y * 0.1
      ),
      size: Vector2(40, 40),
    );
    add(pauseButton);
    
    startObstacleSpawning();
    resumeEngine();
  }

  void togglePause() {
    if (!gameStarted || gameOver) return;

    isPaused = !isPaused;
    pauseButton.isPaused = isPaused;
    
    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  void endGame() {
    if (gameOver) return;

    gameOver = true;
    isPaused = true;
    
    if (pauseButton.isMounted) {
      remove(pauseButton);
    }
    
    obstacleTimer.cancel();
    showGameOverWithDelay();
  }

  void showGameOverWithDelay() {
    final gameOverScreen = GameOverText(gameSize: size);
    add(gameOverScreen);

    Timer(const Duration(seconds: 2), () {
      if (gameOver) {
        resetGame();
      }
    });
  }

  void resetGame() {
    // Очищаем все препятствия
    children.whereType<Grass>().forEach(remove);
    children.whereType<Bird>().forEach(remove);
    
    // Удаляем Game Over экран
    children.whereType<GameOverText>().forEach(remove);

    // Сбрасываем анимацию игрока
    player.resetAnimation();
    
    // Сбрасываем состояние игры
    gameStarted = false;
    gameOver = false;
    isPaused = false;
    
    // Показываем стартовый экран
    add(startScreen);
    
    // Перезапускаем движок
    resumeEngine();
    
    print('Game reset to start screen');
  }

  @override
  void onRemove() {
    obstacleTimer.cancel();
    super.onRemove();
  }
}