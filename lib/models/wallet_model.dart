import 'package:flutter/material.dart';

class WalletModel {
  const WalletModel({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String type;
  final double balance;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  WalletModel copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    int? iconCodePoint,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'balance': balance,
    'icon_code_point': iconCodePoint,
    'color_value': colorValue,
    'created_at': createdAt.toIso8601String(),
  };

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: (map['balance'] as num).toDouble(),
      iconCodePoint: map['icon_code_point'] as int,
      colorValue: map['color_value'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
