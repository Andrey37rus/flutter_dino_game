import 'package:flame/components.dart';


class Player extends SpriteAnimationComponent with HasGameReference {
  // Физика прыжка
  final double _gravity = 1000;
  final double _jumpSpeed = -700;
  double _velocity = 0;
  bool _isOnGround = true;

  Player({super.position}) : super(
    size: Vector2.all(200),
    anchor: Anchor.bottomCenter, // Якорь внизу для правильных прыжков
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Загружаем обе текстуры
    final frame1 = await Sprite.load('dino_frame_1.png');
    final frame2 = await Sprite.load('dino_frame_2.png');
    
    // Создаем анимацию из двух кадров
    animation = SpriteAnimation.spriteList(
      [frame1, frame2],
      stepTime: 0.1,
      loop: true,
    );
    
    // Устанавливаем начальную позицию на земле
    position = Vector2(100, game.size.y - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Обновляем физику прыжка
    _velocity += _gravity * dt;
    position.y += _velocity * dt;

    // Проверяем, стоит ли на земле (динамически относительно размера экрана)
    final groundLevel = game.size.y - 150;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      _velocity = 0;
      _isOnGround = true;
    } else {
      _isOnGround = false;
    }
  }

  void jump() {
    if (_isOnGround) {
      _velocity = _jumpSpeed;
      _isOnGround = false;
    }
  }
}