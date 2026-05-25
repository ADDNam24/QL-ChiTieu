class TransactionModel {
  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.walletId = 1,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final int walletId;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  bool get isIncome => type == 'income';

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    int? walletId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'wallet_id': walletId,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      walletId: map['wallet_id'] as int? ?? 1,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
