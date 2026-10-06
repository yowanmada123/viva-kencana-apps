abstract class CoilScanEvent {}

/// Cari coil dari isi barcode hasil scan. [barcode] dikirim apa adanya -
/// server yang mengurai kalau isinya JSON.
class LookupCoilByBarcode extends CoilScanEvent {
  final String barcode;

  LookupCoilByBarcode(this.barcode);
}

/// Kembalikan ke keadaan awal setelah hasil scan diproses layar, supaya scan
/// berikutnya tidak terhalang state lama.
class ResetCoilScan extends CoilScanEvent {}
