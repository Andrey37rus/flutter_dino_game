import 'package:flame/components.dart';

class Bird extends SpriteAnimationComponent with HasGameReference {
  final double speed;
  
  Bird({
    required this.speed,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(59, 36),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Загружаем 4 кадра анимации птицы
    final frame1 = await Sprite.load('birds/bird_frame_1.png');
    final frame2 = await Sprite.load('birds/bird_frame_2.png');
    final frame3 = await Sprite.load('birds/bird_frame_3.png');
    final frame4 = await Sprite.load('birds/bird_frame_4.png');
    
    // Создаем анимацию из четырех кадров
    animation = SpriteAnimation.spriteList(
      [frame1, frame2, frame3, frame4],
      stepTime: 0.15,
      loop: true,
    );
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
    
  //   // Простое движение птицы слева направо
  //   position.x -= speed * dt;
    
  //   // Если птица улетела за экран, удаляем ее
  //   if (position.x < -size.x) {
  //     removeFromParent();
  //   }
  // }
}