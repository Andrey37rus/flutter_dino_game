import 'package:flame/components.dart';

class InfiniteClouds extends PositionComponent with HasGameReference {
  double speed;
  late final Sprite cloudSprite;
  final List<CloudTile> tiles = [];

  InfiniteClouds({
    required this.speed,
    super.position,
  });
  

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Загружаем текстуру облака
    cloudSprite = await Sprite.load('clouds/cloud.png');
    
    // Определяем размер облака (под размер вашего изображения)
    final cloudSize = Vector2(320, 80);
    
    // Создаем 3 облака для бесконечного эффекта
    for (var i = 0; i < 3; i++) {
      final cloudTile = CloudTile(
        sprite: cloudSprite,
        position: Vector2(i * cloudSize.x * 2, 0), // Больший интервал между облаками
        size: cloudSize,
      );
      add(cloudTile);
      tiles.add(cloudTile);
    }
  }

    // ✅ Метод для остановки движения
    void stop() {
      speed = 0;
    }

    // ✅ Метод для возобновления движения
    void start(double newSpeed) {
      speed = newSpeed;
    }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Двигаем все облака (медленнее, чем дорога)
    final cloudSpeed = speed * 0.3; // Облака движутся в 3 раза медленнее дороги
    
    for (final tile in tiles) {
      tile.position.x -= cloudSpeed * dt;
      
      // Если облако ушло за экран, перемещаем его в конец
      if (tile.position.x <= -tile.size.x) {
        tile.position.x += tiles.length * tile.size.x * 2; // Учитываем интервал
      }
    }
  }
}

class CloudTile extends SpriteComponent {
  CloudTile({
    required super.sprite,
    required super.position,
    required super.size,
  });
}