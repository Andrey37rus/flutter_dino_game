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
import 'package:dino_runner/start_screen.dart';
import 'package:dino_runner/sunny.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class DinoGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // Игровые компоненты - используем nullable типы для безопасности
  Player? _player;
  InfiniteGround? _ground;
  InfiniteClouds? _clouds;
  Sun? _sun;
  StartScreen? _startScreen;
  PauseButton? _pauseButton;
  ScoreDisplay? _scoreDisplay;

  // Игровые параметры
  final double gameSpeed = 400;
  var _currentScore = 0;
  Timer? _scoreTimer;
  Timer? obstacleTimer;

  // Состояние игры
  bool gameStarted = false;
  bool isPaused = false;
  bool gameOver = false;

  final Random random = Random();

  @override
  Color backgroundColor() => const Color.fromARGB(255, 187, 177, 177);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print('DinoGame: onLoad called, initial size: $size');

    await FlameAudio.audioCache.loadAll([
      'fon_music.mp3',
      'jump.mp3',
      'game_over.mp3',
    ]);

    // Запуск фоновой музыки
    FlameAudio.bgm.play('fon_music.mp3');

    // Инициализируем все игровые компоненты
    _ground = InfiniteGround(speed: gameSpeed);
    _clouds = InfiniteClouds(speed: gameSpeed);
    _sun = Sun();
    _player = Player();
    _startScreen = StartScreen(onStartPressed: startGame);
    _scoreDisplay = ScoreDisplay();

    // Добавляем компоненты в игру
    add(_ground!);
    add(_clouds!);
    add(_sun!);
    add(_player!);
    add(_startScreen!);
    add(_scoreDisplay!);

    // Обновляем позиции элементов после добавления
    updateAllElementsPosition();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    print('DinoGame: screen resized to: $size');

    // Обновляем позиции всех элементов при изменении размера экрана
    // Проверяем, что компоненты уже инициализированы
    if (_ground != null) {
      updateAllElementsPosition();
    }
  }

  /// Обновляет позиции всех игровых элементов относительно текущего размера экрана
  void updateAllElementsPosition() {
    // Проверяем, что все компоненты инициализированы
    if (_ground == null || _clouds == null || _player == null) return;

    // Земля - в нижней части экрана
    if (_ground!.isMounted) {
      _ground!.position = Vector2(0, size.y * 0.7);
    }

    // Облака - в верхней части экрана
    if (_clouds!.isMounted) {
      _clouds!.position = Vector2(size.x * -0.50, size.y * 0.2);
    }

    // ✅ Солнце - в правой верхней части экрана
    if (_sun!.isMounted) {
      _sun!.position = Vector2(
        size.x * 0.8 - _sun!.size.x / 2, // 80% ширины, центрируем
        size.y * 0.15 - _sun!.size.y / 2, // 15% высоты, центрируем
      );
    }


    // ✅ Игрок - в левой части экрана ЧУТЬ НИЖЕ ЗЕМЛИ
    if (_player!.isMounted && _ground!.isMounted) {
      _player!.groundYOffset = 20; // Устанавливаем смещение
      
      _player!.position = Vector2(
        size.x * 0.1,
        _ground!.position.y - _player!.size.y + _player!.groundYOffset,
      );
    }

    // Кнопка паузы - в правом верхнем углу (если существует)
    if (_pauseButton?.isMounted == true) {
      _pauseButton!.position = Vector2(size.x - 60, size.y * 0.1);
    }
    // Отображение очков в левом верхнем углу 
    if (_scoreDisplay?.isMounted == true) {
      _scoreDisplay!.position = Vector2(size.x * 0.025, size.y * 0.1);
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

  void startTimerScore() {
    // Инициализируем таймер очков (но не запускаем сразу)
    _scoreTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      print('Ilog очки: $_currentScore');
      if (gameStarted && !isPaused && !gameOver) {
        _currentScore++;
        _scoreDisplay?.updateScore(_currentScore);
      }
    });
  }

  /// Создает препятствие "трава"
  void spawnGrass() {
    final grass = Grass(
      speed: gameSpeed,
      position: Vector2(
        size.x + 50, // За пределами правого края экрана
        size.y - 175, // На уровне земли
      ),
    );
    add(grass);
  }

  /// Создает препятствие "птица"
  void spawnBird() {
    final bird = Bird(
      speed: gameSpeed * 1.2, // Птица летит быстрее
      position: Vector2(
        size.x * 1.0, // За пределами правого края экрана
        size.y * 0.6, // В воздухе
      ),
    );
    add(bird);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Обработка прыжка игрока при тапе
    if (gameStarted && !isPaused && _player != null && _player!.isAlive && !gameOver) {
      _player!.jump();
    }
    super.onTapDown(event);
  }

  /// Запускает игру (вызывается из стартового экрана)
  void startGame() {
    if (gameStarted) return;

    print('DinoGame: starting game');
    gameStarted = true;
    isPaused = false;
    gameOver = false;
    _currentScore = 0;
    _scoreDisplay?.reset();

    // Убираем стартовый экран
    if (_startScreen != null) {
      remove(_startScreen!);
    }

    // Добавляем кнопку паузы
    _pauseButton = PauseButton(
      onPressed: togglePause,
      isPaused: isPaused,
      position: Vector2(size.x - 60, size.y * 0.1),
      size: Vector2(40, 40),
    );
    add(_pauseButton!);

    // Запускаем спавн препятствий
    startObstacleSpawning();

    // Запускаем счет очков
    startTimerScore();

    resumeEngine();
  }

  /// Переключает состояние паузы
  void togglePause() {
    if (!gameStarted || gameOver || _pauseButton == null) return;

    isPaused = !isPaused;
    _pauseButton!.isPaused = isPaused;

    if (isPaused) {
      pauseEngine();
      print('DinoGame: game paused');
    } else {
      resumeEngine();
      print('DinoGame: game resumed');
    }
  }

  /// Завершает игру
  void endGame() {
    if (gameOver) return;

    print('DinoGame: game over');
    gameOver = true;
    isPaused = true;

    // ✅ Останавливаем землю
    if (_ground != null) {
      _ground!.stop();
    }

    // ✅ Останавливаем облака
    if (_clouds != null) {
      _clouds!.stop();
    }

    // Убираем кнопку паузы
    if (_pauseButton?.isMounted == true) {
      remove(_pauseButton!);
    }

    // Останавливаем таймер препятствий
    obstacleTimer?.cancel();

    // Показываем экран "Game Over"
    showGameOverWithDelay();
  }

  /// Показывает экран "Game Over" с задержкой
  void showGameOverWithDelay() {
    final gameOverScreen = GameOverText(score: _currentScore);
    add(gameOverScreen);

    // Через 2 секунды перезапускаем игру
    Timer(const Duration(seconds: 2), () {
      if (gameOver) {
        resetGame();
      }
    });
  }

  /// Сбрасывает игру в начальное состояние
  void resetGame() {
    print('DinoGame: resetting game');

    // Очищаем все препятствия
    children.whereType<Grass>().forEach(remove);
    children.whereType<Bird>().forEach(remove);

    // Удаляем экран "Game Over"
    children.whereType<GameOverText>().forEach(remove);

    // Сбрасываем анимацию игрока
    if (_player != null) {
      _player!.resetAnimation();
    }

    // Сбрасываем состояние игры
    gameStarted = false;
    gameOver = false;
    isPaused = false;
    _currentScore = 0; // Сбрасываем очки
    _scoreDisplay?.reset();

    // ✅ Запускаем землю
    if (_ground != null) {
      _ground!.start(gameSpeed);
    }

    // ✅ Запускаем облака
    if (_clouds != null) {
      _clouds!.start(gameSpeed);
    }


    // Показываем стартовый экран
    if (_startScreen != null && !_startScreen!.isMounted) {
      add(_startScreen!);
    }

    // Перезапускаем движок
    resumeEngine();
  }

  

  @override
  void onRemove() {
    // Очищаем ресурсы при удалении игры
    obstacleTimer?.cancel();
    _scoreTimer?.cancel(); 
    super.onRemove();
  }
}