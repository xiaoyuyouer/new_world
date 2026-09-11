import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import 'overlay_widgets.dart';

/// 游戏暂停时显示的操作菜单。
class PausedOverlay extends StatelessWidget {
  /// 创建暂停菜单。
  const PausedOverlay({super.key, required this.game});

  /// 当前游戏实例。
  final DodgeGame game;

  /// 构建继续、重开、设置和返回主菜单按钮。
  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OverlayTitle('Paused'),
          const SizedBox(height: 28),
          GameButton(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            primary: true,
            onPressed: game.togglePause,
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            onPressed: game.restart,
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Settings',
            icon: Icons.settings_outlined,
            onPressed: game.openSettings,
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Main Menu',
            icon: Icons.home_outlined,
            onPressed: game.backToMenu,
          ),
        ],
      ),
    );
  }
}
