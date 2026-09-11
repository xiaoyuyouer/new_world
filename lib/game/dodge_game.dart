import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/falling_item.dart';
import '../components/hud.dart';
import '../components/player.dart';
import '../models/game_settings.dart';
import '../ui/overlays/game_overlay_config.dart';
import 'falling_item_spawner.dart';
import 'game_flow.dart';
import 'game_round.dart';
import 'game_storage.dart';

/// Dodge 游戏的总控制器。
///
/// 它不绘制实体，也不自己维护状态数据，而是协调各个对象：
/// 输入交给玩家、生成节奏交给生成器、阶段交给 [GameFlow]、
/// 单局数据交给 [GameRound]，其余组件只从它这里读取所需的值。
class DodgeGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
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

  /// 游戏阶段状态机。
  final GameFlow flow = GameFlow();

  /// 本局的分数、生命、时间与难度进度。
  final GameRound round = GameRound();

  /// 历史最高分。跨局保存，因此不属于 [round]。
  int highScore = 0;

  /// 当前分数，供界面读取。
  int get score => round.score;

  /// 本局是否创造了新的最高分，供结算界面读取。
  bool get wasNewBest => round.wasNewBest;

  /// 当前下落物生成间隔，供生成器读取。
  double get spawnInterval => round.spawnInterval;

  /// 当前是否处于待开始状态。
  bool get isReady => flow.isReady;

  /// 当前是否正在游戏。
  bool get isPlaying => flow.isPlaying;

  /// 当前是否暂停。
  bool get isPaused => flow.isPaused;

  /// 当前是否已经结束。
  bool get isGameOver => flow.isGameOver;

  /// 当前是否打开了设置页面。
  bool get isSettingsOpen => flow.isSettingsOpen;

  /// 当前回合总时长，来自设置。
  int get roundDuration => settings.roundDuration;

  /// 当前回合的最大生命数，来自设置。
  int get maxLives => settings.maxLives;

  /// 设置 Flame 游戏画布的背景颜色。
  @override
  Color backgroundColor() => const Color.fromARGB(255, 115, 115, 158);

  /// 加载本地数据并创建游戏中的基础组件。
  @override
  Future<void> onLoad() async {
    // 先加载设置，后续组件创建时就能读取正确的难度和生命数。
    settings = await storage.loadSettings();
    highScore = await storage.loadHighScore();
    // 按加载好的设置初始化本局数据。
    round.reset(settings);

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
    flow.start();
    _syncOverlays();
  }

  /// 返回主菜单，本质上是重置当前回合。
  void backToMenu() {
    restart();
  }

  /// 打开设置页面；返回位置由 [GameFlow] 自己记住。
  void openSettings() {
    flow.openSettings();
    _syncOverlays();
  }

  /// 关闭设置页面，回到进入设置前的阶段。
  void closeSettings() {
    flow.closeSettings();
    _syncOverlays();
  }

  /// 应用新的设置，保存设置并重新开始一局。
  void applySettings(GameSettings next) {
    settings = next;
    storage.saveSettings(next);
    restart();
  }

  /// 把 [GameFlow] 的当前阶段同步到 Flutter Overlay。
  ///
  /// 这里只负责"执行"：该显示哪些 Overlay 由纯函数 [overlaysFor] 决定。
  void _syncOverlays() {
    // 先清除旧 Overlay，保证同一时间只显示正确的界面。
    overlays
      ..clear()
      ..addAll(overlaysFor(flow.phase));
  }

  /// 推进倒计时，再更新子组件。
  ///
  /// 时间耗尽时会先把阶段切到 gameOver，因此本帧剩余的下落物、
  /// 碰撞和生成都不会再执行，避免"死后还被打"和"多余生成"。
  @override
  void update(double dt) {
    if (isPlaying) {
      final isTimeUp = round.advanceTimer(dt);
      hud.updateTimer(round.timeLeft);
      if (isTimeUp) {
        gameOver();
      }
    }

    // 暂停或结束时也必须调用一次：生命周期队列和 UI 动画都在这里推进。
    super.update(dt);
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

    // 计分和难度提升的规则都由本局数据自己维护。
    round.registerDodge(settings);
    hud.updateScore(round.score);
  }

  /// 处理玩家被下落物击中的逻辑。
  void onPlayerHit(FallingItem item) {
    // 暂停、结束或无敌期间不处理伤害。
    if (!isPlaying || player.isInvincible) {
      return;
    }

    // 移除造成伤害的下落物，避免同一个物体重复扣血。
    item.removeFromParent();
    final isOutOfLives = round.loseLife();
    hud.updateLives(round.lives);

    if (isOutOfLives) {
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

    flow.gameOver();
    if (round.finishAgainst(highScore)) {
      // 只有超过历史最高分时才写入本地存储。
      highScore = round.score;
      hud.updateHighScore(highScore);
      storage.saveHighScore(highScore);
    }
    _syncOverlays();
  }

  /// 在游戏进行中和暂停中切换状态。
  void togglePause() {
    // 其他阶段下按暂停键不产生任何变化，也就不必刷新界面。
    if (!isPlaying && !isPaused) {
      return;
    }
    flow.togglePause();
    _syncOverlays();
  }

  /// 清理本局实体和数据，并回到待开始状态。
  void restart() {
    // 下落物由 spawnFallingItem 用 add 挂在本游戏下，所以清理的是 children。
    // 复制成列表再删除，避免遍历集合时同时修改集合。
    for (final item in children.whereType<FallingItem>().toList()) {
      item.removeFromParent();
    }

    // 数据与阶段各自重置，两个对象自己保证字段不会遗漏。
    round.reset(settings);
    flow.reset();
    // 重置生成器计时，避免下一局继承上一局的等待时间。
    itemSpawner.reset();
    // 重置实体和 HUD 的显示。
    player.resetPosition();
    hud.reset();
    _syncOverlays();
  }
}
