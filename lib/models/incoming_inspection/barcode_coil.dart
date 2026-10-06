import 'dart:convert';

/// Satu baris dari view `v_barcode_coil` (db fg_inv).
///
/// View ini sudah menggabungkan seluruh data: packing list, PO, kontrak, PR,
/// spesifikasi produk, hasil inspeksi, dan status penerimaan. Jadi satu objek
/// ini sudah memuat SEMUA yang perlu ditampilkan di layar detail - tidak perlu
/// hit API lagi saat kartu di list ditekan.
///
/// View sudah memuat 48 kolom termasuk `mill_id` dan `no_kendaraan`, jadi satu
/// objek ini cukup untuk mengisi seluruh layar detail tanpa request tambahan.
class BarcodeCoil {
  // --- identitas mill ---
  final String millId;

  // --- packing list ---
  final String plId;
  final String plItem;

  // --- vendor ---
  final String vendorId;
  final String vendorName;

  // --- coil ---
  final String coilId;
  final String containerId;

  // --- purchase order ---
  final String poId;
  final String poItem;

  // --- kontrak & purchase request ---
  final String contrId;
  final String contrItem;
  final String prId;
  final String prItem;

  // --- spesifikasi produk ---
  final String prodCode;
  final String descr;
  final double thick;
  final double width;
  final double wgtNet;
  final double wgtGross;
  final String unitMeas;
  final String unitMeasPo;
  final double unitConv;

  // --- organisasi & gudang ---
  final String deptId;
  final String sectId;
  final String whId;

  // --- harga ---
  final String currId;
  final double currRate;
  final double unitPrice;

  // --- status ---
  /// 'O' = belum diinspeksi (open), 'C' = sudah diinspeksi (closed)
  final String statInspection;

  /// 'O' = belum diterima, 'C' = sudah diterima
  final String statRcv;

  // --- inspection_hdr (null kalau belum pernah diinspeksi) ---
  final String trxId;
  final String noSj;
  final String noKendaraan;
  final DateTime? dtTrx;
  final String shiftNum;
  final String crewId;
  final String cuaca;
  final String tAtap;
  final String tKondisi;
  final DateTime? startTime;
  final DateTime? endTime;
  final String storage;

  // --- inspection_dtl ---
  final String od;
  final String strapping;
  final String surface;
  final String area;
  final String remark;

  /// Berat menurut label fisik yang dicatat saat inspeksi, hasil dari
  /// inspection_dtl.wgt_label. Bisa berbeda dari [wgtNet] kalau angka di label
  /// tidak sama dengan data sistem.
  final double wgtLabel;

  // --- pr_tran_unit ---
  final String trId;

  BarcodeCoil({
    required this.millId,
    required this.plId,
    required this.plItem,
    required this.vendorId,
    required this.vendorName,
    required this.coilId,
    required this.containerId,
    required this.poId,
    required this.poItem,
    required this.contrId,
    required this.contrItem,
    required this.prId,
    required this.prItem,
    required this.prodCode,
    required this.descr,
    required this.thick,
    required this.width,
    required this.wgtNet,
    required this.wgtGross,
    required this.unitMeas,
    required this.unitMeasPo,
    required this.unitConv,
    required this.deptId,
    required this.sectId,
    required this.whId,
    required this.currId,
    required this.currRate,
    required this.unitPrice,
    required this.statInspection,
    required this.statRcv,
    required this.trxId,
    required this.noSj,
    required this.noKendaraan,
    required this.dtTrx,
    required this.shiftNum,
    required this.crewId,
    required this.cuaca,
    required this.tAtap,
    required this.tKondisi,
    required this.startTime,
    required this.endTime,
    required this.storage,
    required this.od,
    required this.strapping,
    required this.surface,
    required this.area,
    required this.remark,
    required this.wgtLabel,
    required this.trId,
  });

  /// true kalau coil ini belum pernah diinspeksi, jadi boleh dipilih di form
  /// pembuatan inspeksi baru.
  bool get isOpenInspection => statInspection.toUpperCase() != 'C';

