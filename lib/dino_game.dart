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
import 'package:dino_runner/score_display.dart';
import 'package:dino_runner/game_config.dart';
import 'package:dino_runner/start_screen.dart';
import 'package:dino_runner/sunny.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class DinoGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  InfiniteGround? _ground;
  InfiniteClouds? _cloud;
  Sun? _sun;
  Player? _player;

  Vector2? _gameSize;

  StartScreen? _startScreen;

  PauseButton? _pauseButton;

  ScoreDisplay? _scoreDisplay;

  bool gameStarted = false;
  bool isPaused = false;
  bool gameOver = false;

  Timer? _scoreTimer;
  Timer? obstacleTimer;

  var _currentScore = 0;

final Random random = Random();

  @override
  Color backgroundColor() => GameConfig.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final startScreen = StartScreen(onStartPressed: startGame);
    _startScreen = startScreen;
    add(_startScreen!);

    final ground = InfiniteGround(speed: GameConfig.groundSpeed);
    _ground = ground;
    add(ground);

    final cloud = InfiniteClouds(speed: GameConfig.cloudSpeed);
    _cloud = cloud;
    add(cloud);

    final sun = Sun();
    _sun = sun;
    add(sun);

    final player = Player();
    _player = player;
    add(player);

    final scoreDisplay = ScoreDisplay();
    _scoreDisplay = scoreDisplay;
    add(scoreDisplay);

  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _gameSize = size;

    updateAllElementsPosition();
  }

  void updateAllElementsPosition() {
    final gameSize = _gameSize;
    final ground = _ground;
    final cloud = _cloud;
    final sun = _sun;
    final player = _player;
    final scoreDisplay = _scoreDisplay;
    
    if (gameSize == null) return;
    
    if (ground != null && ground.isMounted) {
      ground.position = Vector2(0, gameSize.y * 0.7);
    }

    if (cloud != null && cloud.isMounted) {
      cloud.position = Vector2(gameSize.x * -0.50, gameSize.y * 0.2);
    }

    if (sun != null && sun.isMounted) {
      sun.position = Vector2(
        gameSize.x * 0.8 - sun.size.x / 2,
        gameSize.y * 0.20 - sun.size.y / 2,
      );
    }

    if (player != null && player.isMounted && ground != null && ground.isMounted) {
       final groundYOffset = GameConfig.groundYOffset;
      player.position = Vector2(
        gameSize.x * 0.1,
        ground.position.y - player.size.y - groundYOffset,
      );
    }

    if (scoreDisplay != null && scoreDisplay.isMounted) {
      scoreDisplay.position = Vector2(gameSize.x * 0.025, gameSize.y * 0.1);
    }
  }

  /// Запускает систему спавна препятствий
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
    final ground = _ground;
    if (ground != null) {
      final grass = Grass(
        speed: GameConfig.groundSpeed,
        position: Vector2(
          size.x * 1.0, // За пределами правого края экрана
          size.y - 175, // На уровне земли
        ),
      );
      add(grass);
    }
  }

  void spawnBird() {
    final bird = Bird(
      speed: GameConfig.groundSpeed * 1.5, // Птица летит быстрее
      position: Vector2(
        size.x * 1.0, // За пределами правого края экрана
        size.y * 0.6, // В воздухе
      ),
    );
    add(bird);
  }

  void startGame() {
    if (gameStarted) return;

    gameStarted = true;
    isPaused = false;
    gameOver = false;

    if (_startScreen != null) {
      remove(_startScreen!);
    }

    // Добавляем кнопку паузы
    _pauseButton = PauseButton(
      onPressed: togglePause,
      isPaused: isPaused,
      position: Vector2(
        _gameSize!.x - 60, 
        _gameSize!.y * 0.1
      ),
      size: Vector2(40, 40),
    );
    add(_pauseButton!);

    startTimerScore();
    startObstacleSpawning();

  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameStarted && !isPaused && _player != null && _player!.isAlive && !gameOver) {
      _player!.jump();
    }
    super.onTapDown(event);
  }

  void togglePause() {
    if (!gameStarted || gameOver || _pauseButton == null) return;

    isPaused = !isPaused;
    _pauseButton!.isPaused = isPaused;

    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  void startTimerScore() {
    _scoreTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      print('*******$_scoreTimer');
      if (gameStarted && !isPaused && !gameOver) {
        _currentScore++;
        _scoreDisplay?.updateScore(_currentScore);
      } 
    });
  }

  @override
  void onRemove() {
    // Очищаем ресурсы при удалении игры
    obstacleTimer?.cancel();
    _scoreTimer?.cancel(); 
    super.onRemove();
  }
}