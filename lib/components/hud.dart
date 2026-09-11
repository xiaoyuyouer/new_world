import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/dodge_game.dart';

/// 游戏画面中的信息显示层。
///
/// HUD 只负责把游戏数据显示出来，不负责修改分数、生命或时间。
class GameHud extends Component with HasGameReference<DodgeGame> {
  /// 当前分数文本。
  late final TextComponent _scoreText;

  /// 历史最高分文本。
  late final TextComponent _bestText;

  /// 剩余时间文本。
  late final TextComponent _timerText;

  /// 剩余生命文本。
  late final TextComponent _livesText;

  /// 底部操作提示文本。
  late final TextComponent _hintText;

  /// 上一次显示在屏幕上的整数秒数，避免每帧刷新文字。
  int _lastShownSeconds = -1;

  /// 创建 HUD 中的所有文本组件。
  @override
  Future<void> onLoad() async {
    // 分数、最高分和倒计时显示在左上角。
    _scoreText = _createText(
      text: 'Score: 0',
      position: Vector2(20, 20),
      fontSize: 24,
    );
    _bestText = _createText(
      text: 'Best: 0',
      position: Vector2(20, 54),
      fontSize: 18,
      color: const Color(0xFFB0BEC5),
    );
    _timerText = _createText(
      text: 'Time: ${game.roundDuration}',
      position: Vector2(20, 84),
      fontSize: 24,
    );
    _livesText = _createText(
      text: _livesTextFor(game.maxLives),
      position: Vector2(20, 120),
      fontSize: 22,
      color: const Color(0xFFFF5252),
    );
    // 操作提示使用底部居中锚点，窗口变化时重新计算位置。
    _hintText = _createText(
      text: '← → ↑ ↓ / WASD move · Shift boost · P pause',
      position: Vector2(game.size.x / 2, game.size.y - 16),
      anchor: Anchor.bottomCenter,
      fontSize: 16,
      color: const Color(0xFFB0BEC5),
      fontWeight: FontWeight.normal,
    );

    // 把所有文本一次性加入 HUD 的子组件列表。
    await addAll([_scoreText, _bestText, _timerText, _livesText, _hintText]);
  }

  /// 用统一样式创建一个 Flame 文本组件。
  TextComponent _createText({
    required String text,
    required Vector2 position,
    required double fontSize,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w600,
    Anchor anchor = Anchor.topLeft,
  }) {
    return TextComponent(
      text: text,
      position: position,
      anchor: anchor,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  /// 窗口大小变化时，让底部提示保持水平居中。
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _hintText.position = Vector2(size.x / 2, size.y - 16);
    }
  }

  /// 把生命数量转换成实心和空心爱心组成的文本。
  String _livesTextFor(int lives) =>
      '♥' * lives + '♡' * (game.maxLives - lives);

  /// 更新当前分数文本。
  void updateScore(int score) {
    _scoreText.text = 'Score: $score';
  }

  /// 更新最高分文本。
  void updateHighScore(int highScore) {
    _bestText.text = 'Best: $highScore';
  }

  /// 更新剩余生命文本。
  void updateLives(int lives) {
    _livesText.text = _livesTextFor(lives);
  }

  /// 更新倒计时文本，并在最后十秒切换成红色。
  void updateTimer(double seconds) {
    // 界面只显示整数秒，没有必要每一帧修改文本。
    final display = seconds.ceil();
    if (display == _lastShownSeconds) {
      return;
    }

    _lastShownSeconds = display;
    _timerText.text = 'Time: $display';
    _timerText.textRenderer = _timerTextPaint(display);
  }

  /// 根据剩余秒数创建倒计时文本样式。
  TextPaint _timerTextPaint(int seconds) {
    return TextPaint(
      style: TextStyle(
        color: seconds <= 10 ? const Color(0xFFFF5252) : Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 把 HUD 恢复为新一局的初始显示状态。
  void reset() {
    _scoreText.text = 'Score: 0';
    _lastShownSeconds = -1;
    updateTimer(game.roundDuration.toDouble());
    updateLives(game.maxLives);
  }
}
