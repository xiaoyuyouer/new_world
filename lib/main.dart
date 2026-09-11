import 'package:flutter/material.dart';

import 'app/dodge_app.dart';

/// 应用的程序入口。
void main() {
  // 确保 Flutter 绑定已经初始化，之后再启动应用。
  WidgetsFlutterBinding.ensureInitialized();
  // 创建 Flutter 应用的根 Widget。
  runApp(const DodgeApp());
}
