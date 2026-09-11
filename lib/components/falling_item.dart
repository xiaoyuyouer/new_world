import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/dodge_game.dart';
import 'player.dart';

/// 从屏幕上方落下的障碍物。
class FallingItem extends RectangleComponent
    with HasGameReference<DodgeGame>, CollisionCallbacks {
  /// 普通难度下的基础下落速度，单位是像素/秒。
  static const double baseSpeed = 240;

  /// 下落物的显示颜色。
  static const Color itemColor = Color(0xFFFF7043);

  /// 用于随机生成水平位置的随机数生成器。
  static final Random _random = Random();

  /// 创建一个带有固定尺寸和颜色的下落物。
  FallingItem()
    : super(
        size: Vector2(26, 26),
        paint: Paint()..color = itemColor,
        anchor: Anchor.center,
      );

  /// 初始化随机位置和碰撞体。
  @override
  Future<void> onLoad() async {
    position = _randomSpawnPosition();
    add(RectangleHitbox());
  }

  /// 计算下落物从屏幕顶部出现时的随机位置。
  Vector2 _randomSpawnPosition() {
    final halfWidth = size.x / 2;
    return Vector2(
      halfWidth + _random.nextDouble() * (game.size.x - size.x),
      -size.y,
    );
  }

  /// 每帧更新下落物的位置，并检测是否已经离开屏幕。
  @override
  void update(double dt) {
    super.update(dt);
    // 游戏暂停或结束后，障碍物也应该停止移动。
    if (!game.isPlaying) {
      return;
    }

    // 难度影响下落速度，dt 保证速度不依赖当前帧率。
    final currentSpeed = baseSpeed * game.settings.difficulty.itemSpeedFactor;
    position.y += currentSpeed * dt;

    if (_isOutsideScreen) {
      // 成功躲过障碍物，通知游戏加分并移除自己。
      game.onItemDodged();
      removeFromParent();
    }
  }

  /// 判断下落物是否已经完全离开屏幕底部。
  bool get _isOutsideScreen => position.y > game.size.y + size.y;

  /// 当下落物第一次与其他碰撞体接触时调用。
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      // 只对玩家造成伤害，其他碰撞体暂不处理。
      game.onPlayerHit(this);
    }
  }
}
