/// 注册到 Flame 的 Overlay 名称。
///
/// 名字集中在这里，`GameWidget` 的构建表和阶段映射共用同一份常量，
/// 避免同一个字符串在两处各写一遍。
abstract final class OverlayNames {
  /// 待开始界面。
  static const String ready = 'ready';

  /// 游戏进行中的暂停按钮。
  static const String playing = 'playing';

  /// 暂停界面。
  static const String paused = 'paused';

  /// 游戏结束界面。
  static const String gameOver = 'gameOver';

  /// 设置界面。
  static const String settings = 'settings';
}
