/// Data model representing a row in the `tasks` table.
class Task {
  final int? id;
  final String title;
  final String? description;
  final String? dueDate; // Stored as ISO-8601 date string (e.g. '2026-05-06')
  final String? category; // 'penting' (important) or 'biasa' (normal)
  final bool isCompleted;
  final bool isDeleted;

  const Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.category,
    this.isCompleted = false,
    this.isDeleted = false,
  });

  /// Creates a [Task] instance from a SQLite row map.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] as String?,
      category: map['category'] as String?,
      isCompleted: (map['is_completed'] as int?) == 1,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  /// Converts this [Task] into a map suitable for SQLite insertion.
  /// The `id` field is intentionally excluded so that SQLite can
  /// auto-generate it via AUTOINCREMENT.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Returns a copy of this task with the given fields replaced.
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? category,
    bool? isCompleted,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, category: $category, completed: $isCompleted, deleted: $isDeleted)';
}
