import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/incoming_inspection/barcode_coil/barcode_coil_bloc.dart';
import '../../bloc/incoming_inspection/barcode_coil/barcode_coil_event.dart';
import '../../bloc/incoming_inspection/barcode_coil/barcode_coil_state.dart';
import '../../bloc/incoming_inspection/coil_scan/coil_scan_bloc.dart';
import '../../bloc/incoming_inspection/inspection_option/inspection_option_bloc.dart';
import '../../bloc/incoming_inspection/inspection_submit/inspection_submit_bloc.dart';
import '../../bloc/incoming_inspection/vendor/vendor_bloc.dart';
import '../../bloc/incoming_inspection/vendor/vendor_event.dart';
import '../../bloc/incoming_inspection/vendor/vendor_state.dart';
import '../../data/repository/incoming_inspection_repository.dart';
import '../../models/incoming_inspection/vendor.dart';
import '../widgets/base_dropdown_search.dart';
import '../widgets/base_primary_button.dart';
import 'incoming_inspection_detail_screen.dart';
import 'incoming_inspection_form_screen.dart';
import 'widgets/coil_card.dart';

/// Layar awal fitur Incoming Inspection.
///
/// Alur:
///   1. Saat dibuka, langsung ambil riwayat inspeksi dengan rentang default
///      seminggu ini (start = 7 hari lalu, end = hari ini) tanpa filter vendor.
///   2. User bisa menyaring ulang: cari vendor (nama atau kode) lewat API
///      vendor, lalu tekan Cari. Filter vendor opsional - rentang tanggal saja
///      juga sah.
///   3. Hasil ditampilkan sebagai list kartu ringkas. Tekan salah satu kartu
///      untuk melihat seluruh kolom view di layar detail.
///   4. Tombol Inspeksi membuka form pembuatan inspection_hdr + inspection_dtl,
///      di mana item ditambahkan lewat scan barcode.
class IncomingInspectionScreen extends StatelessWidget {
  final String title;
  final String entityId;

  const IncomingInspectionScreen({
    super.key,
    this.title = 'Incoming Inspection',
    required this.entityId,
  });

  @override
  Widget build(BuildContext context) {
    log(
      'Access to presentation/incomine_inspection/incoming_inspection_screen.dart',
    );

    final repository = context.read<IncomingInspectionRepository>();
    final range = IncomingInspectionRepository.defaultRange();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => BarcodeCoilBloc(incomingInspectionRepository: repository)
                ..add(
                  LoadBarcodeCoil(startDate: range.start, endDate: range.end),
                ),
        ),
        BlocProvider(
          create: (_) => VendorBloc(incomingInspectionRepository: repository),
        ),
        BlocProvider(
          create:
              (_) => InspectionSubmitBloc(
                incomingInspectionRepository: repository,
              ),
        ),
        BlocProvider(
          create:
              (_) => InspectionOptionBloc(
                incomingInspectionRepository: repository,
              ),
        ),
        BlocProvider(
          create: (_) => CoilScanBloc(incomingInspectionRepository: repository),
        ),
      ],
      child: IncomingInspectionView(title: title, entityId: entityId),
    );
  }
}

class IncomingInspectionView extends StatefulWidget {
  final String title;
  final String entityId;

  const IncomingInspectionView({
    super.key,
    required this.title,
    required this.entityId,
  });

  @override
  State<IncomingInspectionView> createState() => _IncomingInspectionViewState();
}

