import 'package:flutter_test/flutter_test.dart';
import 'package:new_world/game/game_flow.dart';
import 'package:new_world/game/game_phase.dart';
import 'package:new_world/ui/overlays/game_overlay_config.dart';

/// 阶段状态机的单元测试。
///
/// 这些测试完全不依赖 Flame，只需要构造一个 [GameFlow] 即可，
/// 这正是把状态机从 DodgeGame 里拆出来换到的最大好处。
void main() {
  group('GameFlow 阶段迁移', () {
    test('初始处于待开始阶段', () {
      expect(GameFlow().phase, GamePhase.ready);
    });

    test('只能从待开始进入游戏', () {
      final flow = GameFlow();
      flow.gameOver();
      expect(flow.phase, GamePhase.ready, reason: '待开始时不该被结束');

      flow.start();
      expect(flow.phase, GamePhase.playing);

      flow.start();
      expect(flow.phase, GamePhase.playing, reason: '重复开始不应有副作用');
    });

    test('暂停与继续只在进行中/暂停中之间切换', () {
      final flow = GameFlow();
      flow.togglePause();
      expect(flow.phase, GamePhase.ready, reason: '待开始时按暂停不应有变化');

      flow.start();
      flow.togglePause();
      expect(flow.phase, GamePhase.paused);

      flow.togglePause();
      expect(flow.phase, GamePhase.playing);
    });

    test('从游戏中打开设置，返回时回到游戏而不是待开始', () {
      final flow = GameFlow();
      flow.start();

      flow.openSettings();
      expect(flow.phase, GamePhase.settings);
      expect(flow.isPlaying, isFalse, reason: '设置页打开时游戏应暂停推进');

      flow.closeSettings();
      expect(flow.phase, GamePhase.playing);
    });

    test('从暂停中打开设置，返回时回到暂停', () {
      final flow = GameFlow();
      flow.start();
      flow.togglePause();

      flow.openSettings();
      flow.closeSettings();
      expect(flow.phase, GamePhase.paused);
    });

    test('重置会清空返回记忆，避免残留上一局的来路', () {
      final flow = GameFlow();
      flow.start();
      flow.openSettings();
      // 设置页里点了重开。
      flow.reset();
      expect(flow.phase, GamePhase.ready);

      flow.openSettings();
      flow.closeSettings();
      expect(flow.phase, GamePhase.ready, reason: '不应回到上一局记住的 playing');
    });
  });

  group('overlaysFor 纯映射', () {
    test('每个阶段对应唯一一个 Overlay', () {
      expect(overlaysFor(GamePhase.ready), {OverlayNames.ready});
      expect(overlaysFor(GamePhase.playing), {OverlayNames.playing});
      expect(overlaysFor(GamePhase.paused), {OverlayNames.paused});
      expect(overlaysFor(GamePhase.gameOver), {OverlayNames.gameOver});
      expect(overlaysFor(GamePhase.settings), {OverlayNames.settings});
    });

    test('设置阶段不会再叠加其他界面', () {
      expect(overlaysFor(GamePhase.settings), hasLength(1));
    });
  });
}
