abstract class BarcodeCoilEvent {}

/// Ambil riwayat inspeksi dari view v_barcode_coil.
///
/// [vendorId] boleh null -> filter hanya memakai rentang tanggal.
/// Saat layar pertama kali dibuka, rentang default seminggu terakhir.
class LoadBarcodeCoil extends BarcodeCoilEvent {
  final String? vendorId;
  final DateTime startDate;
  final DateTime endDate;

  LoadBarcodeCoil({
    this.vendorId,
    required this.startDate,
    required this.endDate,
  });
}

/// Pencarian lokal di dalam daftar yang sudah terambil (coil id, no SJ, no
/// kendaraan, prod code, deskripsi, PL, container). Tidak hit API.
class FilterBarcodeCoil extends BarcodeCoilEvent {
  final String keyword;

  FilterBarcodeCoil(this.keyword);
}
