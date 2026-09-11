import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';

/// 负责保存和读取游戏数据。
///
/// 游戏逻辑不需要知道 SharedPreferences 的细节，只需要调用这里的
/// load/save 方法即可。
class GameStorage {
  /// 设置在 SharedPreferences 中使用的键。
  static const String settingsKey = 'game_settings';

  /// 最高分在 SharedPreferences 中使用的键。
  static const String highScoreKey = 'high_score';

  /// 从本地读取游戏设置；读取失败时返回默认设置。
  Future<GameSettings> loadSettings() async {
    try {
      // SharedPreferences 适合保存少量简单的本地配置。
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(settingsKey);
      if (raw == null) {
        return const GameSettings();
      }

      // 先把字符串解析成 JSON，再交给 GameSettings 转成业务对象。
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return const GameSettings();
      }
      return GameSettings.fromJson(json);
    } catch (_) {
      return const GameSettings();
    }
  }

  /// 将当前游戏设置序列化后保存到本地。
  Future<void> saveSettings(GameSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(settingsKey, jsonEncode(settings.toJson()));
    } catch (_) {
      // 设置已经保存在内存中；本地写入失败不应阻止游戏运行。
    }
  }

  /// 读取历史最高分；没有记录时从 0 分开始。
  Future<int> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(highScoreKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 保存新的最高分。
  Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(highScoreKey, score);
    } catch (_) {
      // 最高分仍然保留在当前运行的内存中。
    }
  }
}
