import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../bloc/receive_warehouse/rw_receive/rw_receive_bloc.dart';
import '../../../data/repository/receive_warehouse_repository.dart';
import '../../../models/receive_warehouse/receive_warehouse.dart';

final _qtyFormat = NumberFormat('#,##0.##', 'id_ID');
final _timeFormat = DateFormat('HH:mm:ss', 'id_ID');

/// Langkah 2 Receive Warehouse: kamera langsung aktif untuk scan barcode
/// kiriman (label CODE128 berisi tr_id dari web, QR juga bisa terbaca).
///
/// Bagian atas selalu menampilkan posisi user (mill, warehouse, shift).
/// Setiap scan dicek server: kalau tujuan kiriman bukan posisi ini, muncul
/// pesan "Item ini tidak untuk diterima di ...". Kalau cocok, muncul rincian
/// barang dengan tombol Terima / Batal. Kiriman yang berhasil diterima
/// dicatat di riwayat sesi di bagian bawah.
class ReceiveWarehouseScanScreen extends StatelessWidget {
  final RwSelection selection;

  const ReceiveWarehouseScanScreen({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => RwReceiveBloc(
            repository: context.read<ReceiveWarehouseRepository>(),
            selection: selection,
          ),
      child: _ScanView(selection: selection),
    );
  }
}

class _ScanView extends StatefulWidget {
  final RwSelection selection;

  const _ScanView({required this.selection});

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'ReceiveWarehouseQR');

  QRViewController? _controller;
  bool _flashOn = false;

  /// true selama satu kode sedang diproses (lookup, konfirmasi, submit).
  /// Pembacaan lain diabaikan sampai selesai.
  bool _busy = false;

  /// Kamera akan langsung membaca label yang sama lagi begitu dilanjutkan,
  /// jadi kode terakhir diabaikan sebentar setelah kamera aktif kembali.
  String? _lastCode;
  DateTime _resumedAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _sameCodeCooldown = Duration(seconds: 4);

  /// Kiriman yang berhasil diterima selama layar ini terbuka, terbaru di atas.
  final List<RwReceived> _history = [];

  @override
  void reassemble() {
    super.reassemble();

    /// Kamera perlu dibangunkan ulang setelah hot reload.
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  // ---------------------------------------------------------------------------
  // Scan
  // ---------------------------------------------------------------------------

  void _onViewCreated(QRViewController controller) {
    _controller = controller;

    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code?.trim() ?? '';
      if (code.isEmpty) return;
      _handleCode(code);
    });
  }

  void _handleCode(String code) {
    if (_busy || !mounted) return;

    final sinceResume = DateTime.now().difference(_resumedAt);
    if (code == _lastCode && sinceResume < _sameCodeCooldown) return;

    _busy = true;
    _lastCode = code;
    _controller?.pauseCamera();
    HapticFeedback.mediumImpact();

    context.read<RwReceiveBloc>().add(RwScanned(code));
  }

  /// Selesai memproses satu kode: kamera siap untuk scan berikutnya.
  void _resume() {
    if (!mounted) return;
    _busy = false;
    _resumedAt = DateTime.now();
    _controller?.resumeCamera();
  }

  Future<void> _manualInput() async {
    final textController = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Input tr_id manual'),
            content: TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Contoh: ST251109001',
                border: OutlineInputBorder(),
              ),
              onSubmitted:
                  (value) => Navigator.pop(dialogContext, value.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(
                      dialogContext,
                      textController.text.trim(),
                    ),
                child: const Text('Cari'),
              ),
            ],
          ),
    );

    if (code == null || code.isEmpty) return;

    /// Input manual selalu diproses, walau sama dengan kode terakhir.
    _lastCode = null;
    _handleCode(code);
  }

  // ---------------------------------------------------------------------------
  // Hasil dari bloc
  // ---------------------------------------------------------------------------

  void _onReceiveState(BuildContext context, RwReceiveState state) {
    final navigator = Navigator.of(context);

    /// Dialog loading dan sheet konfirmasi ditutup dulu sebelum menampilkan
    /// hasil berikutnya.
    void closeOverlays() {
      navigator.popUntil((route) => route is! PopupRoute);
    }

    if (state is RwLookupLoading) {
      _showLoading('Mencari kiriman ${state.trId}...');
    } else if (state is RwLookupFailure) {
      closeOverlays();
      _showError('Tidak bisa diterima', state.message);
    } else if (state is RwLookupSuccess) {
      closeOverlays();
      _showConfirmSheet(state.scan);
    } else if (state is RwSubmitLoading) {
      closeOverlays();
      _showLoading('Menerima kiriman ${state.scan.header.trId}...');
    } else if (state is RwSubmitFailure) {
      closeOverlays();
      _showError('Gagal menerima', state.message);
    } else if (state is RwSubmitSuccess) {
      closeOverlays();
      _onReceived(state.scan, state.received);
    } else if (state is RwReceiveIdle) {
      /// Tombol Batal: kiriman tetap belum diterima, lanjut scan.
      _resume();
    }
  }

  void _onReceived(RwScanResult scan, RwReceived received) {
    final trIdRef =
        received.trIdRef.isEmpty ? scan.header.trId : received.trIdRef;

    setState(() => _history.insert(0, received));
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Kiriman $trIdRef telah diterima'
                  '${received.trId.isEmpty ? '' : ' (${received.trId})'}',
                ),
              ),
            ],
          ),
        ),
      );

    _resume();
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(width: 16.w),
                  Expanded(child: Text(message)),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showError(String title, String message) async {
    HapticFeedback.vibrate();

    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            icon: Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 40.w,
            ),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK, scan lagi'),
              ),
            ],
          ),
    );

    _resume();
  }

  void _showConfirmSheet(RwScanResult scan) {
    final bloc = context.read<RwReceiveBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
      ),
      builder:
          (sheetContext) => PopScope(
            /// Tombol back di sheet sama dengan Batal.
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              Navigator.pop(sheetContext);
              bloc.add(RwDismiss());
            },
            child: _ConfirmSheet(
              scan: scan,
              onCancel: () {
                Navigator.pop(sheetContext);
                bloc.add(RwDismiss());
              },
              onConfirm: () => bloc.add(RwConfirm(scan)),
            ),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tampilan
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    /// Kotak bidik memanjang karena label kiriman memakai barcode CODE128.
    /// ZXing hanya men-decode area di dalam kotak ini, jadi lebarnya dibuat
    /// hampir selebar layar.
    final cutOutWidth = screenWidth * 0.9;
    final cutOutHeight = 150.w;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Receive Warehouse',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: 'Input manual',
            icon: const Icon(Icons.keyboard_alt_outlined),
            onPressed: _manualInput,
          ),
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
      body: BlocListener<RwReceiveBloc, RwReceiveState>(
        listener: _onReceiveState,
        child: Column(
          children: [
            _LocationBanner(selection: widget.selection),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  QRView(
                    key: _qrKey,
                    onQRViewCreated: _onViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.white,
                      borderRadius: 8,
                      borderLength: 24,
                      borderWidth: 6,
                      cutOutWidth: cutOutWidth,
                      cutOutHeight: cutOutHeight,
                    ),
                    onPermissionSet: (controller, granted) {
                      if (granted || !mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Izin kamera belum diberikan'),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 12.w,
                    child: Text(
                      'Arahkan kamera ke barcode pada label kiriman.\n'
                      'Pastikan seluruh barcode masuk ke dalam kotak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        height: 1.4,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 3, child: _HistoryPanel(history: _history)),
          ],
        ),
      ),
    );
  }
}

