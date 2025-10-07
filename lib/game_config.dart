import 'dart:ui';

class GameConfig {
  // Цвета
  static const backgroundColor = Color.fromARGB(255, 187, 177, 177);
  
  // Скорости
  static const double groundSpeed = 400;
  static const double cloudSpeed = 300;

  // Относительная позиция обьектов к земле (смещение обьектов чуть ниже земли)
  static const double groundYOffset = 18;

  
  // Размеры
  static const double playerWidth = 50;
  static const double playerHeight = 80;
  static const double groundHeight = 100;
  
  // Прочие настройки
  static const double gravity = 500;
  static const double jumpForce = -600;
}