  /// true kalau coil sudah diterima di gudang (pr_tran_unit sudah terisi).
  bool get isReceived => statRcv.toUpperCase() == 'C';

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millId,
      'pl_id': plId,
      'pl_item': plItem,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'coil_id': coilId,
      'container_id': containerId,
      'po_id': poId,
      'po_item': poItem,
      'contr_id': contrId,
      'contr_item': contrItem,
      'pr_id': prId,
      'pr_item': prItem,
      'prod_code': prodCode,
      'descr': descr,
      'thick': thick,
      'width': width,
      'wgt_net': wgtNet,
      'wgt_gross': wgtGross,
      'unit_meas': unitMeas,
      'unit_meas_po': unitMeasPo,
      'unit_conv': unitConv,
      'dept_id': deptId,
      'sect_id': sectId,
      'wh_id': whId,
      'curr_id': currId,
      'curr_rate': currRate,
      'unit_price': unitPrice,
      'stat_inspection': statInspection,
      'stat_rcv': statRcv,
      'trx_id': trxId,
      'no_sj': noSj,
      'no_kendaraan': noKendaraan,
      'dt_trx': dtTrx?.toIso8601String(),
      'shift_num': shiftNum,
      'crew_id': crewId,
      'cuaca': cuaca,
      't_atap': tAtap,
      't_kondisi': tKondisi,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'storage': storage,
      'od': od,
      'strapping': strapping,
      'surface': surface,
      'area': area,
      'remark': remark,
      'wgt_label': wgtLabel,
      'tr_id': trId,
    };
  }

  factory BarcodeCoil.fromMap(Map<String, dynamic> map) {
    return BarcodeCoil(
      millId: _str(map['mill_id']),
      plId: _str(map['pl_id']),
      plItem: _str(map['pl_item']),
      vendorId: _str(map['vendor_id']),
      vendorName: _str(map['vendor_name']),
      coilId: _str(map['coil_id']),
      containerId: _str(map['container_id']),
      poId: _str(map['po_id']),
      poItem: _str(map['po_item']),
      contrId: _str(map['contr_id']),
      contrItem: _str(map['contr_item']),
      prId: _str(map['pr_id']),
      prItem: _str(map['pr_item']),
      prodCode: _str(map['prod_code']),
      descr: _str(map['descr']),
      thick: _dbl(map['thick']),
      width: _dbl(map['width']),
      wgtNet: _dbl(map['wgt_net']),
      wgtGross: _dbl(map['wgt_gross']),
      unitMeas: _str(map['unit_meas']),
      unitMeasPo: _str(map['unit_meas_po']),
      unitConv: _dbl(map['unit_conv']),
      deptId: _str(map['dept_id']),
      sectId: _str(map['sect_id']),
      whId: _str(map['wh_id']),
      currId: _str(map['curr_id']),
      currRate: _dbl(map['curr_rate']),
      unitPrice: _dbl(map['unit_price']),
      statInspection: _str(map['stat_inspection'], fallback: 'O'),
      statRcv: _str(map['stat_rcv'], fallback: 'O'),
      trxId: _str(map['trx_id']),
      noSj: _str(map['no_sj']),
      noKendaraan: _str(map['no_kendaraan']),
      dtTrx: _date(map['dt_trx']),
      shiftNum: _str(map['shift_num']),
      crewId: _str(map['crew_id']),
      cuaca: _str(map['cuaca']),
      tAtap: _str(map['t_atap']),
      tKondisi: _str(map['t_kondisi']),
      startTime: _date(map['start_time']),
      endTime: _date(map['end_time']),
      storage: _str(map['storage']),
      od: _str(map['od']),
      strapping: _str(map['strapping']),
      surface: _str(map['surface']),
      area: _str(map['area']),
      remark: _str(map['remark']),
      wgtLabel: _dbl(map['wgt_label']),
      trId: _str(map['tr_id']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BarcodeCoil.fromJson(String source) =>
      BarcodeCoil.fromMap(json.decode(source));

  @override
  String toString() => 'BarcodeCoil(coil_id: $coilId, pl_id: $plId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BarcodeCoil && other.coilId == coilId;
  }

  @override
  int get hashCode => coilId.hashCode;
}

// =============================================================================
// Helper parsing. Server SQL Server sering mengirim angka sebagai string dan
// tanggal kosong sebagai '1900-01-01', jadi semuanya dinormalkan di sini.
// =============================================================================

String _str(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

double _dbl(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.startsWith('1900')) return null;
  return DateTime.tryParse(text);
}
