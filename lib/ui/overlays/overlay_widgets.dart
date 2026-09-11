import 'package:flutter/material.dart';

/// 游戏 Overlay 统一使用的深色主题。
final ThemeData gameOverlayTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4FC3F7),
    secondary: Color(0xFF4FC3F7),
    surface: Color(0xFF232538),
  ),
);

/// Overlay 通用容器：半透明背景、居中卡片和滚动支持。
class OverlayScaffold extends StatelessWidget {
  /// 创建一个通用 Overlay 容器。
  const OverlayScaffold({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.dim = true,
  });

  /// 卡片内部要显示的页面内容。
  final Widget child;

  /// 卡片最大宽度，防止桌面窗口过宽时内容被拉开。
  final double maxWidth;

  /// 是否显示覆盖在游戏画面上的黑色半透明遮罩。
  final bool dim;

  /// 构建 Overlay 容器。
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: gameOverlayTheme,
      child: Container(
        color: dim ? Colors.black.withValues(alpha: 0.6) : null,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              color: const Color(0xFF232538),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [child],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay 页面顶部的标题和可选副标题。
class OverlayTitle extends StatelessWidget {
  /// 创建一个标题组件。
  const OverlayTitle(this.text, {super.key, this.subtitle});

  /// 主标题文本。
  final String text;

  /// 可选的说明文本。
  final String? subtitle;

  /// 构建标题区域。
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 15),
          ),
        ],
      ],
    );
  }
}

/// 游戏菜单统一使用的按钮样式。
class GameButton extends StatelessWidget {
  /// 创建一个菜单按钮。
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
  });

  /// 按钮显示文字。
  final String label;

  /// 按钮点击回调。
  final VoidCallback? onPressed;

  /// 可选的按钮图标。
  final IconData? icon;

  /// 是否使用主要按钮样式。
  final bool primary;

  /// 根据 primary 选择 FilledButton 或 OutlinedButton。
  @override
  Widget build(BuildContext context) {
    // 图标和文字组成按钮内部内容。
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label),
      ],
    );

    // 统一所有菜单按钮的内边距和字体。
    final style = ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

    if (primary) {
      return FilledButton(onPressed: onPressed, style: style, child: content);
    }
    return OutlinedButton(onPressed: onPressed, style: style, child: content);
  }
}

/// 设置页面中的通用选项行。
///
/// T 可以是枚举、数字或其他可比较的选项类型。
class ChoiceRow<T> extends StatelessWidget {
  /// 创建一组选项标签。
  const ChoiceRow({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.labelOf,
    required this.onChanged,
  });

  /// 选项行标题。
  final String label;

  /// 所有可选值。
  final List<T> options;

  /// 当前选中的值。
  final T value;

  /// 把选项转换成界面文字。
  final String Function(T option) labelOf;

  /// 用户选择新值时的回调。
  final ValueChanged<T> onChanged;

  /// 构建标题和 ChoiceChip 列表。
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == value,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}
