import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import 'overlay_widgets.dart';

/// 游戏启动后的待开始界面。
class ReadyOverlay extends StatelessWidget {
  /// 创建待开始界面。
  const ReadyOverlay({super.key, required this.game});

  /// 当前游戏实例，用于响应按钮操作和读取最高分。
  final DodgeGame game;

  /// 构建标题、开始按钮、设置按钮和最高分。
  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OverlayTitle(
            'NEW WORLD',
            subtitle:
                'Dodge the falling blocks!\n'
                '← → ↑ ↓ / WASD to move · Shift to boost · P to pause',
          ),
          const SizedBox(height: 28),
          GameButton(
            label: 'Start Game',
            icon: Icons.play_arrow_rounded,
            primary: true,
            onPressed: game.start,
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Settings',
            icon: Icons.settings_outlined,
            onPressed: game.openSettings,
          ),
          const SizedBox(height: 20),
          Text(
            'Best: ${game.highScore}',
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
