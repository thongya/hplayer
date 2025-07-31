class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}