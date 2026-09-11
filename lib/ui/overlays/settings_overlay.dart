import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import '../../models/game_settings.dart';
import 'overlay_widgets.dart';

/// 修改难度、速度、回合时间和生命数的设置页面。
class SettingsOverlay extends StatefulWidget {
  /// 创建设置页面。
  const SettingsOverlay({super.key, required this.game});

  /// 当前游戏实例。
  final DodgeGame game;

  /// 创建设置页面的可变状态对象。
  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

/// SettingsOverlay 的内部编辑状态。
class _SettingsOverlayState extends State<SettingsOverlay> {
  /// 用户正在编辑的临时设置。
  ///
  /// 在点击 Back 之前只修改草稿，不立即影响游戏。
  late GameSettings _draft = widget.game.settings;

  /// 更新草稿并刷新设置页面。
  void _update(GameSettings next) {
    setState(() => _draft = next);
  }

  /// 关闭设置页面；如果草稿有变化，则应用新设置并重开一局。
  void _close() {
    // 有改动则应用设置；没有改动则只返回原来的界面。
    if (_draft == widget.game.settings) {
      widget.game.closeSettings();
    } else {
      widget.game.applySettings(_draft);
    }
  }

  /// 构建所有设置选项和操作按钮。
  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
      maxWidth: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OverlayTitle('Settings'),
          const SizedBox(height: 16),
          // 难度选项。
          ChoiceRow<Difficulty>(
            label: 'Difficulty',
            options: Difficulty.values,
            value: _draft.difficulty,
            labelOf: (difficulty) => difficulty.label,
            onChanged: (difficulty) =>
                _update(_draft.copyWith(difficulty: difficulty)),
          ),
          const SizedBox(height: 16),
          // 玩家速度倍率选项。
          ChoiceRow<double>(
            label: 'Player Speed',
            options: GameSettings.playerSpeedOptions,
            value: _draft.playerSpeedMultiplier,
            labelOf: (speed) => '${speed}x',
            onChanged: (speed) =>
                _update(_draft.copyWith(playerSpeedMultiplier: speed)),
          ),
          const SizedBox(height: 16),
          // 单局时长选项。
          ChoiceRow<int>(
            label: 'Round Time',
            options: GameSettings.roundDurationOptions,
            value: _draft.roundDuration,
            labelOf: (seconds) => '${seconds}s',
            onChanged: (seconds) =>
                _update(_draft.copyWith(roundDuration: seconds)),
          ),
          const SizedBox(height: 16),
          // 最大生命数选项。
          ChoiceRow<int>(
            label: 'Lives',
            options: GameSettings.maxLivesOptions,
            value: _draft.maxLives,
            labelOf: (lives) => '$lives',
            onChanged: (lives) => _update(_draft.copyWith(maxLives: lives)),
          ),
          const SizedBox(height: 22),
          GameButton(
            label: 'Back',
            icon: Icons.arrow_back_rounded,
            primary: true,
            onPressed: _close,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => _update(const GameSettings()),
            child: const Text('Reset to defaults'),
          ),
        ],
      ),
    );
  }
}
