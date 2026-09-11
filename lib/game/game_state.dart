/// 游戏当前所处的阶段。
enum GameState {
  /// 等待玩家开始。
  ready,

  /// 正式进行中。
  playing,

  /// 暂停中。
  paused,

  /// 本局结束。
  gameOver,
}
