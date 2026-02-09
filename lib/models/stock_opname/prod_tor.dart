import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProdTor {
  final String millId;
  final String torId;
  final String descr;
  final double panjang;
  final int jumlah;
  final String activeFlag;
  final String userId;
  final DateTime? dtModified;

  ProdTor({
    required this.millId,
    required this.torId,
    required this.descr,
    required this.panjang,
    required this.jumlah,
    required this.activeFlag,
    required this.userId,
    required this.dtModified,
  });

  ProdTor copyWith({
    String? millId,
    String? torId,
    String? descr,
    double? panjang,
    int? jumlah,
    String? activeFlag,
    String? userId,
    DateTime? dtModified,
  }) {
    return ProdTor(
      millId: millId ?? this.millId,
      torId: torId ?? this.torId,
      descr: descr ?? this.descr,
      panjang: panjang ?? this.panjang,
      jumlah: jumlah ?? this.jumlah,
      activeFlag: activeFlag ?? this.activeFlag,
      userId: userId ?? this.userId,
      dtModified: dtModified ?? this.dtModified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millId,
      'tor_id': torId,
      'descr': descr,
      'panjang': panjang,
      'jumlah': jumlah,
      'active_flag': activeFlag,
      'user_id': userId,
      'dt_modified': dtModified?.toIso8601String(),
    };
  }

  factory ProdTor.fromMap(Map<String, dynamic> map) {
    return ProdTor(
      millId: map['mill_id']?.toString() ?? '',
      torId: map['tor_id']?.toString() ?? '', // ⬅️ INI KUNCI
      descr: map['descr']?.toString() ?? '',
      panjang: (map['panjang'] as num?)?.toDouble() ?? 0.0,
      jumlah: (map['jumlah'] as num?)?.toInt() ?? 0,
      activeFlag: map['active_flag']?.toString() ?? 'Y',
      userId: map['user_id']?.toString() ?? '',
      dtModified:
          map['dt_modified'] != null
              ? DateTime.tryParse(map['dt_modified'].toString())
              : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory ProdTor.fromJson(String source) =>
      ProdTor.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProdTor && other.torId == torId;
  }

  @override
  int get hashCode => torId.hashCode;
}
