import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'local_store.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final _uuid = const Uuid();
  List<Task> _tasks = [];
  Priority _newPriority = Priority.medium;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await LocalStore.loadTasks();
    setState(() {
      _tasks = _sorted(loaded);
    });
  }

  Future<void> _save() async => LocalStore.saveTasks(_tasks);

  List<Task> _sorted(List<Task> list) {
    int rank(Priority p) => switch (p) { Priority.high => 0, Priority.medium => 1, Priority.low => 2 };
    final sorted = [...list]..sort((a, b) {
        final byPriority = rank(a.priority).compareTo(rank(b.priority));
        if (byPriority != 0) return byPriority;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted;
  }

  void _addTask() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _tasks.add(Task(
        id: _uuid.v4(),
        name: name,
        completed: false,
        priority: _newPriority,
      ));
      _tasks = _sorted(_tasks);
      _ctrl.clear();
      _newPriority = Priority.medium;
    });
    _save();
  }

  void _toggleComplete(Task t, bool v) {
    setState(() {
      t.completed = v;
      _tasks = _sorted(_tasks);
    });
    _save();
  }

  void _deleteTask(Task t) {
    setState(() {
      _tasks.removeWhere((x) => x.id == t.id);
    });
    _save();
  }

  void _changePriority(Task t, Priority p) {
    setState(() {
      t.priority = p;
      _tasks = _sorted(_tasks);
    });
    _save();
  }

  Widget _priorityChip(Priority p) {
    final label = switch (p) { Priority.high => 'High', Priority.medium => 'Medium', Priority.low => 'Low' };
    return Chip(label: Text(label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'New task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<Priority>(
                  value: _newPriority,
                  onChanged: (p) => setState(() => _newPriority = p ?? Priority.medium),
                  items: const [
                    DropdownMenuItem(value: Priority.high, child: Text('High')),
                    DropdownMenuItem(value: Priority.medium, child: Text('Medium')),
                    DropdownMenuItem(value: Priority.low, child: Text('Low')),
                  ],
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet'))
                : ListView.separated(
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final t = _tasks[i];
                      return ListTile(
                        leading: Checkbox(
                          value: t.completed,
                          onChanged: (v) => _toggleComplete(t, v ?? false),
                        ),
                        title: Text(
                          t.name,
                          style: t.completed
                              ? const TextStyle(decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        subtitle: _priorityChip(t.priority),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<Priority>(
                              tooltip: 'Change priority',
                              onSelected: (p) => _changePriority(t, p),
                              itemBuilder: (c) => const [
                                PopupMenuItem(value: Priority.high, child: Text('High')),
                                PopupMenuItem(value: Priority.medium, child: Text('Medium')),
                                PopupMenuItem(value: Priority.low, child: Text('Low')),
                              ],
                              child: const Icon(Icons.flag),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteTask(t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
