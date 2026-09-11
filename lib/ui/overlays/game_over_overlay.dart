import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import 'overlay_widgets.dart';

/// 本局结束后显示成绩和后续操作的页面。
class GameOverOverlay extends StatelessWidget {
  /// 创建游戏结束页面。
  const GameOverOverlay({super.key, required this.game});

  /// 当前游戏实例，用于读取本局分数和最高分。
  final DodgeGame game;

  /// 构建成绩、重新开始和返回主菜单按钮。
  @override
  Widget build(BuildContext context) {
    // 只有本局分数超过历史记录时才显示 New Best。
    final isNewBest = game.wasNewBest;
    return OverlayScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OverlayTitle(
            isNewBest ? 'New Best!' : 'Game Over',
            subtitle: isNewBest ? 'You beat your record!' : null,
          ),
          const SizedBox(height: 24),
          _StatRow(label: 'Score', value: '${game.score}'),
          const SizedBox(height: 8),
          _StatRow(label: 'Best', value: '${game.highScore}'),
          const SizedBox(height: 28),
          GameButton(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            primary: true,
            onPressed: game.restart,
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

/// 游戏结束页面中的一行统计数据。
class _StatRow extends StatelessWidget {
  /// 创建一行标签和值。
  const _StatRow({required this.label, required this.value});

  /// 左侧统计名称。
  final String label;

  /// 右侧统计数值。
  final String value;

  /// 构建左右对齐的统计行。
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 18),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
