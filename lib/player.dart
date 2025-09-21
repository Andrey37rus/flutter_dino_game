import 'package:dino_runner/bird.dart';
import 'package:dino_runner/dino_game.dart';
import 'package:dino_runner/grass.dart';
import 'package:dino_runner/ground.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class Player extends SpriteAnimationComponent 
    with HasGameReference<DinoGame>, CollisionCallbacks {
  
  // Физика прыжка
  final double _gravity = 1000;
  final double _jumpSpeed = -700;
  double _velocity = 0;
  bool _isOnGround = true;
  bool isAlive = true;

  // ✅ Добавляем переменные для спрайтов и анимаций
  late SpriteAnimation _idleAnimation; // Анимация из одного кадра
  late SpriteAnimation _runningAnimation;

  Player({super.position}) : super(
    size: Vector2.all(70),
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
      [idleFrame], // ✅ Всего один кадр для "статичного" состояния
      stepTime: 1.0, // ✅ Длинный stepTime чтобы не мигало
      loop: false, // ✅ Не зацикливаем
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
      // ..renderShape = false // оставить для дебаг 
    );
    
    
    // Устанавливаем начальную позицию
    position = Vector2(100, game.size.y - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isAlive) return;
    
    _velocity += _gravity * dt;
    position.y += _velocity * dt;

    final groundLevel = game.size.y - 150;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
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
    // debugMode = true; //оставить для дебага
  }

  void jump() {
    if (_isOnGround && isAlive) {
      _velocity = _jumpSpeed;
      _isOnGround = false;
      
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
    
    if (other is Grass && isAlive || other is Bird && isAlive) {
      _handleObstacleCollision();
    }
  }

  void _handleObstacleCollision() {
    isAlive = false;

    // ✅ Меняем на "статичную" анимацию при столкновении
    _switchToIdleAnimation();

    // ✅ НЕМЕДЛЕННО останавливаем все движущиеся объекты
    _stopAllMovingObjects();

    // ✅ ВЫЗЫВАЕМ endGame() для завершения игры и скрытия кнопки паузы
    game.endGame(); 


    // Анимация смерти
    add(OpacityEffect.fadeOut(
      EffectController(
        duration: 1,
        alternate: true,
        repeatCount: 3,
      ),
    ));
  }

  // ✅ метод для остановки всех движущихся объектов
  void _stopAllMovingObjects() {
    final allCacti = game.children.whereType<Grass>();
    for (final cactus in allCacti) {
      cactus.speed = 0;
    }

    // final ground = game.children.whereType<InfiniteGround>().firstOrNull;
    // if (ground != null) {
    //   ground.speed = 0;
    // }

    final birds = game.children.whereType<Bird>();
    for (final bird in birds) {
      bird.speed = 0;
    }
  }

  void resetAnimation() {
    isAlive = true;
    animation = _runningAnimation; // Возвращаем анимацию бега
    opacity = 1.0; // Сбрасываем прозрачность
    // Удаляем все эффекты (если есть)
    removeWhere((component) => component is OpacityEffect);
  }
}