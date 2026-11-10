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
  final List<DelivHdrItem> delivHdrItems;

  DriverDelivery({
    this.companyId = '',
    this.officeId = '',
    this.deptId = '',
    this.idEmployee = '',
    this.name = '',
    this.entity = '',
    this.millId = '',
    this.millName = '',
    this.trId = '',
    this.driverId = '',
    this.vehicleId = '',
    this.destination = '',
    this.trDate = '',
    this.userId = '',
    this.dtConfirm1 = '',
    this.dtConfirm2 = '',
    this.dtArrive = '',
    this.dtDrop = '',
    this.dtLeave = '',
    this.dtHome = '',
    this.delivHdrItems = const [],
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
    List<DelivHdrItem>? delivHdrItems,
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
      delivHdrItems: delivHdrItems ?? this.delivHdrItems,
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
      'delivHdrItems': delivHdrItems.map((x) => x.toMap()).toList(),
    };
  }

  factory DriverDelivery.fromMap(Map<String, dynamic> map) {
    List<DelivHdrItem> items = [];
    if (map['delivHdrItems'] != null && map['delivHdrItems'] is List) {
      items = (map['delivHdrItems'] as List)
          .whereType<Map>()
          .map((item) => DelivHdrItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    String parsedDestination = (map['destination'] ?? '').toString().trim();
    if (parsedDestination.isEmpty && items.isNotEmpty) {
      final shiptos = items
          .map((e) => e.shipto.isNotEmpty ? e.shipto : e.receiver)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      parsedDestination = shiptos.join(', ');
    }

    return DriverDelivery(
      companyId: (map['company_id'] ?? '').toString().trim(),
      officeId: (map['office_id'] ?? '').toString().trim(),
      deptId: (map['dept_id'] ?? '').toString().trim(),
      idEmployee: (map['idemployee'] ?? map['id_employee'] ?? '').toString().trim(),
      name: (map['name'] ?? '').toString().trim(),
      entity: (map['entity'] ?? '').toString().trim(),
      millId: (map['mill_id'] ?? '').toString().trim(),
      millName: (map['mill_name'] ?? '').toString().trim(),
      trId: (map['tr_id'] ?? '').toString().trim(),
      driverId: (map['driver_id'] ?? '').toString().trim(),
      vehicleId: (map['vehicle_id'] ?? '').toString().trim(),
      destination: parsedDestination,
      trDate: (map['tr_date'] ?? '').toString().trim(),
      userId: (map['user_id'] ?? '').toString().trim(),
      dtConfirm1: (map['dt_confirm1'] ?? '').toString().trim(),
      dtConfirm2: (map['dt_confirm2'] ?? '').toString().trim(),
      dtArrive: (map['dt_arrive'] ?? '').toString().trim(),
      dtDrop: (map['dt_drop'] ?? '').toString().trim(),
      dtLeave: (map['dt_leave'] ?? '').toString().trim(),
      dtHome: (map['dt_home'] ?? '').toString().trim(),
      delivHdrItems: items,
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

class DelivHdrItem {
  final String delivId;
  final String orderId;
  final String millId;
  final String trType;
  final String trId;
  final String shipDate;
  final String shipto;
  final String receiver;
  final String receiverPhone;
  final String stat;
  final String dtArrive;
  final String dtDrop;
  final String totWeight;
  final String totPcs;

  DelivHdrItem({
    this.delivId = '',
    this.orderId = '',
    this.millId = '',
    this.trType = '',
    this.trId = '',
    this.shipDate = '',
    this.shipto = '',
    this.receiver = '',
    this.receiverPhone = '',
    this.stat = '',
    this.dtArrive = '',
    this.dtDrop = '',
    this.totWeight = '',
    this.totPcs = '',
  });

  factory DelivHdrItem.fromMap(Map<String, dynamic> map) {
    return DelivHdrItem(
      delivId: (map['deliv_id'] ?? '').toString().trim(),
      orderId: (map['order_id'] ?? '').toString().trim(),
      millId: (map['mill_id'] ?? '').toString().trim(),
      trType: (map['tr_type'] ?? '').toString().trim(),
      trId: (map['tr_id'] ?? map['batch_id'] ?? '').toString().trim(),
      shipDate: (map['ship_date'] ?? '').toString().trim(),
      shipto: (map['shipto'] ?? map['address'] ?? '').toString().trim(),
      receiver: (map['receiver'] ?? map['cust_name'] ?? '').toString().trim(),
      receiverPhone: (map['receiver_phone'] ?? map['receiver_phone2'] ?? '').toString().trim(),
      stat: (map['stat'] ?? '').toString().trim(),
      dtArrive: (map['dt_arrive'] ?? '').toString().trim(),
      dtDrop: (map['dt_drop'] ?? '').toString().trim(),
      totWeight: (map['tot_weight'] ?? map['weight'] ?? '').toString().trim(),
      totPcs: (map['tot_pcs'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deliv_id': delivId,
      'order_id': orderId,
      'mill_id': millId,
      'tr_type': trType,
      'tr_id': trId,
      'ship_date': shipDate,
      'shipto': shipto,
      'receiver': receiver,
      'receiver_phone': receiverPhone,
      'stat': stat,
      'dt_arrive': dtArrive,
      'dt_drop': dtDrop,
      'tot_weight': totWeight,
      'tot_pcs': totPcs,
    };
  }

  String toJson() => json.encode(toMap());

  factory DelivHdrItem.fromJson(String source) =>
      DelivHdrItem.fromMap(json.decode(source));

  bool get hasArrived =>
      dtArrive.isNotEmpty && !dtArrive.startsWith('1900-01-01') && dtArrive != 'null';
  bool get hasDropped =>
      dtDrop.isNotEmpty && !dtDrop.startsWith('1900-01-01') && dtDrop != 'null';
}

class DriverDeliveryDetailItem {
  final String namaBarang;
  final num qtyShip;
  final String panjang;

  DriverDeliveryDetailItem({
    required this.namaBarang,
    required this.qtyShip,
    required this.panjang,
  });

  factory DriverDeliveryDetailItem.fromMap(Map<String, dynamic> map) {
    return DriverDeliveryDetailItem(
      namaBarang: (map['NamaBarang'] ?? map['nama_barang'] ?? map['descr'] ?? '').toString().trim(),
      qtyShip: num.tryParse((map['qty_ship'] ?? '0').toString()) ?? 0,
      panjang: (map['panjang'] ?? map['Panjang'] ?? map['length_ship'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'NamaBarang': namaBarang,
      'qty_ship': qtyShip,
      'panjang': panjang,
    };
  }

  String toJson() => json.encode(toMap());

  factory DriverDeliveryDetailItem.fromJson(String source) =>
      DriverDeliveryDetailItem.fromMap(json.decode(source));
}
