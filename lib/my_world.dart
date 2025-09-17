import 'package:dino_runner/player.dart';
import 'package:flame/components.dart';


class MyWorld extends World {
  // Этот метод вызывается один раз при запуске игры.
  // Пока он пустой, мы добавим в него логику позже.
  @override
  Future<void> onLoad() async {
    add(Player(position: Vector2(0, 0)));
  }
}