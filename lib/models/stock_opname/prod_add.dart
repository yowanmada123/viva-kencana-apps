import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProdAdd {
  final String millId;
  final String addId;
  final String descr;
  final String activeFlag;
  final String userId;
  final DateTime? dtModified;
  final String str1;
  final String str2;
  final String str3;
  final double price;
  final double priceUnit;

  ProdAdd({
    required this.millId,
    required this.addId,
    required this.descr,
    required this.activeFlag,
    required this.userId,
    required this.dtModified,
    required this.str1,
    required this.str2,
    required this.str3,
    required this.price,
    required this.priceUnit,
  });

  ProdAdd copyWith({
    String? millId,
    String? addId,
    String? descr,
    String? activeFlag,
    String? userId,
    DateTime? dtModified,
    String? str1,
    String? str2,
    String? str3,
    double? price,
    double? priceUnit,
  }) {
    return ProdAdd(
      millId: millId ?? this.millId,
      addId: addId ?? this.addId,
      descr: descr ?? this.descr,
      activeFlag: activeFlag ?? this.activeFlag,
      userId: userId ?? this.userId,
      dtModified: dtModified ?? this.dtModified,
      str1: str1 ?? this.str1,
      str2: str2 ?? this.str2,
      str3: str3 ?? this.str3,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millId,
      'add_id': addId,
      'descr': descr,
      'active_flag': activeFlag,
      'user_id': userId,
      'dt_modified': dtModified?.toIso8601String(),
      'str1': str1,
      'str2': str2,
      'str3': str3,
      'price': price,
      'price_unit': priceUnit,
    };
  }

  factory ProdAdd.fromMap(Map<String, dynamic> map) {
    return ProdAdd(
      millId: map['mill_id'] ?? '',
      addId: map['add_id'] ?? '',
      descr: map['descr'] ?? '',
      activeFlag: map['active_flag'] ?? 'Y',
      userId: map['user_id'] ?? '',
      dtModified:
          map['dt_modified'] != null
              ? DateTime.tryParse(map['dt_modified'].toString())
              : null,
      str1: map['str1'] ?? '',
      str2: map['str2'] ?? '',
      str3: map['str3'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      priceUnit: (map['price_unit'] ?? 0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory ProdAdd.fromJson(String source) =>
      ProdAdd.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProdAdd && other.addId == addId;
  }

  @override
  int get hashCode => addId.hashCode;
}
