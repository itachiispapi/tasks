import 'package:flutter/material.dart';
import 'local_store.dart';
import 'task_list_screen.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});
  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    LocalStore.loadThemeMode().then((m) {
      setState(() {
        _mode = _parseMode(m);
      });
    });
  }

  ThemeMode _parseMode(String m) {
    switch (m) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _setMode(ThemeMode m) {
    setState(() => _mode = m);
    LocalStore.saveThemeMode(
      m == ThemeMode.light ? 'light' : m == ThemeMode.dark ? 'dark' : 'system',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: _mode,
      home: Builder(
        builder: (context) => Scaffold(
          body: const TaskListScreen(),
          appBar: AppBar(
            title: const Text('CW3'),
            actions: [
              PopupMenuButton<ThemeMode>(
                onSelected: _setMode,
                itemBuilder: (c) => const [
                  PopupMenuItem(value: ThemeMode.system, child: Text('System')),
                  PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
                  PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.color_lens),
                ),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
