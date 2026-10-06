import '../../../models/incoming_inspection/coil_scan_result.dart';

abstract class CoilScanState {}

class CoilScanInitial extends CoilScanState {}

class CoilScanLoading extends CoilScanState {}

/// Coil boleh ditambahkan ke daftar item. Perhatikan result.found bisa false:
/// coil yang tidak terdaftar tetap sah, hanya bakal tersimpan dengan stat 'G'.
class CoilScanLoaded extends CoilScanState {
  final CoilScanResult result;

  CoilScanLoaded(this.result);
}

/// Coil ditolak - paling sering karena sudah pernah diinspeksi (HTTP 409).
/// Pesannya sudah menyebut nomor inspeksi sebelumnya.
class CoilScanError extends CoilScanState {
  final String message;

  CoilScanError({required this.message});
}
