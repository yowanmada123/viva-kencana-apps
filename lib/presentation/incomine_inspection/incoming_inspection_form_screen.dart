import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../bloc/incoming_inspection/coil_scan/coil_scan_bloc.dart';
import '../../bloc/incoming_inspection/coil_scan/coil_scan_event.dart';
import '../../bloc/incoming_inspection/coil_scan/coil_scan_state.dart';
import '../../bloc/incoming_inspection/inspection_option/inspection_option_bloc.dart';
import '../../bloc/incoming_inspection/inspection_option/inspection_option_event.dart';
import '../../bloc/incoming_inspection/inspection_option/inspection_option_state.dart';
import '../../bloc/incoming_inspection/inspection_submit/inspection_submit_bloc.dart';
import '../../bloc/incoming_inspection/inspection_submit/inspection_submit_event.dart';
import '../../bloc/incoming_inspection/inspection_submit/inspection_submit_state.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_key.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_manager.dart';
import '../../models/incoming_inspection/inspection_form.dart';
import '../../models/incoming_inspection/inspection_option.dart';
import '../../utils/barcode_candidates.dart';
import '../../utils/number_input.dart';
import '../widgets/base_dropdown_button.dart';
import '../widgets/base_pop_up.dart';
import '../widgets/base_primary_button.dart';
import 'widgets/inspection_scan_screen.dart';
import 'widgets/scan_candidate_dialog.dart';

/// Form pembuatan data inspeksi: satu inspection_hdr + banyak inspection_dtl.
///
/// Alur sesuai kebutuhan lapangan:
///   1. Isi header. Semua dropdown (crew section ENT, shift, cuaca, kondisi
///      atap, kondisi terpal, storage) datang dari server lewat
///      getInspectionOption, jadi tidak ada kode yang di-hardcode di app.
///      Memilih shift otomatis mengisi jam mulai/selesai dari descr-nya,
///      tetapi jamnya tetap bisa diubah manual.
///   2. Tambah item dengan scan barcode. Tiap hasil scan diperiksa ke
///      v_barcode_coil. Coil yang TIDAK terdaftar tetap boleh masuk dan nanti
///      tersimpan dengan stat 'G'; yang sudah pernah diinspeksi ditolak server.
///   3. Isi Kondisi CRC (Y/N), Area, dan Keterangan per item.
///   4. Simpan. Nomor inspeksi (IN + YYMM + urut) dibuat server.
///
/// Layar menutup diri dengan `Navigator.pop(context, true)` setelah simpan
/// berhasil, supaya layar list tahu harus memuat ulang data.
class IncomingInspectionFormScreen extends StatefulWidget {
  const IncomingInspectionFormScreen({super.key});

  @override
  State<IncomingInspectionFormScreen> createState() =>
      _IncomingInspectionFormScreenState();
}

