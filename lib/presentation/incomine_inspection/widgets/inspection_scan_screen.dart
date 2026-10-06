import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

/// Mode pemindaian. Label coil di lapangan memakai dua jenis kode yang bentuk
/// fisiknya jauh berbeda, jadi jendela bidiknya dibedakan:
///
///   qr      - kode 2D (QR pada label Krakatau Steel, NAI, Gunung Steel),
///             jendela bidik kotak
///   barcode - kode 1D (Code 39 pada label POSCO), jendela bidik memanjang
///             karena garisnya lebar dan pendek
///
/// Membatasi format juga membantu akurasi: pemindai tidak perlu mencoba semua
/// simbologi sekaligus.
enum ScanMode { qr, barcode }

/// Hasil satu kali pemindaian.
class ScanOutcome {
  /// Teks mentah persis seperti dibaca pemindai.
  final String code;

  /// Simbologi yang terbaca, mis. "code39" atau "qrcode". Ditampilkan di
  /// dialog pilihan dan berguna saat menelusuri scan yang bermasalah.
  final String format;

  const ScanOutcome({required this.code, required this.format});
}

/// Layar pemindai khusus Incoming Inspection.
///
/// Sengaja terpisah dari QrCodeScanScreen milik menu Confirm Loading: layar ini
/// perlu membatasi format dan mengembalikan jenis simbologi, sementara layar
/// lama hanya mengembalikan teks dan dipakai fitur lain yang tidak boleh ikut
/// berubah.
class InspectionScanScreen extends StatefulWidget {
  final ScanMode mode;

  const InspectionScanScreen({super.key, required this.mode});

  @override
  State<InspectionScanScreen> createState() => _InspectionScanScreenState();
}

class _InspectionScanScreenState extends State<InspectionScanScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'InspectionQR');

  QRViewController? _controller;
  bool _handled = false;
  bool _flashOn = false;

  String get _title =>
      widget.mode == ScanMode.qr ? 'Scan QR Code' : 'Scan Barcode';

  String get _hint =>
      widget.mode == ScanMode.qr
          ? 'Arahkan kamera ke QR code pada label coil.\n'
              'Pastikan seluruh kode masuk ke dalam kotak.'
          : 'Pastikan SELURUH barcode masuk ke dalam kotak, '
              'termasuk sisi kiri dan kanannya.\n'
              'Kalau tidak muat, mundurkan kamera sedikit.';

  @override
  void reassemble() {
    super.reassemble();

    /// Kamera perlu dibangunkan ulang setelah hot reload, perilakunya berbeda
    /// antara Android dan iOS.
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  /// QRViewController membuang dirinya sendiri saat QRView lepas dari tree,
  /// jadi tidak perlu dispose manual di sini.

  void _onViewCreated(QRViewController controller) {
    _controller = controller;

    controller.scannedDataStream.listen((scanData) {
      /// Stream bisa memuntahkan beberapa pembacaan beruntun untuk satu kode,
      /// jadi hanya yang pertama yang dipakai.
      if (_handled) return;
      _handled = true;

      final code = scanData.code?.trim() ?? '';
      if (code.isEmpty) {
        _handled = false;
        return;
      }

      controller.pauseCamera();

      if (!mounted) return;
      Navigator.pop(
        context,
        ScanOutcome(code: code, format: scanData.format.name),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isQr = widget.mode == ScanMode.qr;
    final screenWidth = MediaQuery.of(context).size.width;

    /// PENTING: ukuran kotak ini bukan sekadar hiasan. Nilainya dikirim ke
    /// sisi native sebagai framingRect, dan ZXing HANYA men-decode area di
    /// dalamnya. Barcode 1D yang lebih lebar dari kotak tidak akan pernah
    /// terbaca, walau terlihat jelas di layar.
    ///
    /// Karena itu mode barcode memakai kotak selebar hampir seluruh layar -
    /// barcode garis jauh lebih lebar daripada QR, dan ZXing butuh seluruh
    /// batang plus margin kosong di kiri-kanannya.
    final cutOutWidth = isQr ? screenWidth * 0.72 : screenWidth * 0.94;
    final cutOutHeight = isQr ? screenWidth * 0.72 : 160.w;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.w,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Senter',
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await _controller?.toggleFlash();
              final status = await _controller?.getFlashStatus();
              if (!mounted) return;
              setState(() => _flashOn = status ?? false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onViewCreated,

              /// Format sengaja TIDAK dibatasi. Mode hanya menentukan bentuk
              /// kotak bidik, bukan simbologi yang diterima - supaya salah
              /// pilih tombol tidak membuat scan gagal diam-diam.
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 8,
                borderLength: 24,
                borderWidth: 6,
                cutOutWidth: cutOutWidth,
                cutOutHeight: cutOutHeight,
              ),
              onPermissionSet: (controller, granted) {
                if (granted) return;
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Izin kamera belum diberikan'),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 16.w),
            color: Colors.black,
            child: SafeArea(
              top: false,
              child: Text(
                _hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
