class SavingGoalModel {
  const SavingGoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.dueDate,
    required this.note,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime dueDate;
  final String note;
  final DateTime createdAt;

  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  SavingGoalModel copyWith({double? currentAmount}) => SavingGoalModel(
    id: id,
    name: name,
    targetAmount: targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    dueDate: dueDate,
    note: note,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'due_date': dueDate.toIso8601String(),
    'note': note,
    'created_at': createdAt.toIso8601String(),
  };

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) => SavingGoalModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    targetAmount: (map['target_amount'] as num).toDouble(),
    currentAmount: (map['current_amount'] as num).toDouble(),
    dueDate: DateTime.parse(map['due_date'] as String),
    note: map['note'] as String? ?? '',
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
