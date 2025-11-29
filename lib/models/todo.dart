import 'package:isar/isar.dart';

part 'todo.g.dart';

@collection
class Todo {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @Index()
  late bool isCompleted;

  @enumerated
  late Priority priority;

  String? category;

  late DateTime createdAt;

  DateTime? dueDate;

  DateTime? completedAt;

  Todo({
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category,
    this.dueDate,
    this.completedAt,
  }) {
    createdAt = DateTime.now();
  }
}

enum Priority {
  low,
  medium,
  high,
  urgent,
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Basse';
      case Priority.medium:
        return 'Moyenne';
      case Priority.high:
        return 'Haute';
      case Priority.urgent:
        return 'Urgente';
    }
  }

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
      case Priority.urgent:
        return 4;
    }
  }
}
