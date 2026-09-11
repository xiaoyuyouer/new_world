import '../models/game_settings.dart';

/// 一局游戏进行到的程度。
///
/// 所有字段的生命周期都是"一局"：开局时按设置派生初始值，重开时统一清零。
/// 跨局的数据（例如历史最高分）不属于这里。
///
/// 它只依赖 [GameSettings]，不认识 Flame，因此可以零依赖单测。
class GameRound {
  /// 普通难度下的初始生成间隔。
  static const double baseSpawnInterval = 1.0;

  /// 普通难度下允许达到的最小生成间隔。
  static const double baseMinSpawnInterval = 0.35;

  /// 当前分数。
  int _score = 0;

  /// 本局是否创造了新的最高分。
  bool _wasNewBest = false;

  /// 当前剩余生命数。
  int _lives = 0;

  /// 当前回合剩余时间，使用 double 保留帧级精度。
  double _timeLeft = 0;

  /// 当前下落物生成间隔。
  double _spawnInterval = baseSpawnInterval;

  /// 当前分数，只允许外部读取。
  int get score => _score;

  /// 本局是否创造了新的最高分，只允许外部读取。
  bool get wasNewBest => _wasNewBest;

  /// 当前剩余生命数，只允许外部读取。
  int get lives => _lives;

  /// 当前回合剩余时间，只允许外部读取。
  double get timeLeft => _timeLeft;

  /// 当前下落物生成间隔，只允许外部读取。
  double get spawnInterval => _spawnInterval;

  /// 按给定设置重置本局数据。
  ///
  /// 开局和重开共用这一个入口，避免初始化逻辑散落在多个地方。
  void reset(GameSettings settings) {
    _score = 0;
    _wasNewBest = false;
    _lives = settings.maxLives;
    _timeLeft = settings.roundDuration.toDouble();
    _spawnInterval = initialSpawnInterval(settings);
  }

  /// 躲过一个下落物：加一分，并让生成间隔逐渐缩短以提高难度。
  void registerDodge(GameSettings settings) {
    _score += 1;
    // 每成功躲过一个下落物，下一次生成间隔缩短 2%。
    // clamp 保证难度不会超过设定的上下限。
    _spawnInterval = (_spawnInterval * 0.98).clamp(
      minSpawnInterval(settings),
      initialSpawnInterval(settings),
    );
  }

  /// 扣掉一条生命，返回是否因此耗尽生命。
  bool loseLife() {
    // 已经耗尽时不再继续扣，保证生命数不会变成负数。
    if (_lives <= 0) {
      return true;
    }
    _lives -= 1;
    return _lives == 0;
  }

  /// 推进倒计时，返回本局时间是否已经耗尽。
  bool advanceTimer(double dt) {
    _timeLeft -= dt;
    if (_timeLeft > 0) {
      return false;
    }
    // 防止界面显示负数。
    _timeLeft = 0;
    return true;
  }

  /// 结算本局成绩，并返回是否打破历史最高分。
  bool finishAgainst(int highScore) {
    _wasNewBest = _score > highScore;
    return _wasNewBest;
  }

  /// 根据难度计算本局开始时的生成间隔。
  static double initialSpawnInterval(GameSettings settings) =>
      baseSpawnInterval * settings.difficulty.spawnIntervalFactor;

  /// 根据难度计算生成间隔允许达到的最小值。
  static double minSpawnInterval(GameSettings settings) =>
      baseMinSpawnInterval * settings.difficulty.spawnIntervalFactor;
}
