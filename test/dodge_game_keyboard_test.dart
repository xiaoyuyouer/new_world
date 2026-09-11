import 'package:new_world/game/dodge_game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 键盘输入相关的基础回归测试。
void main() {
  /// 确认使用组件键盘处理器时，游戏可以安全接收按键事件。
  test('keyboard events do not assert when using component handlers', () {
    final game = DodgeGame();
    expect(
      () => game.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          logicalKey: LogicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.arrowLeft},
      ),
      returnsNormally,
    );
  });
}
