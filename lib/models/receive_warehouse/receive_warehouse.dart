import '../mill.dart';

/// Model fitur Receive Warehouse KKA (database KEPUH).
///
/// Semua nilai string dari server di-trim di sini, karena kolom CHAR di
/// SQL Server mengembalikan spasi di ujungnya.

String _str(dynamic v) => (v ?? '').toString().trim();

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(_str(v)) ?? 0;
}

/// Isi layar pilih: daftar mill dan pilihan shift.
/// Shift kerja yang bisa dipilih. Tetap 1, 2, 3 dan tidak diambil dari
/// server, supaya dropdown shift tidak pernah kosong.
const List<String> kRwShifts = ['1', '2', '3'];

class RwOption {
  final List<Mill> mills;

  const RwOption({required this.mills});

  factory RwOption.fromMap(Map<String, dynamic> map) {
    final mills = (map['mills'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Mill.fromMap(Map<String, dynamic>.from(e)))
        .map((m) => m.copyWith(millID: m.millID.trim(), millName: m.millName.trim()))
        .toList();

    return RwOption(mills: mills);
  }
}

class RwWarehouse {
  final String millId;
  final String whId;
  final String descr;

  const RwWarehouse({
    required this.millId,
    required this.whId,
    required this.descr,
  });

  /// Teks yang dipakai di dropdown dan pesan.
  String get label => descr.isEmpty ? whId : '$descr ($whId)';

  factory RwWarehouse.fromMap(Map<String, dynamic> map) {
    return RwWarehouse(
      millId: _str(map['mill_id']),
      whId: _str(map['wh_id']),
      descr: _str(map['descr']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RwWarehouse && other.millId == millId && other.whId == whId;

  @override
  int get hashCode => Object.hash(millId, whId);
}

/// Pilihan user di layar pertama. Dibawa ke layar scan dan dipakai di setiap
/// request, termasuk untuk validasi tujuan kiriman.
class RwSelection {
  final Mill mill;
  final RwWarehouse warehouse;
  final String shift;

  const RwSelection({
    required this.mill,
    required this.warehouse,
    required this.shift,
  });
}

/// Header kiriman TI (wh_trans_hdr). mill_id = pengirim,
/// office_id_dest + wh_dest = tujuan.
class RwTransfer {
  final String millId;
  final String millName;
  final String officeIdDest;
  final String millNameDest;
  final String trId;
  final DateTime? dtTrans;
  final String whId;
  final String binId;
  final String whDest;
  final String binDest;
  final String descr;
  final String descrDest;
  final String remark;
  final String userId;
  final String shift;
  final int totalItem;
  final double totalQty;

  const RwTransfer({
    required this.millId,
    required this.millName,
    required this.officeIdDest,
    required this.millNameDest,
    required this.trId,
    required this.dtTrans,
    required this.whId,
    required this.binId,
    required this.whDest,
    required this.binDest,
    required this.descr,
    required this.descrDest,
    required this.remark,
    required this.userId,
    required this.shift,
    required this.totalItem,
    required this.totalQty,
  });

  String get fromMill => millName.isEmpty ? millId : millName;
  String get fromLabel => descr.isEmpty ? whId : '$descr ($whId)';
  String get toLabel => descrDest.isEmpty ? whDest : '$descrDest ($whDest)';

  factory RwTransfer.fromMap(Map<String, dynamic> map) {
    return RwTransfer(
      millId: _str(map['mill_id']),
      millName: _str(map['mill_name']),
      officeIdDest: _str(map['office_id_dest']),
      millNameDest: _str(map['mill_name_dest']),
      trId: _str(map['tr_id']),
      dtTrans: DateTime.tryParse(_str(map['dt_trans'])),
      whId: _str(map['wh_id']),
      binId: _str(map['bin_id']),
      whDest: _str(map['wh_dest']),
      binDest: _str(map['bin_dest']),
      descr: _str(map['descr']),
      descrDest: _str(map['descr_dest']),
      remark: _str(map['remark']),
      userId: _str(map['user_id']),
      shift: _str(map['shift']),
      totalItem: _num(map['total_item']).toInt(),
      totalQty: _num(map['total_qty']),
    );
  }
}

/// Baris kiriman TI yang akan diterima (wh_trans_dtl).
class RwTransferDetail {
  final int trSeq;
  final String prodCode;
  final String namaBarang;
  final String namaWarna;
  final String addId;
  final String torId;
  final String batchId;
  final double panjang;
  final double qty;
  final double wgt;

  const RwTransferDetail({
    required this.trSeq,
    required this.prodCode,
    required this.namaBarang,
    required this.namaWarna,
    required this.addId,
    required this.torId,
    required this.batchId,
    required this.panjang,
    required this.qty,
    required this.wgt,
  });

  factory RwTransferDetail.fromMap(Map<String, dynamic> map) {
    return RwTransferDetail(
      trSeq: _num(map['tr_seq']).toInt(),
      prodCode: _str(map['prod_code']),
      namaBarang: _str(map['nama_barang']),
      namaWarna: _str(map['nama_warna']),
      addId: _str(map['add_id']),
      torId: _str(map['tor_id']),
      batchId: _str(map['batch_id']),
      panjang: _num(map['panjang']),
      qty: _num(map['qty']),
      wgt: _num(map['wgt']),
    );
  }
}

/// Hasil lookup tr_id dari scan yang sudah lolos validasi tujuan.
class RwScanResult {
  final RwTransfer header;
  final List<RwTransferDetail> details;

  const RwScanResult({required this.header, required this.details});

  double get totalQty => details.fold(0, (sum, d) => sum + d.qty);
  double get totalWgt => details.fold(0, (sum, d) => sum + d.wgt);

  factory RwScanResult.fromMap(Map<String, dynamic> map) {
    final header = RwTransfer.fromMap(
      Map<String, dynamic>.from(map['header'] as Map? ?? {}),
    );
    final details = (map['details'] as List? ?? [])
        .whereType<Map>()
        .map((e) => RwTransferDetail.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return RwScanResult(header: header, details: details);
  }
}

/// Hasil submitRw: kiriman [trIdRef] sudah diterima sebagai TR [trId].
class RwReceived {
  final String trId;
  final String trIdRef;
  final int totalItem;
  final double totalQty;
  final String message;
  final DateTime receivedAt;

  const RwReceived({
    required this.trId,
    required this.trIdRef,
    required this.totalItem,
    required this.totalQty,
    required this.message,
    required this.receivedAt,
  });

  factory RwReceived.fromResponse(Map res) {
    final data = res['data'] is Map ? res['data'] as Map : const {};

    return RwReceived(
      trId: _str(data['tr_id']),
      trIdRef: _str(data['tr_id_ref']),
      totalItem: _num(data['total_item']).toInt(),
      totalQty: _num(data['total_qty']),
      message: _str(res['message']),
      receivedAt: DateTime.now(),
    );
  }
}
