class ReminderModel {
  const ReminderModel({
    this.id,
    required this.title,
    required this.type,
    required this.timeText,
    required this.isActive,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String type;
  final String timeText;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type,
    'time_text': timeText,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory ReminderModel.fromMap(Map<String, dynamic> map) => ReminderModel(
    id: map['id'] as int?,
    title: map['title'] as String,
    type: map['type'] as String,
    timeText: map['time_text'] as String,
    isActive: (map['is_active'] as int? ?? 1) == 1,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
