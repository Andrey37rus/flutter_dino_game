import 'package:flame/components.dart';

class Sun extends SpriteAnimationComponent with HasGameReference {
  Sun({
    required Vector2 position,
  }) : super(
        position: position,
        size: Vector2(92, 84), // Размер солнца
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Загружаем 2 кадра солнца
    final frame1 = await Sprite.load('sunny/sunny_frame_1.png');
    final frame2 = await Sprite.load('sunny/sunny_frame_2.png');
    
    // Создаем анимацию из двух кадров с интервалом 0.5 секунды
    animation = SpriteAnimation.spriteList(
      [frame1, frame2],
      stepTime: 0.5, // Смена кадра каждые полсекунды
      loop: true,
    );
  }
}