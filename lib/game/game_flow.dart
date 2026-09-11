import 'game_phase.dart';

/// 游戏阶段状态机。
///
/// 只持有"当前处于哪个阶段"，并负责阶段之间的合法迁移。
/// 它不认识 Flame、Overlay 或任何 UI，因此可以零依赖单测。
class GameFlow {
  /// 当前阶段。
  GamePhase _phase = GamePhase.ready;

  /// 关闭设置后要回到的阶段。
  ///
  /// 这是状态机内部的实现细节：调用方不需要知道"从哪来"。
  GamePhase _beforeSettings = GamePhase.ready;

  /// 当前阶段。
  GamePhase get phase => _phase;

  /// 当前是否处于待开始阶段。
  bool get isReady => _phase == GamePhase.ready;

  /// 当前是否正在游戏。
  bool get isPlaying => _phase == GamePhase.playing;

  /// 当前是否暂停。
  bool get isPaused => _phase == GamePhase.paused;

  /// 当前是否已经结束。
  bool get isGameOver => _phase == GamePhase.gameOver;

  /// 当前是否打开了设置页面。
  bool get isSettingsOpen => _phase == GamePhase.settings;

  /// 从待开始进入游戏；只有待开始阶段有效。
  void start() {
    if (!isReady) {
      return;
    }
    _phase = GamePhase.playing;
  }

  /// 在游戏进行中和暂停中互相切换；其他阶段不动作。
  void togglePause() {
    if (isPlaying) {
      _phase = GamePhase.paused;
    } else if (isPaused) {
      _phase = GamePhase.playing;
    }
  }

  /// 结束本局；只有游戏进行中才会结束。
  void gameOver() {
    if (!isPlaying) {
      return;
    }
    _phase = GamePhase.gameOver;
  }

  /// 打开设置，并记住返回时的阶段。
  void openSettings() {
    if (isSettingsOpen) {
      return;
    }
    _beforeSettings = _phase;
    _phase = GamePhase.settings;
  }

  /// 关闭设置，回到进入设置前的阶段。
  void closeSettings() {
    if (!isSettingsOpen) {
      return;
    }
    _phase = _beforeSettings;
  }

  /// 回到待开始阶段，并清空返回记忆。
  void reset() {
    _phase = GamePhase.ready;
    _beforeSettings = GamePhase.ready;
  }
}
