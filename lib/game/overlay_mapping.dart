import 'game_phase.dart';
import 'overlay_names.dart';

/// 阶段到 Overlay 名称的映射。
///
/// 这是一个纯函数：同样的阶段永远得到同样的结果，没有副作用，
/// 因此可以脱离 Flame 单独断言。
///
/// 注意设置页面只是枚举里的一行，而不是 `if` 里的特判——
/// 阶段本身已经保证了同一时刻只有一个合法值。
Set<String> overlaysFor(GamePhase phase) => switch (phase) {
  GamePhase.ready => {OverlayNames.ready},
  GamePhase.playing => {OverlayNames.playing},
  GamePhase.paused => {OverlayNames.paused},
  GamePhase.gameOver => {OverlayNames.gameOver},
  GamePhase.settings => {OverlayNames.settings},
};
