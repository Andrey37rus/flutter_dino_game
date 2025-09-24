import 'package:dino_runner/bird.dart';
import 'package:dino_runner/dino_game.dart';
import 'package:dino_runner/grass.dart';
import 'package:dino_runner/ground.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';

class Player extends SpriteAnimationComponent 
    with HasGameReference<DinoGame>, CollisionCallbacks {
  
  // Физика прыжка
  final double _gravity = 1000;
  final double _jumpSpeed = -450;
  double _velocity = 0;
  bool _isOnGround = true;
  bool isAlive = true;
  double groundYOffset = 0; // ✅ Добавляем свойство для смещения

  double get _groundLevel {
    final ground = game.children.whereType<InfiniteGround>().firstOrNull;
    if (ground != null) {
      return ground.position.y - size.y + groundYOffset; // ✅ Используем смещение
    }
    return position.y;
  }

  // Анимации
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _runningAnimation;

  Player({super.position}) : super(
    size: Vector2.all(60), // Размер игрока
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ Загружаем все текстуры
    final idleFrame = await Sprite.load('player/new_dino_frame_1.png');
    final frame2 = await Sprite.load('player/new_dino_frame_2.png');
    final frame3 = await Sprite.load('player/new_dino_frame_3.png');
    
    // Создаем анимации
    _idleAnimation = SpriteAnimation.spriteList(
      [idleFrame], // Один кадр для "статичного" состояния
      stepTime: 1.0, // Длинный stepTime чтобы не мигало
      loop: false, // Не зацикливаем
    );
    
    _runningAnimation = SpriteAnimation.spriteList(
      [frame2, frame3],
      stepTime: 0.1,
      loop: true,
    );

    // Начинаем с анимации бега
    animation = _runningAnimation;

    // Добавляем хитбокс
    add(RectangleHitbox(
      size: Vector2(width * 0.7, height * 0.6),
      position: Vector2(width * 0.15, height * 0.2),
    )..collisionType = CollisionType.active
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isAlive) return;
    
    // ✅ Применяем гравитацию
    _velocity += _gravity * dt;
    position.y += _velocity * dt;

    // ✅ Динамически вычисляем уровень земли каждый кадр
    final currentGroundLevel = _groundLevel;

    // ✅ Проверяем столкновение с землей
    if (position.y >= currentGroundLevel) {
      position.y = currentGroundLevel;
      _velocity = 0;
      _isOnGround = true;
      
      // ✅ Возвращаем анимацию бега при приземлении
      if (isAlive && animation != _runningAnimation) {
        animation = _runningAnimation;
      }
    } else {
      _isOnGround = false;
      
      // ✅ Меняем на "статичную" анимацию в прыжке
      if (isAlive && animation != _idleAnimation) {
        _switchToIdleAnimation();
      }
    }
  }

  /// Прыжок игрока
  void jump() {
    if (_isOnGround && isAlive) {
      _velocity = _jumpSpeed;
      _isOnGround = false;
      FlameAudio.play('jump.mp3');
      
      // ✅ Меняем на "статичную" анимацию при прыжке
      _switchToIdleAnimation();
    }
  }

  // ✅ Метод для переключения на "статичную" анимацию
  void _switchToIdleAnimation() {
    animation = _idleAnimation;
  }

  // ✅ Метод для возврата к анимации бега
  void _switchToRunningAnimation() {
    animation = _runningAnimation;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints, 
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // ✅ Обрабатываем столкновение с препятствиями
    if ((other is Grass || other is Bird) && isAlive) {
      // ✅ Воспроизводим звук столкновения
      FlameAudio.play('game_over.mp3');
      _handleObstacleCollision();
    }
  }

  /// Обработка столкновения с препятствием
  void _handleObstacleCollision() {
    isAlive = false;

    // ✅ Меняем на "статичную" анимацию при столкновении
    _switchToIdleAnimation();

    // ✅ Останавливаем все движущиеся объекты
    _stopAllMovingObjects();

    // ✅ Завершаем игру
    game.endGame();

    // Анимация смерти (мигание)
    add(OpacityEffect.fadeOut(
      EffectController(
        duration: 1,
        alternate: true,
        repeatCount: 3,
      ),
    ));
  }

  /// Останавливает все движущиеся объекты в игре
  void _stopAllMovingObjects() {
    // Останавливаем кактусы
    final allCacti = game.children.whereType<Grass>();
    for (final cactus in allCacti) {
      cactus.speed = 0;
    }

    // Останавливаем птиц
    final birds = game.children.whereType<Bird>();
    for (final bird in birds) {
      bird.speed = 0;
    }

    // Останавливаем землю (если нужно)
    // final ground = game.children.whereType<InfiniteGround>().firstOrNull;
    // if (ground != null) {
    //   ground.speed = 0;
    // }
  }

  /// Сбрасывает анимацию игрока при рестарте игры
  void resetAnimation() {
    isAlive = true;
    animation = _runningAnimation; // Возвращаем анимацию бега
    opacity = 1.0; // Сбрасываем прозрачность
    
    // Удаляем все эффекты
    removeWhere((component) => component is Effect);
    
    // Сбрасываем физику
    _velocity = 0;
    _isOnGround = true;
  }

  /// Для отладки: получает текущую позицию земли
  double getDebugGroundLevel() {
    final ground = game.children.whereType<InfiniteGround>().firstOrNull;
    return ground?.position.y ?? 0;
  }
}