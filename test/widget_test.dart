import 'package:new_world/app/dodge_app.dart';
import 'package:flutter_test/flutter_test.dart';

/// 应用启动相关的最小 Widget 测试。
void main() {
  /// 确认根应用可以被 Flutter 测试框架正常挂载。
  testWidgets('launches dodge game', (tester) async {
    await tester.pumpWidget(const DodgeApp());
    expect(find.byType(DodgeApp), findsOneWidget);
  });
}
