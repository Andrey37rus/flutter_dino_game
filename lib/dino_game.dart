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

  Vector2? _gameSize;

  StartScreen? _startScreen;

  PauseButton? _pauseButton;

    // Состояние игры
  bool gameStarted = false;
  bool isPaused = false;
  bool gameOver = false;

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
    
    if (gameSize == null) return;
    
    if (ground != null && ground.isMounted) {
      ground.position = Vector2(0, gameSize.y * 0.7);
    }
  }

  void startGame() {
    if (gameStarted) return;

    gameStarted = true;
    isPaused = false;
    gameOver = false;

    // Убираем стартовый экран
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
}