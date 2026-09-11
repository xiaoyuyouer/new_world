import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/dodge_game.dart';
import '../ui/game_overlays.dart';

/// Dodge 游戏对应的 Flutter 应用外壳。
///
/// Flutter 负责应用生命周期和 UI，Flame 负责游戏画面和游戏循环。
class DodgeApp extends StatefulWidget {
  /// 创建应用 Widget。
  const DodgeApp({super.key});

  /// 创建应用对应的可变状态对象。
  @override
  State<DodgeApp> createState() => _DodgeAppState();
}

/// 保存游戏实例的状态对象。
class _DodgeAppState extends State<DodgeApp> {
  /// 游戏实例只创建一次，避免 Flutter 重建时丢失游戏进度。
  final DodgeGame _game = DodgeGame();

  /// 构建 Flutter 页面，并把 Flame 游戏嵌入页面中。
  @override
  Widget build(BuildContext context) {
    // GameWidget 是 Flutter 和 Flame 之间的桥梁。
    return MaterialApp(
      title: 'New World',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<DodgeGame>(
          // 使用同一个游戏实例，避免页面重建导致游戏状态丢失。
          game: _game,
          // 注册不同游戏状态对应的 Flutter Overlay。
          overlayBuilderMap: gameOverlayBuilders,
        ),
      ),
    );
  }
}
