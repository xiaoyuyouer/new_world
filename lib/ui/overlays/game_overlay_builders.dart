import 'package:flutter/material.dart';

import '../../game/dodge_game.dart';
import 'game_over_overlay.dart';
import 'game_overlay_config.dart';
import 'paused_overlay.dart';
import 'playing_overlay.dart';
import 'ready_overlay.dart';
import 'settings_overlay.dart';

/// 根据 Overlay 名称创建对应的 Flutter 页面。
final Map<String, Widget Function(BuildContext, DodgeGame)>
gameOverlayBuilders = {
  OverlayNames.ready: (context, game) => ReadyOverlay(game: game),
  OverlayNames.playing: (context, game) => PauseButton(game: game),
  OverlayNames.paused: (context, game) => PausedOverlay(game: game),
  OverlayNames.gameOver: (context, game) => GameOverOverlay(game: game),
  OverlayNames.settings: (context, game) => SettingsOverlay(game: game),
};
