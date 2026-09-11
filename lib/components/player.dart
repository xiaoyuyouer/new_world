import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/dodge_game.dart';

/// 游戏中的玩家角色。
///
/// 负责处理键盘输入、移动、边界限制和受击后的无敌状态。
class Player extends RectangleComponent
    with HasGameReference<DodgeGame>, KeyboardHandler, CollisionCallbacks {
  /// 玩家正常移动速度，单位是像素/秒。
  static const double baseSpeed = 420;

  /// 按住 Shift 时的速度倍率。
  static const double boostMultiplier = 1.8;

  /// 玩家距离屏幕底部的最小间距。
  static const double bottomPadding = 48;

  /// 玩家允许移动到的最上方位置。
  static const double topPadding = 80;

  /// 玩家正常显示颜色。
  static const Color baseColor = Color(0xFF4FC3F7);

  /// 每次受击后持续无敌的时间。
  static const double invincibleDuration = 1.5;

  /// 当前水平方向：-1 向左，0 不动，1 向右。
  double _horizontalDirection = 0;

  /// 当前垂直方向：-1 向上，0 不动，1 向下。
  double _verticalDirection = 0;

  /// 当前是否正在加速移动。
  bool _isBoosting = false;

  /// 剩余无敌时间。
  double _invincibleTimer = 0;

  /// 当前是否处于无敌状态。
  bool get isInvincible => _invincibleTimer > 0;

  /// 创建玩家的外观和初始尺寸。
  Player()
    : super(
        size: Vector2(72, 22),
        paint: Paint()..color = baseColor,
        anchor: Anchor.center,
      );

  /// 初始化玩家的碰撞体和初始位置。
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    resetPosition();
  }

  /// 窗口大小改变时，确保玩家仍然位于有效区域内。
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.y = position.y.clamp(topPadding, size.y - bottomPadding);
    _clampX();
  }

  /// 把玩家放回游戏底部中央，并清空当前输入和无敌状态。
  void resetPosition() {
    position = Vector2(game.size.x / 2, game.size.y - bottomPadding);
    _horizontalDirection = 0;
    _verticalDirection = 0;
    _isBoosting = false;
    _invincibleTimer = 0;
    paint.color = baseColor;
  }

  /// 开始一段无敌时间，由 update 负责倒计时和闪烁。
  void startInvincibility([double duration = invincibleDuration]) {
    _invincibleTimer = duration;
  }

  /// 处理键盘按键和按键释放事件。
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 设置界面打开时不让游戏快捷键干扰 Flutter 控件。
    if (game.isSettingsOpen) {
      return true;
    }

    // 一次性动作只在按下时触发，移动方向则读取当前所有按键状态。
    final isKeyDown = event is KeyDownEvent;

    // 待开始时，空格或回车可以开始游戏。
    if (game.isReady &&
        isKeyDown &&
        (keysPressed.contains(LogicalKeyboardKey.space) ||
            keysPressed.contains(LogicalKeyboardKey.enter))) {
      game.start();
      return true;
    }

    // 游戏结束时，R 键可以重新开始。
    if (game.isGameOver &&
        isKeyDown &&
        keysPressed.contains(LogicalKeyboardKey.keyR)) {
      game.restart();
      return true;
    }

    // 只在按下的那一刻切换，避免长按 P 反复暂停和恢复。
    if (isKeyDown && keysPressed.contains(LogicalKeyboardKey.keyP)) {
      game.togglePause();
      return true;
    }

    // 其他按键用于更新移动方向和加速状态。
    _updateInput(keysPressed);
    return true;
  }

  /// 根据当前仍然按住的按键更新移动输入。
  void _updateInput(Set<LogicalKeyboardKey> keysPressed) {
    _horizontalDirection = 0;
    _verticalDirection = 0;

    // A/左箭头控制水平向左移动。
    if (_isPressed(
      keysPressed,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA,
    )) {
      _horizontalDirection -= 1;
    }
    // D/右箭头控制水平向右移动。
    if (_isPressed(
      keysPressed,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyD,
    )) {
      _horizontalDirection += 1;
    }
    // W/上箭头控制垂直向上移动。
    if (_isPressed(
      keysPressed,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.keyW,
    )) {
      _verticalDirection -= 1;
    }
    // S/下箭头控制垂直向下移动。
    if (_isPressed(
      keysPressed,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.keyS,
    )) {
      _verticalDirection += 1;
    }

    // 任意一个 Shift 键按住时开启加速。
    _isBoosting =
        keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        keysPressed.contains(LogicalKeyboardKey.shiftRight);
  }

  /// 判断一组按键中是否至少有一个按键被按住。
  bool _isPressed(
    Set<LogicalKeyboardKey> keysPressed,
    LogicalKeyboardKey first,
    LogicalKeyboardKey second,
  ) {
    return keysPressed.contains(first) || keysPressed.contains(second);
  }

  /// 每帧更新无敌状态和玩家位置。
  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) {
      return;
    }

    // 先更新无敌倒计时和闪烁效果。
    _updateInvincibility(dt);

    // 速度由基础速度、设置倍率和加速状态共同决定。
    final currentSpeed =
        baseSpeed *
        game.settings.playerSpeedMultiplier *
        (_isBoosting ? boostMultiplier : 1);
    // 速度乘以 dt，得到本帧应该移动的距离。
    position.x += _horizontalDirection * currentSpeed * dt;
    position.y += _verticalDirection * currentSpeed * dt;
    _clampX();
    _clampY();
  }

  /// 减少无敌时间，并通过改变透明度表现闪烁效果。
  void _updateInvincibility(double dt) {
    if (_invincibleTimer <= 0) {
      return;
    }

    _invincibleTimer -= dt;
    if (_invincibleTimer <= 0) {
      _invincibleTimer = 0;
      // 无敌时间结束后恢复正常颜色。
      paint.color = baseColor;
      return;
    }

    // 每 0.1 秒切换一次显示状态，形成闪烁效果。
    final visible = (_invincibleTimer * 10).floor().isEven;
    paint.color = visible ? baseColor : baseColor.withValues(alpha: 0);
  }

  /// 限制玩家不能移动出左右边界。
  void _clampX() {
    final halfWidth = size.x / 2;
    position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
  }

  /// 限制玩家不能移动到 HUD 区域或屏幕底部之外。
  void _clampY() {
    position.y = position.y.clamp(topPadding, game.size.y - bottomPadding);
  }
}
