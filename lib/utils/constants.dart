import 'package:flutter/material.dart';

class GameConstants {
  const GameConstants._();

  static const appTitle = 'LA SENDA: El descenso';
  static const coverImage = 'assets/images/la_senda_cover.png';
  static const tileSize = 32.0;
  static const pixelCornerRadius = 3.0;
  static const torchLightRadiusInTiles = 4.5;
  static const darknessOpacity = .94;
}

class GameColors {
  const GameColors._();

  static const cave = Color(0xFF0B0D0E);
  static const darkness = Color(0xFF0B0D0E);
  static const stone = Color(0xFF211F1B);
  static const stoneEdge = Color(0xFF59442E);
  static const wood = Color(0xFF593A27);
  static const woodLight = Color(0xFFB77C3D);
  static const torch = Color(0xFFFFB94A);
  static const flame = Color(0xFFC47735);
  static const parchment = Color(0xFFF0D7A0);
  static const error = Color(0xFFD65A42);
}
