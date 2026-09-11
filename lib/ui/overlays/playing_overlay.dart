import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';

/// 游戏进行中显示在右上角的暂停按钮。
class PauseButton extends StatelessWidget {
  /// 创建暂停按钮。
  const PauseButton({super.key, required this.game});

  /// 当前游戏实例。
  final DodgeGame game;

  /// 构建右上角的暂停按钮。
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton.filledTonal(
            onPressed: game.togglePause,
            tooltip: 'Pause (P)',
            iconSize: 26,
            icon: const Icon(Icons.pause_rounded),
          ),
        ),
      ),
    );
  }
}
