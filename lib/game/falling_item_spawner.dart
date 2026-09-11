import 'package:flame/components.dart';

import 'dodge_game.dart';

/// 按当前生成间隔创建下落物。
class FallingItemSpawner extends Component with HasGameReference<DodgeGame> {
  /// 距离上次生成下落物已经经过的时间。
  double _elapsed = 0;

  /// 重置计时器，让新的一局从头开始计算生成时间。
  void reset() {
    _elapsed = 0;
  }

  /// 每帧累加时间，达到生成间隔后创建一个下落物。
  @override
  void update(double dt) {
    super.update(dt);
    // 游戏没有进行时，不应该生成新的下落物。
    if (!game.isPlaying) {
      return;
    }

    // dt 是上一帧到当前帧经过的秒数，避免依赖固定帧率。
    _elapsed += dt;
    if (_elapsed < game.spawnInterval) {
      return;
    }

    // 计时达到阈值后重新计时，并通知游戏创建实体。
    _elapsed = 0;
    game.spawnFallingItem();
  }
}
