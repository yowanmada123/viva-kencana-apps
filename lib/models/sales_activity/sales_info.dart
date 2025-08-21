import 'dart:convert';

class SalesInfo {
  final String companyId;
  final String employeeId;
  final String salesId;
  final String salesName;
  final String officeId;
  final String officeName;
  final String officeAddress;
  final String officeLat;
  final String officeLng;
  final String userId;
  final String todayCheckin;
  final String todayCheckout;
  SalesInfo({
    required this.companyId,
    required this.employeeId,
    required this.salesId,
    required this.salesName,
    required this.officeId,
    required this.officeName,
    required this.officeAddress,
    required this.officeLat,
    required this.officeLng,
    required this.userId,
    required this.todayCheckin,
    required this.todayCheckout,
  });

  SalesInfo copyWith({
    String? companyId,
    String? employeeId,
    String? salesId,
    String? salesName,
    String? officeId,
    String? officeName,
    String? officeAddress,
    String? officeLat,
    String? officeLng,
    String? userId,
    String? todayCheckin,
    String? todayCheckout,
  }) {
    return SalesInfo(
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      salesId: salesId ?? this.salesId,
      salesName: salesName ?? this.salesName,
      officeId: officeId ?? this.officeId,
      officeName: officeName ?? this.officeName,
      officeAddress: officeAddress ?? this.officeAddress,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
      userId: userId ?? this.userId,
      todayCheckin: todayCheckin ?? this.todayCheckin,
      todayCheckout: todayCheckout ?? this.todayCheckout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_id': companyId,
      'employee_id': employeeId,
      'sales_id': salesId,
      'sales_name': salesName,
      'office_id': officeId,
      'office_name': officeName,
      'office_address': officeAddress,
      'office_lat': officeLat,
      'office_lng': officeLng,
      'user_id': userId,
      'today_checkin': todayCheckin,
      'today_checkout': todayCheckout,
    };
  }

  factory SalesInfo.fromMap(Map<String, dynamic> map) {
    return SalesInfo(
      companyId: map['company_id'] ?? '',
      employeeId: map['employee_id'] ?? '',
      salesId: map['sales_id'] ?? '',
      salesName: map['sales_name'] ?? '',
      officeId: map['office_id'] ?? '',
      officeName: map['office_name'] ?? '',
      officeAddress: map['office_address'] ?? '',
      officeLat: map['office_lat'] ?? '',
      officeLng: map['office_lng'] ?? '',
      userId: map['user_id'] ?? '',
      todayCheckin: map['today_checkin'] ?? '',
      todayCheckout: map['today_checkout'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesInfo.fromJson(String source) => SalesInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SalesInfo(companyId: $companyId, employeeId: $employeeId, salesId: $salesId, salesName: $salesName, officeId: $officeId, officeName: $officeName, officeAddress: $officeAddress, officeLat: $officeLat, officeLng: $officeLng, userId: $userId, todayCheckin: $todayCheckin, todayCheckout: $todayCheckout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SalesInfo &&
      other.companyId == companyId &&
      other.employeeId == employeeId &&
      other.salesId == salesId &&
      other.salesName == salesName &&
      other.officeId == officeId &&
      other.officeName == officeName &&
      other.officeAddress == officeAddress &&
      other.officeLat == officeLat &&
      other.officeLng == officeLng &&
      other.userId == userId &&
      other.todayCheckin == todayCheckin &&
      other.todayCheckout == todayCheckout;
  }

  @override
  int get hashCode {
    return companyId.hashCode ^
      employeeId.hashCode ^
      salesId.hashCode ^
      salesName.hashCode ^
      officeId.hashCode ^
      officeName.hashCode ^
      officeAddress.hashCode ^
      officeLat.hashCode ^
      officeLng.hashCode ^
      userId.hashCode ^
      todayCheckin.hashCode ^
      todayCheckout.hashCode;
  }
}
