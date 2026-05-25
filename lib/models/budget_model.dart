class BudgetModel {
  const BudgetModel({
    this.id,
    required this.monthKey,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  final int? id;
  final String monthKey;
  final String category;
  final double amount;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'month_key': monthKey,
    'category': category,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
    id: map['id'] as int?,
    monthKey: map['month_key'] as String,
    category: map['category'] as String,
    amount: (map['amount'] as num).toDouble(),
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
