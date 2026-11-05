import 'dart:convert';

class DriverDelivery {
  final String companyId;
  final String officeId;
  final String deptId;
  final String idEmployee;
  final String name;
  final String entity;
  final String millId;
  final String millName;
  final String trId;
  final String driverId;
  final String vehicleId;
  final String destination;
  final String trDate;
  final String userId;
  final String dtConfirm1;
  final String dtConfirm2;
  final String dtArrive;
  final String dtDrop;
  final String dtLeave;
  final String dtHome;

  DriverDelivery({
    required this.companyId,
    required this.officeId,
    required this.deptId,
    required this.idEmployee,
    required this.name,
    required this.entity,
    required this.millId,
    required this.millName,
    required this.trId,
    required this.driverId,
    required this.vehicleId,
    required this.destination,
    required this.trDate,
    required this.userId,
    required this.dtConfirm1,
    required this.dtConfirm2,
    required this.dtArrive,
    required this.dtDrop,
    required this.dtLeave,
    required this.dtHome,
  });

  DriverDelivery copyWith({
    String? companyId,
    String? officeId,
    String? deptId,
    String? idEmployee,
    String? name,
    String? entity,
    String? millId,
    String? millName,
    String? trId,
    String? driverId,
    String? vehicleId,
    String? destination,
    String? trDate,
    String? userId,
    String? dtConfirm1,
    String? dtConfirm2,
    String? dtArrive,
    String? dtDrop,
    String? dtLeave,
    String? dtHome,
  }) {
    return DriverDelivery(
      companyId: companyId ?? this.companyId,
      officeId: officeId ?? this.officeId,
      deptId: deptId ?? this.deptId,
      idEmployee: idEmployee ?? this.idEmployee,
      name: name ?? this.name,
      entity: entity ?? this.entity,
      millId: millId ?? this.millId,
      millName: millName ?? this.millName,
      trId: trId ?? this.trId,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      destination: destination ?? this.destination,
      trDate: trDate ?? this.trDate,
      userId: userId ?? this.userId,
      dtConfirm1: dtConfirm1 ?? this.dtConfirm1,
      dtConfirm2: dtConfirm2 ?? this.dtConfirm2,
      dtArrive: dtArrive ?? this.dtArrive,
      dtDrop: dtDrop ?? this.dtDrop,
      dtLeave: dtLeave ?? this.dtLeave,
      dtHome: dtHome ?? this.dtHome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_id': companyId,
      'office_id': officeId,
      'dept_id': deptId,
      'idemployee': idEmployee,
      'name': name,
      'entity': entity,
      'mill_id': millId,
      'mill_name': millName,
      'tr_id': trId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'destination': destination,
      'tr_date': trDate,
      'user_id': userId,
      'dt_confirm1': dtConfirm1,
      'dt_confirm2': dtConfirm2,
      'dt_arrive': dtArrive,
      'dt_drop': dtDrop,
      'dt_leave': dtLeave,
      'dt_home': dtHome,
    };
  }

  factory DriverDelivery.fromMap(Map<String, dynamic> map) {
    return DriverDelivery(
      companyId: (map['company_id'] ?? '').toString().trim(),
      officeId: (map['office_id'] ?? '').toString().trim(),
      deptId: (map['dept_id'] ?? '').toString().trim(),
      idEmployee: (map['idemployee'] ?? '').toString().trim(),
      name: (map['name'] ?? '').toString().trim(),
      entity: (map['entity'] ?? '').toString().trim(),
      millId: (map['mill_id'] ?? '').toString().trim(),
      millName: (map['mill_name'] ?? '').toString().trim(),
      trId: (map['tr_id'] ?? '').toString().trim(),
      driverId: (map['driver_id'] ?? '').toString().trim(),
      vehicleId: (map['vehicle_id'] ?? '').toString().trim(),
      destination: (map['destination'] ?? '').toString().trim(),
      trDate: (map['tr_date'] ?? '').toString().trim(),
      userId: (map['user_id'] ?? '').toString().trim(),
      dtConfirm1: (map['dt_confirm1'] ?? '').toString().trim(),
      dtConfirm2: (map['dt_confirm2'] ?? '').toString().trim(),
      dtArrive: (map['dt_arrive'] ?? '').toString().trim(),
      dtDrop: (map['dt_drop'] ?? '').toString().trim(),
      dtLeave: (map['dt_leave'] ?? '').toString().trim(),
      dtHome: (map['dt_home'] ?? '').toString().trim(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverDelivery.fromJson(String source) =>
      DriverDelivery.fromMap(json.decode(source));

  // Helper flags
  bool get hasLeft =>
      dtLeave.isNotEmpty && !dtLeave.startsWith('1900-01-01');
  bool get hasArrived =>
      dtArrive.isNotEmpty && !dtArrive.startsWith('1900-01-01');
  bool get hasDropped =>
      dtDrop.isNotEmpty && !dtDrop.startsWith('1900-01-01');
  bool get isCompleted =>
      dtHome.isNotEmpty && !dtHome.startsWith('1900-01-01');

  String get statusText {
    if (isCompleted) return 'Selesai';
    if (hasDropped) return 'Selesai Bongkar';
    if (hasArrived) return 'Tiba di Lokasi';
    if (hasLeft) return 'Dalam Perjalanan';
    return 'Siap Dikirim';
  }
}

