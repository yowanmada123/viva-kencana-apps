import 'barcode_coil.dart';

/// Hasil `POST api/getCoilByBarcode` setelah scan barcode.
///
/// Backend TIDAK menolak coil yang tidak terdaftar: coil asing tetap boleh
/// masuk daftar item dan nanti tersimpan dengan stat 'G'. Jadi aplikasi harus
/// membaca [found] / [stat], bukan mengandalkan kode HTTP.
///
/// Satu-satunya kondisi yang benar-benar ditolak adalah coil yang sudah pernah
/// diinspeksi - itu datang sebagai error (HTTP 409) lewat jalur Left.
class CoilScanResult {
  /// true kalau coil_id ada di v_barcode_coil.
  final bool found;

  /// 'O' bila ditemukan, 'G' bila tidak. Nilai inilah yang nanti masuk ke
  /// inspection_dtl.stat - server yang menentukan, aplikasi hanya meneruskan.
  final String stat;

  /// coil_id hasil pembacaan barcode, sudah dibersihkan server (barcode bisa
  /// berisi JSON, server yang mengurai).
  final String coilId;

  /// Data lengkap dari view. null kalau coil tidak terdaftar.
  final BarcodeCoil? coil;

  CoilScanResult({
    required this.found,
    required this.stat,
    required this.coilId,
    required this.coil,
  });

  factory CoilScanResult.fromMap(Map<String, dynamic> map) {
    final rawCoil = map['coil'];

    return CoilScanResult(
      found: map['found'] == true,
      stat: map['stat']?.toString().trim().toUpperCase() ?? 'G',
      coilId: map['coil_id']?.toString().trim() ?? '',
      coil:
          rawCoil is Map
              ? BarcodeCoil.fromMap(Map<String, dynamic>.from(rawCoil))
              : null,
    );
  }

  /// Keterangan singkat untuk ditampilkan di baris daftar item.
  String get description {
    final coil = this.coil;
    if (coil == null) return 'Tidak terdaftar di v_barcode_coil';

    return [
      if (coil.prodCode.isNotEmpty) coil.prodCode,
      if (coil.descr.isNotEmpty) coil.descr,
    ].join(' - ');
  }
}
