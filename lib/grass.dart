import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Grass extends SpriteComponent with HasGameReference, CollisionCallbacks {
  double speed;
  
  Grass({
    required this.speed,
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(60, 80), // Размер кактуса
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Загружаем одну картинку кактуса
    sprite = await Sprite.load('grass/grass_big.png');


    // Добавляем хитбокс для кактуса
    add(RectangleHitbox(
      size: Vector2(width * 0.8, height * 0.9),
      position: Vector2(width * 0.1, height * 0.1),
    )..collisionType = CollisionType.passive // Оптимизация производительности
      // ..renderShape = true // оставить для дебаг
    ); 
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Движение кактуса слева направо
    position.x -= speed * dt;
    
    // Если кактус ушел за экран, удаляем его
    if (position.x < -size.x) {
      removeFromParent();
    }
    // debugMode = true; // оставить для дебаг
  }
}