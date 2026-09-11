import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:new_world/game/dodge_game.dart';
import 'package:new_world/app/dodge_app.dart';
import 'package:new_world/components/falling_item.dart';
import 'package:new_world/game/game_storage.dart';
import 'package:new_world/models/game_settings.dart';
import 'package:new_world/ui/game_overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用独立的游戏实例搭建可交互画面，方便直接驱动状态。
Future<DodgeGame> pumpGame(WidgetTester tester) async {
  final game = DodgeGame();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GameWidget<DodgeGame>(
          game: game,
          overlayBuilderMap: gameOverlayBuilders,
        ),
      ),
    ),
  );
  // 给 onLoad 里的异步设置/最高分加载留出时间。
  await tester.pump();
  await tester.pump();
  return game;
}

/// 读取 HUD 当前显示的所有文本，验证游戏数据是否正确同步到画面。
List<String> hudTexts(DodgeGame game) => game.hud.children
    .whereType<TextComponent>()
    .map((component) => component.text)
    .toList();

void main() {
  /// 每个测试都使用干净的内存版 SharedPreferences。
  setUp(() {
    // 让 SharedPreferences 在测试中使用内存实现。
    SharedPreferences.setMockInitialValues({});
  });

  /// 验证游戏可以从开始状态进入暂停，再恢复到进行中状态。
  testWidgets('开始游戏 -> 暂停 -> 继续 的覆盖层流程', (tester) async {
    await tester.pumpWidget(const DodgeApp());
    // 给 onLoad 里的异步设置/最高分加载留出时间。
    await tester.pump();
    await tester.pump();

    // 启动后显示开始界面。
    expect(find.byType(ReadyOverlay), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);

    // 点击“开始游戏”进入游戏，右上角出现暂停按钮。
    await tester.tap(find.text('Start Game'));
    await tester.pump();
    expect(find.byType(ReadyOverlay), findsNothing);
    expect(find.byType(PauseButton), findsOneWidget);

    // 点击暂停按钮，出现暂停界面。
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.byType(PausedOverlay), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    // 继续游戏。
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.byType(PausedOverlay), findsNothing);
    expect(find.byType(PauseButton), findsOneWidget);
  });

  /// 验证设置页面可以打开，并在没有修改时安全返回。
  testWidgets('从开始界面可进入设置并返回', (tester) async {
    await tester.pumpWidget(const DodgeApp());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.byType(SettingsOverlay), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Player Speed'), findsOneWidget);
    expect(find.text('Round Time'), findsOneWidget);
    expect(find.text('Lives'), findsOneWidget);

    // 未修改设置时返回，应回到开始界面。
    await tester.ensureVisible(find.text('Back'));
    await tester.pump();
    await tester.tap(find.text('Back'));
    await tester.pump();
    expect(find.byType(SettingsOverlay), findsNothing);
    expect(find.byType(ReadyOverlay), findsOneWidget);
  });

  /// 验证游戏结束页面能够展示，并且 Restart 会回到待开始状态。
  testWidgets('游戏结束时弹出结算面板，可重新开始', (tester) async {
    final game = await pumpGame(tester);

    game.start();
    await tester.pump();
    expect(find.byType(PauseButton), findsOneWidget);

    game.gameOver();
    await tester.pump();
    expect(find.byType(GameOverOverlay), findsOneWidget);
    expect(find.text('Game Over'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Main Menu'), findsOneWidget);

    // 重新开始后回到待开始界面。
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.byType(GameOverOverlay), findsNothing);
    expect(find.byType(ReadyOverlay), findsOneWidget);
  });

  testWidgets('重开会清理上一局残留的下落物', (tester) async {
    final game = await pumpGame(tester);
    game.start();

    game.spawnFallingItem();
    await tester.pump();
    game.spawnFallingItem();
    await tester.pump();
    expect(
      game.children.whereType<FallingItem>(),
      isNotEmpty,
      reason: '前置条件：场上应当已经有下落物',
    );

    game.restart();
    await tester.pump();
    await tester.pump();

    expect(
      game.children.whereType<FallingItem>(),
      isEmpty,
      reason: '重开后若残留下落物，新一局会立刻砸到玩家并在出屏时白送分',
    );
    expect(game.isReady, isTrue);
  });

  testWidgets('DodgeGame 会协调本局数据、HUD 与结束流程', (tester) async {
    final game = await pumpGame(tester);
    game.start();

    game.onItemDodged();
    expect(game.round.score, 1);
    expect(hudTexts(game), contains('Score: 1'));

    final livesBeforeHit = game.round.lives;
    game.onPlayerHit(FallingItem());
    expect(game.round.lives, livesBeforeHit - 1);
    expect(hudTexts(game), contains('♥' * (livesBeforeHit - 1) + '♡'));

    game.update(game.round.timeLeft + 1);
    await tester.pump();
    expect(game.round.timeLeft, 0);
    expect(game.isGameOver, isTrue);
    expect(find.byType(GameOverOverlay), findsOneWidget);
  });

  /// 验证修改设置后，游戏实例和本地存储都会得到新值。
  testWidgets('修改设置后保存并生效', (tester) async {
    final game = await pumpGame(tester);
    expect(game.settings.difficulty, Difficulty.normal);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.tap(find.text('Hard'));
    await tester.pump();
    await tester.tap(find.text('30s'));
    await tester.pump();

    await tester.ensureVisible(find.text('Back'));
    await tester.pump();
    await tester.tap(find.text('Back'));
    await tester.pump();

    // 设置已应用到游戏，并写入本地存储。
    expect(game.settings.difficulty, Difficulty.hard);
    expect(game.settings.roundDuration, 30);
    expect(find.byType(ReadyOverlay), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(GameStorage.settingsKey), isNotNull);
  });
}
