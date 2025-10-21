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
    setState(() => _tasks = loaded);
  }

  Future<void> _save() async => LocalStore.saveTasks(_tasks);

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
      _ctrl.clear();
      _newPriority = Priority.medium;
    });
    _save();
  }

  void _toggleComplete(Task t, bool v) {
    setState(() {
      t.completed = v;
    });
    _save();
  }

  void _deleteTask(Task t) {
    setState(() {
      _tasks.removeWhere((x) => x.id == t.id);
    });
    _save();
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
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteTask(t),
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
