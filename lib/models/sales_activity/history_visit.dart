import 'dart:convert';

class HistoryVisit {
  final String entityId;
  final String trId;
  final String salesId;
  final String officeId;
  final String userId2;
  final String trDate;
  final String trModified;
  final String employeeId;
  HistoryVisit({
    required this.entityId,
    required this.trId,
    required this.salesId,
    required this.officeId,
    required this.userId2,
    required this.trDate,
    required this.trModified,
    required this.employeeId,
  });

  HistoryVisit copyWith({
    String? entityId,
    String? trId,
    String? salesId,
    String? officeId,
    String? userId2,
    String? trDate,
    String? trModified,
    String? employeeId,
  }) {
    return HistoryVisit(
      entityId: entityId ?? this.entityId,
      trId: trId ?? this.trId,
      salesId: salesId ?? this.salesId,
      officeId: officeId ?? this.officeId,
      userId2: userId2 ?? this.userId2,
      trDate: trDate ?? this.trDate,
      trModified: trModified ?? this.trModified,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'tr_id': trId,
      'sales_id': salesId,
      'office_id': officeId,
      'user_id2': userId2,
      'tr_date': trDate,
      'tr_modified': trModified,
      'employee_id': employeeId,
    };
  }

  factory HistoryVisit.fromMap(Map<String, dynamic> map) {
    return HistoryVisit(
      entityId: map['entity_id'] ?? '',
      trId: map['tr_id'] ?? '',
      salesId: map['sales_id'] ?? '',
      officeId: map['office_id'] ?? '',
      userId2: map['user_id2'] ?? '',
      trDate: map['tr_date'] ?? '',
      trModified: map['tr_modified'] ?? '',
      employeeId: map['employee_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryVisit.fromJson(String source) => HistoryVisit.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HistoryVisit(entityId: $entityId, trId: $trId, salesId: $salesId, officeId: $officeId, userId2: $userId2, trDate: $trDate, trModified: $trModified, employeeId: $employeeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HistoryVisit &&
      other.entityId == entityId &&
      other.trId == trId &&
      other.salesId == salesId &&
      other.officeId == officeId &&
      other.userId2 == userId2 &&
      other.trDate == trDate &&
      other.trModified == trModified &&
      other.employeeId == employeeId;
  }

  @override
  int get hashCode {
    return entityId.hashCode ^
      trId.hashCode ^
      salesId.hashCode ^
      officeId.hashCode ^
      userId2.hashCode ^
      trDate.hashCode ^
      trModified.hashCode ^
      employeeId.hashCode;
  }
}