class _IncomingInspectionViewState extends State<IncomingInspectionView> {
  late DateTime _startDate;
  late DateTime _endDate;
  Vendor? _selectedVendor;
  bool _filterExpanded = true;

  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final range = IncomingInspectionRepository.defaultRange();
    _startDate = range.start;
    _endDate = range.end;
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<BarcodeCoilBloc>().add(
      LoadBarcodeCoil(
        vendorId: _selectedVendor?.vendorId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    setState(() => _filterExpanded = false);
  }

  void _resetFilter() {
    final range = IncomingInspectionRepository.defaultRange();
    _vendorController.clear();
    _searchController.clear();
    context.read<VendorBloc>().add(ClearVendor());

    setState(() {
      _startDate = range.start;
      _endDate = range.end;
      _selectedVendor = null;
    });

    _load();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isStart ? 'Pilih Start Date' : 'Pilih End Date',
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;

        /// Jaga supaya start tidak melewati end.
        if (_startDate.isAfter(_endDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
    });
  }

  /// Buka form inspeksi. Bloc opsi, scan, dan submit dibagikan lewat
  /// BlocProvider.value supaya form memakai instance yang sama dengan layar ini.
  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<InspectionSubmitBloc>()),
                BlocProvider.value(value: context.read<InspectionOptionBloc>()),
                BlocProvider.value(value: context.read<CoilScanBloc>()),
              ],
              child: const IncomingInspectionFormScreen(),
            ),
      ),
    );

    /// Setelah simpan berhasil, muat ulang supaya inspeksi baru ikut muncul.
    if (saved == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        actions: [
          _buildFilterToggle(),
          SizedBox(width: 8.w),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(
          'Inspeksi',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_filterExpanded) _buildFilterPanel(),
            _buildSummaryBar(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  /// Tombol show/hide filter dibuat berbentuk pill berlabel supaya menonjol di
  /// AppBar. Saat panel terbuka tombolnya putih solid (state aktif), saat
  /// tertutup hanya outline transparan.
  Widget _buildFilterToggle() {
    final primary = Theme.of(context).primaryColor;
    final active = _filterExpanded;
    final foreground = active ? primary : Colors.white;

    return Tooltip(
      message: active ? 'Sembunyikan filter' : 'Tampilkan filter',
      child: Center(
        child: Material(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.15),
          shape: StadiumBorder(
            side: BorderSide(color: Colors.white, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _filterExpanded = !_filterExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? Icons.filter_alt_off : Icons.filter_alt,
                    color: foreground,
                    size: 18.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    active ? Icons.expand_less : Icons.expand_more,
                    color: foreground,
                    size: 18.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PANEL FILTER
  // ===========================================================================

  Widget _buildFilterPanel() {
    return Container(
      margin: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Data',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          // SizedBox(height: 4.w),
          // Text(
          //   'Vendor boleh dikosongkan. Kalau kosong, data diambil berdasarkan '
          //   'rentang tanggal saja.',
          //   style: TextStyle(
          //     fontFamily: 'Poppins',
          //     fontSize: 11.sp,
          //     color: Colors.grey.shade600,
          //   ),
          // ),
          // SizedBox(height: 8.w),

          /// Pencarian vendor: ketik nama atau kode, hasil datang dari API.
          BlocBuilder<VendorBloc, VendorState>(
            builder: (context, state) {
              final items = state is VendorLoaded ? state.data : <Vendor>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseDropdownSearch<Vendor>(
                    label: 'Vendor (nama atau kode)',
                    controller: _vendorController,
                    items: items,
                    getLabel: (vendor) => vendor.label,
                    selectedValue: _selectedVendor,
                    onSearchChanged: (keyword) {
                      context.read<VendorBloc>().add(SearchVendor(keyword));
                    },
                    onChanged: (vendor) {
                      setState(() => _selectedVendor = vendor);
                    },
                  ),
                  if (state is VendorLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 4.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12.w,
                            height: 12.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Mencari vendor...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state is VendorError)
                    Padding(
                      padding: EdgeInsets.only(top: 4.w),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.sp,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          SizedBox(height: 8.w),

          /// Rentang tanggal
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start Date',
                  value: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _DateField(
                  label: 'End Date',
                  value: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.w),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: _resetFilter,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: BlocBuilder<BarcodeCoilBloc, BarcodeCoilState>(
                  builder: (context, state) {
                    return BasePrimaryButton(
                      label: 'Cari',
                      icon: Icons.search,
                      isLoading: state is BarcodeCoilLoading,
                      onPressed: _load,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RINGKASAN + PENCARIAN LOKAL
  // ===========================================================================

  Widget _buildSummaryBar() {
    return BlocBuilder<BarcodeCoilBloc, BarcodeCoilState>(
      builder: (context, state) {
        if (state is! BarcodeCoilLoaded) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Pencarian lokal terhadap data yang sudah terambil.
              TextField(
                controller: _searchController,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari no inspeksi, coil, SJ, kendaraan',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.search, size: 18.w),
                  suffixIcon:
                      _searchController.text.isEmpty
                          ? null
                          : IconButton(
                            icon: Icon(Icons.close, size: 16.w),
                            onPressed: () {
                              _searchController.clear();
                              context.read<BarcodeCoilBloc>().add(
                                FilterBarcodeCoil(''),
                              );
                              setState(() {});
                            },
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) {
                  context.read<BarcodeCoilBloc>().add(FilterBarcodeCoil(value));
                  setState(() {});
                },
              ),

              SizedBox(height: 6.w),

              Text(
                '${state.inspectionCount} inspeksi  •  '
                '${state.coilCount} coil'
                '${state.data.length == state.coilCount ? '' : '  •  ${state.data.length} tampil'}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // LIST
  // ===========================================================================

  Widget _buildList() {
    return BlocBuilder<BarcodeCoilBloc, BarcodeCoilState>(
      builder: (context, state) {
        if (state is BarcodeCoilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BarcodeCoilError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.w),
                  SizedBox(height: 12.w),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
                  ),
                  SizedBox(height: 16.w),
                  BasePrimaryButton(
                    label: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: _load,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is BarcodeCoilLoaded) {
          if (state.data.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48.w,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12.w),
                    Text(
                      state.all.isEmpty
                          ? 'Belum ada inspeksi pada rentang tanggal ini'
                          : 'Tidak ada data yang cocok dengan pencarian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 80.w),
              itemCount: state.data.length,
              itemBuilder: (context, index) {
                final coil = state.data[index];
                return CoilCard(
                  coil: coil,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => IncomingInspectionDetailScreen(coil: coil),
                        ),
                      ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// =============================================================================
// WIDGET PENDUKUNG
// =============================================================================

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp),
          suffixIcon: Icon(Icons.calendar_today, size: 16.w),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(
          '$dd/$mm/${value.year}',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
        ),
      ),
    );
  }
}
