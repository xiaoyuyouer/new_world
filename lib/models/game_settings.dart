/// 游戏难度，影响道具的下落速度与生成频率。
enum Difficulty {
  /// 简单难度：下落慢、生成间隔长。
  easy('Easy', 0.75, 1.35),

  /// 普通难度：使用基准速度和生成间隔。
  normal('Normal', 1.0, 1.0),

  /// 困难难度：下落快、生成间隔短。
  hard('Hard', 1.35, 0.7);

  /// 创建一个难度配置。
  const Difficulty(this.label, this.itemSpeedFactor, this.spawnIntervalFactor);

  /// 设置页面显示的名称。
  final String label;

  /// 下落物速度倍率。
  final double itemSpeedFactor;

  /// 生成间隔倍率，数值越小表示生成越密集。
  final double spawnIntervalFactor;

  /// 根据保存的名称恢复难度；名称无效时使用普通难度。
  static Difficulty fromName(String? name) => Difficulty.values.firstWhere(
    (difficulty) => difficulty.name == name,
    orElse: () => Difficulty.normal,
  );
}

/// 可以在设置页调整的游戏参数。
class GameSettings {
  /// 创建一组游戏设置。
  const GameSettings({
    this.difficulty = Difficulty.normal,
    this.playerSpeedMultiplier = 1.0,
    this.roundDuration = 60,
    this.maxLives = 3,
  });

  /// 玩家速度可选倍率。
  static const List<double> playerSpeedOptions = [0.7, 0.85, 1.0, 1.15, 1.3];

  /// 回合时间可选值，单位是秒。
  static const List<int> roundDurationOptions = [30, 60, 90, 120];

  /// 最大生命数可选值。
  static const List<int> maxLivesOptions = [1, 2, 3, 4, 5];

  /// 当前选择的难度。
  final Difficulty difficulty;

  /// 玩家基础速度倍率。
  final double playerSpeedMultiplier;

  /// 单局持续时间，单位是秒。
  final int roundDuration;

  /// 每局开始时的生命数。
  final int maxLives;

  /// 创建只修改部分字段的新设置对象。
  GameSettings copyWith({
    Difficulty? difficulty,
    double? playerSpeedMultiplier,
    int? roundDuration,
    int? maxLives,
  }) => GameSettings(
    difficulty: difficulty ?? this.difficulty,
    playerSpeedMultiplier: playerSpeedMultiplier ?? this.playerSpeedMultiplier,
    roundDuration: roundDuration ?? this.roundDuration,
    maxLives: maxLives ?? this.maxLives,
  );

  /// 将设置转换为可保存到 JSON 的键值结构。
  Map<String, Object?> toJson() => {
    'difficulty': difficulty.name,
    'playerSpeedMultiplier': playerSpeedMultiplier,
    'roundDuration': roundDuration,
    'maxLives': maxLives,
  };

  /// 从 JSON 键值结构恢复设置，并校验可能已经损坏的值。
  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    difficulty: Difficulty.fromName(json['difficulty'] as String?),
    playerSpeedMultiplier: _validSpeed(json['playerSpeedMultiplier']),
    roundDuration: _validRoundDuration(json['roundDuration']),
    maxLives: _validLives(json['maxLives']),
  );

  /// 校验玩家速度倍率，避免本地数据出现极端值。
  static double _validSpeed(Object? value) {
    final speed = value is num ? value.toDouble() : 1.0;
    return speed.clamp(playerSpeedOptions.first, playerSpeedOptions.last);
  }

  /// 校验回合时间，只允许设置页面提供的选项。
  static int _validRoundDuration(Object? value) {
    final duration = value is num ? value.toInt() : 60;
    return roundDurationOptions.contains(duration) ? duration : 60;
  }

  /// 校验生命数量，限制在允许的范围内。
  static int _validLives(Object? value) {
    final lives = value is num ? value.toInt() : 3;
    return lives.clamp(maxLivesOptions.first, maxLivesOptions.last);
  }

  /// 判断两组设置是否完全相同。
  @override
  bool operator ==(Object other) =>
      other is GameSettings &&
      other.difficulty == difficulty &&
      other.playerSpeedMultiplier == playerSpeedMultiplier &&
      other.roundDuration == roundDuration &&
      other.maxLives == maxLives;

  /// 根据所有设置字段计算哈希值，配合 == 使用。
  @override
  int get hashCode =>
      Object.hash(difficulty, playerSpeedMultiplier, roundDuration, maxLives);
}
