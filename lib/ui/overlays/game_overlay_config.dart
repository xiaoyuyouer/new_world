import '../../game/game_phase.dart';

/// 注册到 Flame 的 Overlay 名称。
abstract final class OverlayNames {
  static const String ready = 'ready';
  static const String playing = 'playing';
  static const String paused = 'paused';
  static const String gameOver = 'gameOver';
  static const String settings = 'settings';
}

/// 把游戏阶段转换成当前应该显示的 Overlay。
Set<String> overlaysFor(GamePhase phase) => switch (phase) {
  GamePhase.ready => {OverlayNames.ready},
  GamePhase.playing => {OverlayNames.playing},
  GamePhase.paused => {OverlayNames.paused},
  GamePhase.gameOver => {OverlayNames.gameOver},
  GamePhase.settings => {OverlayNames.settings},
};
