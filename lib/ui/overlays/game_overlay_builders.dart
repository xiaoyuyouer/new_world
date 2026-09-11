import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import 'game_over_overlay.dart';
import 'paused_overlay.dart';
import 'playing_overlay.dart';
import 'ready_overlay.dart';
import 'settings_overlay.dart';

/// 根据 Overlay 名称创建对应的 Flutter 页面。
final Map<String, Widget Function(BuildContext, DodgeGame)>
gameOverlayBuilders = {
  DodgeGame.readyOverlay: (context, game) => ReadyOverlay(game: game),
  DodgeGame.playingOverlay: (context, game) => PauseButton(game: game),
  DodgeGame.pausedOverlay: (context, game) => PausedOverlay(game: game),
  DodgeGame.gameOverOverlay: (context, game) => GameOverOverlay(game: game),
  DodgeGame.settingsOverlay: (context, game) => SettingsOverlay(game: game),
};
