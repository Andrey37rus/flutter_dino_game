import 'package:flame/components.dart';

class InfiniteGround extends PositionComponent with HasGameReference {
  final double speed;
  late final Sprite groundSprite;
  final List<GroundTile> tiles = [];

  InfiniteGround({
    required this.speed,
    super.position,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Загружаем текстуру дороги
    groundSprite = await Sprite.load('road_frame.png');
    
    // Определяем размер дороги (под размер вашего изображения)
    final groundSize = Vector2(500, 200);
    
    // Создаем 3 плитки дороги для бесконечного эффекта
    for (var i = 0; i < 3; i++) {
      final groundTile = GroundTile(
        sprite: groundSprite,
        position: Vector2(i * groundSize.x, 0),
        size: groundSize,
      );
      add(groundTile);
      tiles.add(groundTile);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Двигаем все плитки дороги
    for (final tile in tiles) {
      tile.position.x -= speed * dt;
      
      // Если плитка ушла за экран, перемещаем ее в конец
      if (tile.position.x <= -tile.size.x) {
        tile.position.x += tiles.length * tile.size.x;
      }
    }
  }
}

class GroundTile extends SpriteComponent {
  GroundTile({
    required super.sprite,
    required super.position,
    required super.size,
  });
}