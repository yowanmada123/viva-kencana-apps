import 'dart:convert';
import 'package:flutter/foundation.dart';

class WHBin {
  final String millId;
  final String whId;
  final String binId;
  final String descr;
  final String activeFlag;
  final String activeFlagDesc;
  final String whouseName;

  WHBin({
    required this.millId,
    required this.whId,
    required this.binId,
    required this.descr,
    required this.activeFlag,
    required this.activeFlagDesc,
    required this.whouseName,
  });

  WHBin copyWith({
    String? millId,
    String? whId,
    String? binId,
    String? descr,
    String? activeFlag,
    String? activeFlagDesc,
    String? whouseName,
  }) {
    return WHBin(
      millId: millId ?? this.millId,
      whId: whId ?? this.whId,
      binId: binId ?? this.binId,
      descr: descr ?? this.descr,
      activeFlag: activeFlag ?? this.activeFlag,
      activeFlagDesc: activeFlagDesc ?? this.activeFlagDesc,
      whouseName: whouseName ?? this.whouseName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millId,
      'wh_id': whId,
      'bin_id': binId,
      'descr': descr,
      'active_flag': activeFlag,
      'active_flag_desc': activeFlagDesc,
      'whouse_name': whouseName,
    };
  }

  factory WHBin.fromMap(Map<String, dynamic> map) {
    return WHBin(
      millId: map['mill_id']?.toString().trim() ?? '',
      whId: map['wh_id']?.toString().trim() ?? '',
      binId: map['bin_id']?.toString().trim() ?? '',
      descr: map['descr']?.toString().trim() ?? '',
      activeFlag: map['active_flag']?.toString().trim() ?? '',
      activeFlagDesc: map['active_flag_desc']?.toString().trim() ?? '',
      whouseName: map['whouse_name']?.toString().trim() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WHBin.fromJson(String source) => WHBin.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WHBin &&
        other.millId == millId &&
        other.whId == whId &&
        other.binId == binId;
  }

  @override
  int get hashCode => millId.hashCode ^ whId.hashCode ^ binId.hashCode;
}
