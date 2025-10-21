enum Priority { high, medium, low }

class Task {
  final String id;
  String name;
  bool completed;
  Priority priority;

  Task({
    required this.id,
    required this.name,
    this.completed = false,
    this.priority = Priority.medium,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        name: j['name'] as String,
        completed: j['completed'] as bool,
        priority: Priority.values.firstWhere(
          (p) => p.name == (j['priority'] as String? ?? 'medium'),
          orElse: () => Priority.medium,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'completed': completed,
        'priority': priority.name,
      };
}
