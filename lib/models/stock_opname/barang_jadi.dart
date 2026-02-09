import 'dart:convert';
import 'package:flutter/foundation.dart';

class BarangJadi {
  final String barangJadiId;
  final String namaBarang;
  final String grade;

  BarangJadi({
    required this.barangJadiId,
    required this.namaBarang,
    required this.grade,
  });

  BarangJadi copyWith({
    String? barangJadiId,
    String? namaBarang,
    String? grade,
  }) {
    return BarangJadi(
      barangJadiId: barangJadiId ?? this.barangJadiId,
      namaBarang: namaBarang ?? this.namaBarang,
      grade: grade ?? this.grade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'BarangJadiId': barangJadiId,
      'NamaBarang': namaBarang,
      'grade': grade,
    };
  }

  factory BarangJadi.fromMap(Map<String, dynamic> map) {
    return BarangJadi(
      barangJadiId: map['BarangJadiId'] ?? '',
      namaBarang: map['NamaBarang'] ?? '',
      grade: map['grade'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BarangJadi.fromJson(String source) =>
      BarangJadi.fromMap(json.decode(source));

  @override
  String toString() =>
      'BarangJadi(id: $barangJadiId, nama: $namaBarang, grade: $grade)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BarangJadi && other.barangJadiId == barangJadiId;
  }

  @override
  int get hashCode => barangJadiId.hashCode;
}
