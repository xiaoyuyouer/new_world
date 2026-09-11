import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/falling_item.dart';
import '../components/hud.dart';
import '../components/player.dart';
import '../models/game_settings.dart';
import 'falling_item_spawner.dart';
import 'game_state.dart';
import 'game_storage.dart';

/// Dodge 游戏的总控制器。
///
/// 它不负责绘制每个实体，而是负责协调游戏状态、计分、倒计时、
/// 生成器、玩家、HUD 和 Overlay。
class DodgeGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  /// 待开始界面的 Overlay 名称。
  static const String readyOverlay = 'ready';

  /// 游戏进行中暂停按钮的 Overlay 名称。
  static const String playingOverlay = 'playing';

  /// 暂停界面的 Overlay 名称。
  static const String pausedOverlay = 'paused';

  /// 游戏结束界面的 Overlay 名称。
  static const String gameOverOverlay = 'gameOver';

  /// 设置界面的 Overlay 名称。
  static const String settingsOverlay = 'settings';

  /// 普通难度下的初始生成间隔。
  static const double baseSpawnInterval = 1.0;

  /// 普通难度下允许达到的最小生成间隔。
  static const double baseMinSpawnInterval = 0.35;

  /// 创建游戏，并允许外部传入存储实现，方便测试和替换存储方式。
  DodgeGame({GameStorage? storage}) : storage = storage ?? GameStorage();

  /// 游戏使用的本地存储对象。
  final GameStorage storage;

  /// 玩家实体。
  late final Player player;

  /// 游戏内的分数、时间和生命 HUD。
  late final GameHud hud;

  /// 下落物生成器。
  late final FallingItemSpawner itemSpawner;

  /// 当前游戏设置。
  GameSettings settings = const GameSettings();

  /// 当前分数。
  int score = 0;

  /// 历史最高分。
  int highScore = 0;

  /// 当前剩余生命数。
  late int lives = maxLives;

  /// 当前回合剩余时间，使用 double 保留帧级精度。
  late double timeLeft = roundDuration.toDouble();

  /// 当前下落物生成间隔。
  late double spawnInterval = initialSpawnInterval;

  /// 本局是否创造了新的最高分。
  bool wasNewBest = false;

  /// 游戏当前状态。
  GameState _state = GameState.ready;

  /// 设置页面是否正在显示。
  bool _showSettings = false;

  /// 关闭设置页面后应该返回的游戏状态。
  GameState _settingsReturnState = GameState.ready;

  /// 对外暴露当前游戏状态。
  GameState get state => _state;

  /// 当前是否处于待开始状态。
  bool get isReady => _state == GameState.ready;

  /// 当前是否正在游戏。
  bool get isPlaying => _state == GameState.playing;

  /// 当前是否暂停。
  bool get isPaused => _state == GameState.paused;

  /// 当前是否已经结束。
  bool get isGameOver => _state == GameState.gameOver;

  /// 当前是否打开了设置页面。
  bool get isSettingsOpen => _showSettings;

  /// 当前回合总时长，来自设置。
  int get roundDuration => settings.roundDuration;

  /// 当前回合的最大生命数，来自设置。
  int get maxLives => settings.maxLives;

  /// 根据难度计算本局开始时的生成间隔。
  double get initialSpawnInterval =>
      baseSpawnInterval * settings.difficulty.spawnIntervalFactor;

  /// 根据难度计算生成间隔允许达到的最小值。
  double get minSpawnInterval =>
      baseMinSpawnInterval * settings.difficulty.spawnIntervalFactor;

  /// 设置 Flame 游戏画布的背景颜色。
  @override
  Color backgroundColor() => const Color.fromARGB(255, 115, 115, 158);

  /// 加载本地数据并创建游戏中的基础组件。
  @override
  Future<void> onLoad() async {
    // 先加载设置，后续组件创建时就能读取正确的难度和生命数。
    settings = await storage.loadSettings();
    highScore = await storage.loadHighScore();
    lives = maxLives;
    timeLeft = roundDuration.toDouble();
    spawnInterval = initialSpawnInterval;

    // 创建游戏实体和辅助组件。
    player = Player();
    hud = GameHud();
    itemSpawner = FallingItemSpawner();
    await addAll([player, hud, itemSpawner]);

    // HUD 加载完成后再显示已保存的最高分。
    hud.updateHighScore(highScore);
    // 根据初始状态显示待开始界面。
    _syncOverlays();
  }

  /// 从待开始状态进入游戏状态。
  void start() {
    if (!isReady) {
      return;
    }
    _state = GameState.playing;
    _syncOverlays();
  }

  /// 返回主菜单，本质上是重置当前回合。
  void backToMenu() {
    restart();
  }

  /// 打开设置页面，并记录打开前的状态。
  void openSettings() {
    if (_showSettings) {
      return;
    }
    _settingsReturnState = _state;
    _showSettings = true;
    _syncOverlays();
  }

  /// 关闭设置页面，并恢复进入设置前的状态。
  void closeSettings() {
    if (!_showSettings) {
      return;
    }
    _showSettings = false;
    _state = _settingsReturnState;
    _syncOverlays();
  }

  /// 应用新的设置，保存设置并重新开始一局。
  void applySettings(GameSettings next) {
    settings = next;
    storage.saveSettings(next);
    restart();
  }

  /// 根据游戏状态和设置状态同步当前显示的 Flutter Overlay。
  void _syncOverlays() {
    // 先清除旧 Overlay，保证同一时间只显示正确的界面。
    overlays.clear();
    if (_showSettings) {
      overlays.add(settingsOverlay);
      return;
    }

    // 设置页面优先级最高，打开时不显示其他状态页面。
    switch (_state) {
      case GameState.ready:
        overlays.add(readyOverlay);
      case GameState.playing:
        overlays.add(playingOverlay);
      case GameState.paused:
        overlays.add(pausedOverlay);
      case GameState.gameOver:
        overlays.add(gameOverOverlay);
    }
  }

  /// 更新游戏倒计时。
  @override
  void update(double dt) {
    super.update(dt);
    // 待开始、暂停和结束状态都不应该继续倒计时。
    if (!isPlaying) {
      return;
    }

    // 用 dt 扣除真实经过的时间，保证不同帧率下倒计时一致。
    timeLeft -= dt;
    if (timeLeft <= 0) {
      // 防止界面显示负数，并结束本局游戏。
      timeLeft = 0;
      hud.updateTimer(timeLeft);
      gameOver();
      return;
    }
    hud.updateTimer(timeLeft);
  }

  /// 创建并加入一个下落物。
  void spawnFallingItem() {
    add(FallingItem());
  }

  /// 当一个下落物成功越过屏幕底部时增加分数并提高难度。
  void onItemDodged() {
    if (!isPlaying) {
      return;
    }

    score += 1;
    hud.updateScore(score);
    // 每成功躲过一个下落物，下一次生成间隔缩短 2%。
    // clamp 保证难度不会超过设定的上下限。
    spawnInterval = (spawnInterval * 0.98).clamp(
      minSpawnInterval,
      initialSpawnInterval,
    );
  }

  /// 处理玩家被下落物击中的逻辑。
  void onPlayerHit(FallingItem item) {
    // 暂停、结束或无敌期间不处理伤害。
    if (!isPlaying || player.isInvincible) {
      return;
    }

    // 移除造成伤害的下落物，避免同一个物体重复扣血。
    item.removeFromParent();
    lives -= 1;
    hud.updateLives(lives);

    if (lives <= 0) {
      // 生命耗尽后结束游戏。
      gameOver();
      return;
    }

    // 未结束时把玩家放回安全位置，并启动短暂无敌时间。
    player.resetPosition();
    player.startInvincibility();
  }

  /// 结束本局，并在需要时保存新的最高分。
  void gameOver() {
    if (!isPlaying) {
      return;
    }

    _state = GameState.gameOver;
    wasNewBest = score > highScore;
    if (wasNewBest) {
      // 只有超过历史最高分时才写入本地存储。
      highScore = score;
      hud.updateHighScore(highScore);
      storage.saveHighScore(highScore);
    }
    _syncOverlays();
  }

  /// 在游戏进行中和暂停中切换状态。
  void togglePause() {
    if (isPlaying) {
      _state = GameState.paused;
    } else if (isPaused) {
      _state = GameState.playing;
    } else {
      return;
    }
    _syncOverlays();
  }

  /// 清理本局实体和数据，并回到待开始状态。
  void restart() {
    // 复制 children 后再删除，避免遍历集合时同时修改集合。
    for (final item in world.children.whereType<FallingItem>().toList()) {
      item.removeFromParent();
    }

    // 恢复本局数据。
    score = 0;
    lives = maxLives;
    timeLeft = roundDuration.toDouble();
    spawnInterval = initialSpawnInterval;
    wasNewBest = false;
    // 重置生成器计时，避免下一局继承上一局的等待时间。
    itemSpawner.reset();
    _state = GameState.ready;
    _showSettings = false;
    // 重置实体和 HUD 的显示。
    player.resetPosition();
    hud.reset();
    _syncOverlays();
  }
}
