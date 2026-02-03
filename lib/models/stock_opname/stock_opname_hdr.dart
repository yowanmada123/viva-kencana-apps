import 'dart:convert';

class StockOpnameHdr {
  final String trId;
  final String millId;
  final String prodCode;
  final String addId;
  final String torId;
  final double panjang;
  final String batchId;
  final String whId;
  final String binId;
  final double qtyAwal;
  final double qtyOpname;
  final String remark;
  final DateTime? dtCek;
  final DateTime? dtModified;
  final String userId;
  final String coilId;

  StockOpnameHdr({
    required this.trId,
    required this.millId,
    required this.prodCode,
    required this.addId,
    required this.torId,
    required this.panjang,
    required this.batchId,
    required this.whId,
    required this.binId,
    required this.qtyAwal,
    required this.qtyOpname,
    required this.remark,
    required this.dtCek,
    required this.dtModified,
    required this.userId,
    required this.coilId,
  });

  /// =======================
  /// COPY WITH
  /// =======================
  StockOpnameHdr copyWith({
    String? trId,
    String? millId,
    String? prodCode,
    String? addId,
    String? torId,
    double? panjang,
    String? batchId,
    String? whId,
    String? binId,
    double? qtyAwal,
    double? qtyOpname,
    String? remark,
    DateTime? dtCek,
    DateTime? dtModified,
    String? userId,
    String? coilId,
  }) {
    return StockOpnameHdr(
      trId: trId ?? this.trId,
      millId: millId ?? this.millId,
      prodCode: prodCode ?? this.prodCode,
      addId: addId ?? this.addId,
      torId: torId ?? this.torId,
      panjang: panjang ?? this.panjang,
      batchId: batchId ?? this.batchId,
      whId: whId ?? this.whId,
      binId: binId ?? this.binId,
      qtyAwal: qtyAwal ?? this.qtyAwal,
      qtyOpname: qtyOpname ?? this.qtyOpname,
      remark: remark ?? this.remark,
      dtCek: dtCek ?? this.dtCek,
      dtModified: dtModified ?? this.dtModified,
      userId: userId ?? this.userId,
      coilId: coilId ?? this.coilId,
    );
  }

  /// =======================
  /// TO MAP
  /// =======================
  Map<String, dynamic> toMap() {
    return {
      'tr_id': trId,
      'mill_id': millId,
      'prod_code': prodCode,
      'add_id': addId,
      'tor_id': torId,
      'panjang': panjang,
      'batch_id': batchId,
      'wh_id': whId,
      'bin_id': binId,
      'qty_awal': qtyAwal,
      'qty_opname': qtyOpname,
      'remark': remark,
      'dt_cek': dtCek?.toIso8601String(),
      'dt_modified': dtModified?.toIso8601String(),
      'user_id': userId,
      'coil_id': coilId,
    };
  }

  /// =======================
  /// FROM MAP (API RESPONSE)
  /// =======================
  factory StockOpnameHdr.fromMap(Map<String, dynamic> map) {
    return StockOpnameHdr(
      trId: map['tr_id'] ?? '',
      millId: map['mill_id'] ?? '',
      prodCode: map['prod_code'] ?? '',
      addId: map['add_id'] ?? '',
      torId: map['tor_id'] ?? '',
      panjang: (map['panjang'] ?? 0).toDouble(),
      batchId: map['batch_id'] ?? '',
      whId: map['wh_id'] ?? '',
      binId: map['bin_id'] ?? '',
      qtyAwal: (map['qty_awal'] ?? 0).toDouble(),
      qtyOpname: (map['qty_opname'] ?? 0).toDouble(),
      remark: map['remark'] ?? '',
      dtCek: map['dt_cek'] != null ? DateTime.parse(map['dt_cek']) : null,
      dtModified:
          map['dt_modified'] != null
              ? DateTime.parse(map['dt_modified'])
              : null,
      userId: map['user_id'] ?? '',
      coilId: map['coil_id'] ?? '',
    );
  }

  /// =======================
  /// JSON
  /// =======================
  String toJson() => json.encode(toMap());

  factory StockOpnameHdr.fromJson(String source) =>
      StockOpnameHdr.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StockOpnameHdr(tr_id: $trId, mill_id: $millId, prod_code: $prodCode, qty_opname: $qtyOpname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StockOpnameHdr &&
        other.trId == trId &&
        other.millId == millId &&
        other.prodCode == prodCode &&
        other.batchId == batchId;
  }

  @override
  int get hashCode {
    return trId.hashCode ^
        millId.hashCode ^
        prodCode.hashCode ^
        batchId.hashCode;
  }
}