/// Posisi user saat ini. Selalu tampil supaya jelas barang diterima di mana.
class _LocationBanner extends StatelessWidget {
  final RwSelection selection;

  const _LocationBanner({required this.selection});

  @override
  Widget build(BuildContext context) {
    final mill =
        selection.mill.millName.isEmpty
            ? selection.mill.millID
            : selection.mill.millName;
    final warehouse =
        selection.warehouse.descr.isEmpty
            ? selection.warehouse.whId
            : selection.warehouse.descr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 10.w),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menerima di',
            style: TextStyle(fontSize: 11.sp, color: Colors.black54),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 4.w,
            children: [
              _chip(Icons.factory_outlined, 'Mill', mill),
              _chip(Icons.warehouse_outlined, 'Warehouse', warehouse),
              _chip(Icons.schedule, 'Shift', selection.shift),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: Colors.black54),
        SizedBox(width: 4.w),
        Text.rich(
          TextSpan(
            text: '$label: ',
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kiriman yang sudah diterima selama layar ini terbuka.
class _HistoryPanel extends StatelessWidget {
  final List<RwReceived> history;

  const _HistoryPanel({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 6.w),
            child: Text(
              'Diterima sesi ini (${history.length})',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                history.isEmpty
                    ? Center(
                      child: Text(
                        'Belum ada kiriman yang diterima.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black45,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.w),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (_, i) {
                        final item = history[i];
                        return Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 20.w,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.trIdRef,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${item.trId.isEmpty ? '' : '${item.trId} · '}'
                                    '${item.totalItem} item · '
                                    '${_qtyFormat.format(item.totalQty)} pcs',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _timeFormat.format(item.receivedAt),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final RwScanResult scan;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.scan,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final header = scan.header;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.green.shade600),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Terima ${header.trId}?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Dari ${header.fromMill} · ${header.fromLabel}',
                style: TextStyle(fontSize: 12.sp),
              ),
              Text(
                'Ke ${header.toLabel}',
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                '${scan.details.length} item · '
                '${_qtyFormat.format(scan.totalQty)} pcs · '
                '${_qtyFormat.format(scan.totalWgt)} kg',
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
              if (header.remark.isNotEmpty)
                Text(
                  header.remark,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              const Divider(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: scan.details.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) => _DetailRow(item: scan.details[i]),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(44.h),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(44.h),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Terima'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final RwTransferDetail item;

  const _DetailRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final spec = [
      if (item.panjang > 0) 'P ${_qtyFormat.format(item.panjang)} m',
      if (item.namaWarna.isNotEmpty) item.namaWarna,
      if (item.batchId.isNotEmpty) 'Batch ${item.batchId}',
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.namaBarang.isEmpty ? item.prodCode : item.namaBarang,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              if (spec.isNotEmpty)
                Text(
                  spec,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '${_qtyFormat.format(item.qty)} pcs',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
