import 'package:flutter_test/flutter_test.dart';
import 'package:new_world/game/game_round.dart';
import 'package:new_world/models/game_settings.dart';

/// 单局数据的单元测试。
///
/// [GameRound] 只依赖 [GameSettings]，不需要启动游戏引擎就能验证规则。
void main() {
  const hardSettings = GameSettings(difficulty: Difficulty.hard, maxLives: 5);
  const easySettings = GameSettings(difficulty: Difficulty.easy, maxLives: 1);

  group('reset 按设置派生初始值', () {
    test('生命、时间和生成间隔都来自设置', () {
      final round = GameRound()..reset(hardSettings);

      expect(round.score, 0);
      expect(round.wasNewBest, isFalse);
      expect(round.lives, 5);
      expect(round.timeLeft, 60);
      // 困难难度的生成间隔倍率是 0.7。
      expect(round.spawnInterval, closeTo(0.7, 1e-9));
    });

    test('重开后所有字段都被还原，不会残留上一局', () {
      final round = GameRound()..reset(hardSettings);
      round.registerDodge(hardSettings);
      round.loseLife();
      round.advanceTimer(10);
      round.finishAgainst(0);

      round.reset(easySettings);

      expect(round.score, 0);
      expect(round.wasNewBest, isFalse);
      expect(round.lives, 1);
      expect(round.timeLeft, 60);
      expect(round.spawnInterval, closeTo(1.35, 1e-9));
    });
  });

  group('registerDodge 计分与难度', () {
    test('每躲过一个下落物加一分', () {
      final round = GameRound()..reset(hardSettings);
      round
        ..registerDodge(hardSettings)
        ..registerDodge(hardSettings);
      expect(round.score, 2);
    });

    test('生成间隔逐渐缩短，但不会低于难度下限', () {
      final round = GameRound()..reset(hardSettings);
      // 连续躲过大量下落物，间隔应当被 clamp 在下限而不是无限缩小。
      for (var i = 0; i < 500; i++) {
        round.registerDodge(hardSettings);
      }
      expect(round.spawnInterval, closeTo(0.245, 1e-9));
    });
  });

  group('loseLife 与 advanceTimer 的返回值', () {
    test('生命耗尽时返回 true', () {
      final round = GameRound()..reset(easySettings);
      expect(round.loseLife(), isTrue);
      expect(round.lives, 0);
    });

    test('还有生命时返回 false', () {
      final round = GameRound()..reset(hardSettings);
      expect(round.loseLife(), isFalse);
      expect(round.lives, 4);
    });

    test('生命耗尽后继续调用也不会变成负数', () {
      final round = GameRound()..reset(easySettings);
      round.loseLife();

      expect(round.loseLife(), isTrue);
      expect(round.lives, 0);
    });

    test('时间耗尽时归零并返回 true', () {
      final round = GameRound()..reset(hardSettings);
      expect(round.advanceTimer(59), isFalse);
      expect(round.advanceTimer(2), isTrue);
      expect(round.timeLeft, 0, reason: '不应显示负数时间');
    });
  });

  group('finishAgainst 本局结算', () {
    test('超过历史最高分时记录 New Best', () {
      final round = GameRound()..reset(hardSettings);
      round
        ..registerDodge(hardSettings)
        ..registerDodge(hardSettings);

      expect(round.finishAgainst(1), isTrue);
      expect(round.wasNewBest, isTrue);
    });

    test('没有超过历史最高分时不记录 New Best', () {
      final round = GameRound()..reset(hardSettings);
      round.registerDodge(hardSettings);

      expect(round.finishAgainst(1), isFalse);
      expect(round.wasNewBest, isFalse);
    });
  });
}