class _IncomingInspectionFormScreenState
    extends State<IncomingInspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- inspection_hdr ---
  final TextEditingController _noSjController = TextEditingController();
  final TextEditingController _noKendaraanController = TextEditingController();

  DateTime _dtTrx = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _crewId;
  String? _shiftNum;
  String? _cuaca;
  String? _tAtap;
  String? _tKondisi;
  String? _storage;

  // --- inspection_dtl ---
  final List<InspectionDetailForm> _details = [];
  final Map<String, TextEditingController> _areaControllers = {};
  final Map<String, TextEditingController> _remarkControllers = {};
  final Map<String, TextEditingController> _wgtLabelControllers = {};

  String _userId = '';

  @override
  void initState() {
    super.initState();
    log(
      'Access to presentation/incomine_inspection/incoming_inspection_form_screen.dart',
    );
    _loadUserData();
    context.read<InspectionOptionBloc>().add(LoadInspectionOption());
  }

  @override
  void dispose() {
    _noSjController.dispose();
    _noKendaraanController.dispose();
    for (final controller in _areaControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarkControllers.values) {
      controller.dispose();
    }
    for (final controller in _wgtLabelControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// user_id diambil dari data login yang tersimpan di SharedPreferences,
  /// memakai field yang sama dengan Stock Opname (user_id2).
  Future<void> _loadUserData() async {
    final authSharedPref = SharedPreferencesManager(
      key: SharedPreferencesKey.authKey,
    );
    final dataString = await authSharedPref.read();

    if (dataString == null) return;

    final Map<String, dynamic> data = json.decode(dataString);
    final user = data['user'];

    if (!mounted) return;
    setState(() {
      _userId = (user['user_id2'] ?? user['user_id'] ?? '').toString().trim();
    });
  }

  /// mill_id diambil dari coil terdaftar yang pertama. Kalau semua item
  /// ternyata coil asing, nilainya kosong dan server akan menurunkannya dari
  /// crew yang dipilih.
  String get _millId {
    for (final detail in _details) {
      final millId = detail.coil?.millId ?? '';
      if (millId.isNotEmpty) return millId;
    }
    return '';
  }

  DateTime _combine(TimeOfDay time) {
    return DateTime(
      _dtTrx.year,
      _dtTrx.month,
      _dtTrx.day,
      time.hour,
      time.minute,
    );
  }

  // ===========================================================================
  // AKSI HEADER
  // ===========================================================================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dtTrx,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Transaksi',
    );

    if (picked != null) setState(() => _dtTrx = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isStart ? _startTime : _endTime) ??
          const TimeOfDay(hour: 8, minute: 0),
      helpText: isStart ? 'Pilih Jam Mulai' : 'Pilih Jam Selesai',
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  /// Saat shift dipilih, jam loading diisi otomatis dari descr shift
  /// (mis. "07:00 - 15:00"). User tetap bisa mengubahnya.
  void _onShiftChanged(String? value, List<ShiftOption> shifts) {
    setState(() {
      _shiftNum = value;

      final shift = shifts.firstWhere(
        (e) => e.shiftNum == value,
        orElse:
            () => ShiftOption(millId: '', shiftNum: value ?? '', descr: ''),
      );

      final start = shift.startTime;
      final end = shift.endTime;

      if (start != null) {
        _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
      }
      if (end != null) {
        _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
      }
    });
  }

  // ===========================================================================
  // AKSI ITEM
  // ===========================================================================

  /// Buka kamera, lalu serahkan hasilnya ke CoilScanBloc untuk diperiksa ke
  /// v_barcode_coil. Isi barcode bisa berupa JSON - server yang mengurai.
  Future<void> _scanCoil(ScanMode mode) async {
    final outcome = await Navigator.push<ScanOutcome>(
      context,
      MaterialPageRoute(builder: (_) => InspectionScanScreen(mode: mode)),
    );

    if (!mounted || outcome == null) return;

    /// Isi barcode dipecah jadi daftar kandidat: teks polos jadi satu pilihan,
    /// JSON jadi satu pilihan per key, URL jadi satu pilihan per segmen.
    /// Petugas yang memilih mana No CRC-nya - aplikasi tidak menebak, karena
    /// format label berbeda tiap pabrikan.
    final payload = parseScanPayload(outcome.code);

    if (payload.isEmpty) {
      _snack('Hasil scan kosong, coba ulangi');
      return;
    }

    final picked = await ScanCandidateDialog.show(
      context,
      payload: payload,
      format: outcome.format,
    );

    if (!mounted || picked == null || picked.trim().isEmpty) return;

    /// Baru setelah dipilih, nilainya dicek ke v_barcode_coil.
    context.read<CoilScanBloc>().add(LookupCoilByBarcode(picked));
  }

  /// Jalur cadangan kalau barcode rusak atau tidak terbaca kamera.
  Future<void> _inputCoilManual() async {
    /// Controller-nya dimiliki _ManualCoilDialog, bukan method ini. Kalau
    /// dibuat di sini lalu di-dispose setelah await, TextField-nya masih
    /// dirender selama animasi dialog menutup dan memakai controller yang
    /// sudah mati.
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualCoilDialog(),
    );

    if (!mounted || code == null || code.isEmpty) return;

    context.read<CoilScanBloc>().add(LookupCoilByBarcode(code));
  }

  /// Masukkan hasil scan ke daftar item. Duplikat dicek di sini memakai
  /// coil_id yang sudah dibersihkan server, bukan isi barcode mentah.
  void _addScanResult(CoilScanState state) {
    if (state is! CoilScanLoaded) return;

    final result = state.result;
    context.read<CoilScanBloc>().add(ResetCoilScan());

    if (result.coilId.isEmpty) {
      _snack('Barcode tidak berisi No CRC yang bisa dibaca');
      return;
    }

    if (_details.any((e) => e.coilId == result.coilId)) {
      _snack('${result.coilId} sudah ada di daftar item');
      return;
    }

    setState(() {
      _details.add(
        InspectionDetailForm(
          coilId: result.coilId,
          stat: result.stat,
          coil: result.coil,
        ),
      );
      _areaControllers[result.coilId] = TextEditingController();
      _remarkControllers[result.coilId] = TextEditingController();

      /// Berat label diisi dulu dengan wgt_net dari view sebagai acuan.
      /// Coil yang tidak terdaftar tidak punya acuan, jadi dibiarkan kosong.
      _wgtLabelControllers[result.coilId] = TextEditingController(
        text: result.coil == null ? '' : formatWeight(result.coil!.wgtNet),
      );
    });

    if (result.found) {
      _snack('${result.coilId} ditambahkan');
    } else {
      _snack(
        '${result.coilId} tidak terdaftar di v_barcode_coil, '
        'akan disimpan dengan status G',
        color: Colors.orange.shade800,
      );
    }
  }

  void _removeDetail(int index) {
    final coilId = _details[index].coilId;

    /// Lepaskan dari map dulu supaya rebuild berikutnya tidak memakainya lagi.
    final area = _areaControllers.remove(coilId);
    final remark = _remarkControllers.remove(coilId);
    final wgtLabel = _wgtLabelControllers.remove(coilId);

    setState(() => _details.removeAt(index));

    /// Baru dibuang setelah frame ini selesai, saat TextField-nya benar-benar
    /// sudah lepas dari tree. Kalau di-dispose langsung, field yang sedang
    /// fokus masih sempat menyentuh controller yang sudah mati.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      area?.dispose();
      remark?.dispose();
      wgtLabel?.dispose();
    });
  }

  /// Isi ketiga penilaian Kondisi CRC sekaligus untuk semua item - dalam satu
  /// truk umumnya kondisinya seragam.
  void _applyKondisiToAll(String value) {
    setState(() {
      for (var i = 0; i < _details.length; i++) {
        _details[i] = _details[i].copyWith(
          od: value,
          strapping: value,
          surface: value,
        );
      }
    });
  }

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: color, content: Text(message)),
    );
  }

  // ===========================================================================
  // VALIDASI & SIMPAN
  // ===========================================================================

  String? _validate() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return 'Lengkapi dulu data header yang wajib diisi';
    }
    if (_crewId == null) return 'Crew belum dipilih';
    if (_shiftNum == null) return 'Shift belum dipilih';
    if (_cuaca == null) return 'Cuaca belum dipilih';
    if (_tAtap == null) return 'Kondisi atap belum dipilih';
    if (_tKondisi == null) return 'Kondisi terpal belum dipilih';
    if (_storage == null) return 'Storage belum dipilih';

    if (_startTime == null) return 'Jam mulai belum diisi';
    if (_endTime == null) return 'Jam selesai belum diisi';

    if (!_combine(_endTime!).isAfter(_combine(_startTime!))) {
      return 'Jam selesai harus lebih besar dari jam mulai';
    }

    if (_details.isEmpty) return 'Scan minimal satu coil';

    final incomplete = _details.where((e) => !e.isComplete).length;
    if (incomplete > 0) {
      return 'Kondisi CRC belum diisi pada $incomplete item';
    }

    if (_userId.isEmpty) return 'User ID tidak ditemukan, silakan login ulang';

    return null;
  }

  void _submit() {
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => BasePopUpDialog(
            question:
                'Simpan inspeksi untuk ${_details.length} coil dengan surat '
                'jalan ${_noSjController.text.trim()}?',
            yesText: 'Simpan',
            noText: 'Batal',
            onNoPressed: () {},
            onYesPressed: () {
              /// Area dan keterangan dibaca dari controller saat submit, bukan
              /// saat diketik, supaya tidak memicu rebuild tiap karakter.
              final details =
                  _details.map((detail) {
                    return detail.copyWith(
                      wgtLabel: parseWeight(
                        _wgtLabelControllers[detail.coilId]?.text ?? '',
                      ),
                      area: _areaControllers[detail.coilId]?.text.trim() ?? '',
                      remark:
                          _remarkControllers[detail.coilId]?.text.trim() ?? '',
                    );
                  }).toList();

              context.read<InspectionSubmitBloc>().add(
                SubmitInspection(
                  InspectionForm(
                    millId: _millId,
                    noSj: _noSjController.text.trim(),
                    noKendaraan: _noKendaraanController.text.trim(),
                    dtTrx: _dtTrx,
                    crewId: _crewId!,
                    shiftNum: _shiftNum!,
                    cuaca: _cuaca!,
                    tAtap: _tAtap!,
                    tKondisi: _tKondisi!,
                    startTime: _combine(_startTime!),
                    endTime: _combine(_endTime!),
                    storage: _storage!,
                    userId: _userId,
                    details: details,
                  ),
                ),
              );
            },
          ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        /// Hasil scan -> masukkan ke daftar item, atau tampilkan penolakan
        /// (paling sering: coil sudah pernah diinspeksi).
        BlocListener<CoilScanBloc, CoilScanState>(
          listener: (context, state) {
            if (state is CoilScanLoaded) {
              _addScanResult(state);
            } else if (state is CoilScanError) {
              context.read<CoilScanBloc>().add(ResetCoilScan());
              _snack(state.message, color: Colors.red.shade700);
            }
          },
        ),

        BlocListener<InspectionSubmitBloc, InspectionSubmitState>(
          listener: (context, state) {
            if (state is InspectionSubmitSuccess) {
              context.read<InspectionSubmitBloc>().add(
                ResetInspectionSubmit(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade700,
                  content: Text(
                    state.trxId.isEmpty
                        ? 'Data inspeksi berhasil disimpan'
                        : 'Inspeksi ${state.trxId} berhasil disimpan',
                  ),
                ),
              );
              Navigator.pop(context, true);
            }

            if (state is InspectionSubmitError) {
              context.read<InspectionSubmitBloc>().add(
                ResetInspectionSubmit(),
              );
              _snack(state.message, color: Colors.red.shade700);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Buat Inspeksi',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.w,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: SafeArea(
          child: BlocBuilder<InspectionOptionBloc, InspectionOptionState>(
            builder: (context, state) {
              if (state is InspectionOptionLoading ||
                  state is InspectionOptionInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is InspectionOptionError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48.w,
                        ),
                        SizedBox(height: 12.w),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.w),
                        BasePrimaryButton(
                          label: 'Coba Lagi',
                          icon: Icons.refresh,
                          onPressed:
                              () => context.read<InspectionOptionBloc>().add(
                                LoadInspectionOption(),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final option = (state as InspectionOptionLoaded).option;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(8.w),
                  children: [
                    _buildHeaderSection(option),
                    SizedBox(height: 8.w),
                    _buildItemSection(option),
                    SizedBox(height: 16.w),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<InspectionSubmitBloc, InspectionSubmitState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_details.length} item',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_details.where((e) => e.isComplete).length} sudah lengkap'
                        '${_details.any((e) => e.isUnregistered) ? '  •  ${_details.where((e) => e.isUnregistered).length} tidak terdaftar' : ''}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: BasePrimaryButton(
                    label: 'Simpan',
                    icon: Icons.save_outlined,
                    isLoading: state is InspectionSubmitLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HEADER ----------------------------------------------------------------

  Widget _buildHeaderSection(InspectionOption option) {
    return _Card(
      title: 'Data Header',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// No inspeksi dibuat server, jadi hanya diinformasikan.
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 16.w,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'No Inspeksi dibuat otomatis oleh server '
                    '(format IN + tahun + bulan + nomor urut)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.w),

          TextFormField(
            controller: _noSjController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 40,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            decoration: const InputDecoration(
              labelText: 'No Surat Jalan *',
              counterText: '',
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'No surat jalan wajib diisi'
                        : null,
          ),
          SizedBox(height: 8.w),

          TextFormField(
            controller: _noKendaraanController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 50,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            decoration: const InputDecoration(
              labelText: 'No Kendaraan *',
              counterText: '',
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'No kendaraan wajib diisi'
                        : null,
          ),
          SizedBox(height: 8.w),

          _TapField(
            label: 'Tanggal *',
            value: DateFormat('dd/MM/yyyy').format(_dtTrx),
            icon: Icons.calendar_today,
            onTap: _pickDate,
          ),
          SizedBox(height: 8.w),

          /// Crew: tampilkan crew_name, simpan crew_id.
          BaseDropdownButton(
            label: 'Crew *',
            items: {for (final c in option.crew) c.crewId: c.label},
            value: _crewId,
            onChanged: (value) => setState(() => _crewId = value),
          ),
          SizedBox(height: 8.w),

          /// Shift: tampilkan "1 (07:00 - 15:00)", simpan shift_num.
          BaseDropdownButton(
            label: 'Shift *',
            items: {for (final s in option.shift) s.shiftNum: s.label},
            value: _shiftNum,
            onChanged: (value) => _onShiftChanged(value, option.shift),
          ),
          SizedBox(height: 8.w),

          /// Waktu loading - terisi otomatis dari shift, tetap bisa diubah.
          Row(
            children: [
              Expanded(
                child: _TapField(
                  label: 'Jam Mulai *',
                  value: _startTime?.format(context) ?? '-',
                  icon: Icons.schedule,
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _TapField(
                  label: 'Jam Selesai *',
                  value: _endTime?.format(context) ?? '-',
                  icon: Icons.schedule,
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),

          BaseDropdownButton(
            label: 'Cuaca *',
            items: InspectionOption.asMap(option.cuaca),
            value: _cuaca,
            onChanged: (value) => setState(() => _cuaca = value),
          ),
          SizedBox(height: 8.w),

          Row(
            children: [
              Expanded(
                child: BaseDropdownButton(
                  label: 'Kondisi Atap *',
                  items: InspectionOption.asMap(option.tAtap),
                  value: _tAtap,
                  onChanged: (value) => setState(() => _tAtap = value),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: BaseDropdownButton(
                  label: 'Kondisi Terpal *',
                  items: InspectionOption.asMap(option.tKondisi),
                  value: _tKondisi,
                  onChanged: (value) => setState(() => _tKondisi = value),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),

          BaseDropdownButton(
            label: 'Storage *',
            items: InspectionOption.asMap(option.storage),
            value: _storage,
            onChanged: (value) => setState(() => _storage = value),
          ),

          if (_millId.isNotEmpty || _userId.isNotEmpty) ...[
            SizedBox(height: 10.w),
            Text(
              [
                if (_millId.isNotEmpty) 'Mill: $_millId',
                if (_userId.isNotEmpty) 'User: $_userId',
              ].join('  •  '),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- ITEM ------------------------------------------------------------------

  Widget _buildItemSection(InspectionOption option) {
    return _Card(
      title: 'Daftar Item',
      icon: Icons.checklist_rtl,
      trailing: BlocBuilder<CoilScanBloc, CoilScanState>(
        builder: (context, state) {
          if (state is CoilScanLoading) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Input manual',
                visualDensity: VisualDensity.compact,
                onPressed: _inputCoilManual,
                icon: Icon(Icons.keyboard_alt_outlined, size: 20.w),
              ),
              IconButton(
                tooltip: 'Scan barcode garis',
                visualDensity: VisualDensity.compact,
                onPressed: () => _scanCoil(ScanMode.barcode),
                icon: Icon(Icons.barcode_reader, size: 20.w),
              ),
              IconButton(
                tooltip: 'Scan QR code',
                visualDensity: VisualDensity.compact,
                onPressed: () => _scanCoil(ScanMode.qr),
                icon: Icon(Icons.qr_code_scanner, size: 20.w),
              ),
            ],
          );
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_details.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 36.w,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      'Belum ada item.\nTekan "Scan" untuk menambahkan coil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (_details.length > 1) ...[
              _buildApplyToAll(option),
              SizedBox(height: 8.w),
            ],
            ...List.generate(_details.length, (index) {
              return _DetailTile(
                key: ValueKey(_details[index].coilId),
                detail: _details[index],
                kondisiOptions: option.kondisiCrc,
                areaController: _areaControllers[_details[index].coilId]!,
                remarkController: _remarkControllers[_details[index].coilId]!,
                wgtLabelController:
                    _wgtLabelControllers[_details[index].coilId]!,
                onChanged:
                    (updated) => setState(() => _details[index] = updated),
                onRemove: () => _removeDetail(index),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildApplyToAll(InspectionOption option) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terapkan ke semua item',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          Text(
            'Mengisi OD, Strapping, dan Surface sekaligus',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.sp,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 6.w),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.w,
            children:
                option.kondisiCrc.map((item) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: Colors.blue.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    onPressed: () => _applyKondisiToAll(item.value),
                    child: Text(
                      'Semua ${item.label}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIALOG INPUT MANUAL
// =============================================================================

/// Jalur cadangan saat barcode rusak atau tidak terbaca kamera.
///
/// Dibuat sebagai StatefulWidget supaya controller-nya hidup dan mati bersama
/// dialog. Membuat controller di luar lalu men-dispose-nya setelah
/// `await showDialog(...)` tidak aman: Future-nya selesai begitu Navigator.pop
/// dipanggil, sementara isi dialog masih dirender sampai animasi tutup habis.
class _ManualCoilDialog extends StatefulWidget {
  const _ManualCoilDialog();

  @override
  State<_ManualCoilDialog> createState() => _ManualCoilDialogState();
}

class _ManualCoilDialogState extends State<_ManualCoilDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Input No CRC Manual',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 15.sp),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
        decoration: const InputDecoration(labelText: 'No CRC / Coil ID'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _submit, child: const Text('Cari')),
      ],
    );
  }
}

// =============================================================================
// SATU BARIS ITEM: No CRC, Area, Kondisi CRC, Keterangan
// =============================================================================

class _DetailTile extends StatelessWidget {
  final InspectionDetailForm detail;
  final List<OptionItem> kondisiOptions;
  final TextEditingController areaController;
  final TextEditingController remarkController;
  final TextEditingController wgtLabelController;
  final ValueChanged<InspectionDetailForm> onChanged;
  final VoidCallback onRemove;

  const _DetailTile({
    super.key,
    required this.detail,
    required this.kondisiOptions,
    required this.areaController,
    required this.remarkController,
    required this.wgtLabelController,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              detail.isComplete
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// No CRC + tombol hapus di pojok kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                detail.isComplete
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 18.w,
                color:
                    detail.isComplete
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.coilId,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      detail.productLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color:
                            detail.isUnregistered
                                ? Colors.orange.shade800
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus item ini',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline, size: 20.w, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),

          /// Penanda coil tidak terdaftar - tetap boleh disimpan (stat G)
          if (detail.isUnregistered)
            Container(
              margin: EdgeInsets.only(top: 4.w, bottom: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Tidak terdaftar di v_barcode_coil, akan disimpan status G',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  color: Colors.orange.shade900,
                ),
              ),
            ),

          SizedBox(height: 6.w),

          /// Kondisi CRC terdiri dari tiga penilaian Y/N, masing-masing punya
          /// kolomnya sendiri di inspection_dtl.
          Text(
            'Kondisi CRC *',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 2.w),

          _ConditionRow(
            label: 'OD',
            value: detail.od,
            options: kondisiOptions,
            primary: primary,
            onSelected: (value) => onChanged(detail.copyWith(od: value)),
          ),
          _ConditionRow(
            label: 'Strapping',
            value: detail.strapping,
            options: kondisiOptions,
            primary: primary,
            onSelected: (value) => onChanged(detail.copyWith(strapping: value)),
          ),
          _ConditionRow(
            label: 'Surface',
            value: detail.surface,
            options: kondisiOptions,
            primary: primary,
            onSelected: (value) => onChanged(detail.copyWith(surface: value)),
          ),

          SizedBox(height: 6.w),

          /// Berat menurut label fisik. Terisi otomatis dari wgt_net coil,
          /// tapi tetap bisa dikoreksi kalau angka di label berbeda.
          TextField(
            controller: wgtLabelController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ThousandsInputFormatter()],
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: 'Berat Label',
              suffixText: 'KG',
              isDense: true,
              helperText:
                  detail.coil == null
                      ? 'Coil tidak terdaftar, isi manual'
                      : 'Acuan wgt_net: ${formatWeight(detail.coil!.wgtNet)} KG',
              helperStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          SizedBox(height: 4.w),

          TextField(
            controller: areaController,
            maxLength: 10,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            decoration: const InputDecoration(
              labelText: 'Area',
              counterText: '',
              isDense: true,
            ),
          ),
          SizedBox(height: 4.w),
          TextField(
            controller: remarkController,
            maxLength: 150,
            maxLines: 2,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
            decoration: const InputDecoration(
              labelText: 'Keterangan',
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris penilaian Kondisi CRC: label di kiri, pilihan Y/N di kanan.
/// Dipakai tiga kali per item, untuk kolom od, strapping, dan surface.
class _ConditionRow extends StatelessWidget {
  final String label;
  final String value;
  final List<OptionItem> options;
  final Color primary;
  final ValueChanged<String> onSelected;

  const _ConditionRow({
    required this.label,
    required this.value,
    required this.options,
    required this.primary,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.w),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.w,
              children:
                  options.map((item) {
                    final selected = value == item.value;

                    return InkWell(
                      onTap: () => onSelected(item.value),
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.w,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? primary : Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: selected ? primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// KARTU PEMBUNGKUS SECTION
// =============================================================================

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _Card({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.w, 6.w, 4.w),
            child: Row(
              children: [
                Icon(icon, size: 16.w, color: Theme.of(context).primaryColor),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(padding: EdgeInsets.all(12.w), child: child),
        ],
      ),
    );
  }
}

/// Field yang tidak diketik, hanya ditekan untuk membuka picker.
class _TapField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TapField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp),
          suffixIcon: Icon(icon, size: 16.w),
        ),
        child: Text(
          value,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
        ),
      ),
    );
  }
}
