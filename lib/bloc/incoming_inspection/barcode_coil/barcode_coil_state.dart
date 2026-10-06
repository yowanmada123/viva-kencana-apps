import '../../../models/incoming_inspection/barcode_coil.dart';

abstract class BarcodeCoilState {}

class BarcodeCoilInitial extends BarcodeCoilState {}

class BarcodeCoilLoading extends BarcodeCoilState {}

/// [all] menyimpan seluruh hasil dari server, [data] adalah hasil setelah
/// pencarian lokal diterapkan. Keduanya dipisah supaya pencarian di sisi
/// aplikasi tidak perlu hit API lagi.
class BarcodeCoilLoaded extends BarcodeCoilState {
  final List<BarcodeCoil> all;
  final List<BarcodeCoil> data;
  final String keyword;

  BarcodeCoilLoaded({
    required this.all,
    required this.data,
    this.keyword = '',
  });

  /// Jumlah nomor inspeksi yang berbeda. Satu inspeksi bisa mencakup banyak
  /// coil, sedangkan view mengembalikan satu baris per coil.
  int get inspectionCount =>
      all.map((e) => e.trxId).where((e) => e.isNotEmpty).toSet().length;

  /// Jumlah coil yang tidak terdaftar tidak bisa dihitung dari view ini,
  /// karena coil ber-stat 'G' memang tidak muncul di v_barcode_coil.
  int get coilCount => all.length;
}

class BarcodeCoilError extends BarcodeCoilState {
  final String message;

  BarcodeCoilError({required this.message});
}
