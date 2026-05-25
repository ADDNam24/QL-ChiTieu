class RecurringTransactionModel {
  const RecurringTransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.walletId,
    required this.cycle,
    required this.nextRunDate,
    required this.note,
    required this.isActive,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final int walletId;
  final String cycle;
  final DateTime nextRunDate;
  final String note;
  final bool isActive;
  final DateTime createdAt;

  RecurringTransactionModel copyWith({DateTime? nextRunDate}) {
    return RecurringTransactionModel(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      walletId: walletId,
      cycle: cycle,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      note: note,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type,
    'category': category,
    'wallet_id': walletId,
    'cycle': cycle,
    'next_run_date': nextRunDate.toIso8601String(),
    'note': note,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) =>
      RecurringTransactionModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        category: map['category'] as String,
        walletId: map['wallet_id'] as int? ?? 1,
        cycle: map['cycle'] as String,
        nextRunDate: DateTime.parse(map['next_run_date'] as String),
        note: map['note'] as String? ?? '',
        isActive: (map['is_active'] as int? ?? 1) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
