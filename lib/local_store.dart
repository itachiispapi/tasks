import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class LocalStore {
  static const _kTasks = 'tasks';
  static const _kThemeMode = 'themeMode'; // light, dark, system

  static Future<List<Task>> loadTasks() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kTasks) ?? <String>[];
    return raw
        .map((s) => Task.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final sp = await SharedPreferences.getInstance();
    final enc = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await sp.setStringList(_kTasks, enc);
  }

  static Future<String> loadThemeMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kThemeMode) ?? 'system';
  }

  static Future<void> saveThemeMode(String mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeMode, mode);
  }
}
