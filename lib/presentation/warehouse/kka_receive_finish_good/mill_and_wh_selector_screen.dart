import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/receive_warehouse/rw_selector/rw_selector_bloc.dart';
import '../../../data/repository/receive_warehouse_repository.dart';
import '../../../models/mill.dart';
import '../../../models/receive_warehouse/receive_warehouse.dart';
import 'receive_warehouse_scan_screen.dart';

/// Langkah 1 Receive Warehouse: pilih mill, warehouse, dan shift.
///
/// Meniru filter di halaman web kka/transfer_warehouse/Index.vue:
///   Mill      - master mill (mill_type 'M'), tampil mill_name
///   Warehouse - whouse milik mill terpilih, dimuat ulang setiap mill berganti,
///               tampil descr
///   Shift     - 1, 2, 3
///
/// Pilihan di sini dibawa ke layar scan dan dipakai server untuk memastikan
/// barang yang discan memang dikirim ke mill + warehouse ini.
class MillAndWhSelectorScreen extends StatelessWidget {
  static String routeName = "MillAndWhSelectorScreen";

  const MillAndWhSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => RwSelectorBloc(
            repository: context.read<ReceiveWarehouseRepository>(),
          )..add(const RwSelectorStarted()),
      child: const _SelectorView(),
    );
  }
}

class _SelectorView extends StatefulWidget {
  const _SelectorView();

  @override
  State<_SelectorView> createState() => _SelectorViewState();
}

class _SelectorViewState extends State<_SelectorView> {
  RwWarehouse? _warehouse;
  String? _shift;
  int _warehouseVersion = 0;

  void _go(Mill mill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReceiveWarehouseScanScreen(
              selection: RwSelection(
                mill: mill,
                warehouse: _warehouse!,
                shift: _shift!,
              ),
            ),
      ),
    );
  }

  InputDecoration _decoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.w)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Receive Warehouse',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: BlocConsumer<RwSelectorBloc, RwSelectorState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          /// Mill berganti -> warehouse yang dipilih sebelumnya tidak berlaku,
          /// sama seperti getListWarehouse() di web yang mengosongkan _wh_id.
          if (state.warehouseVersion != _warehouseVersion) {
            _warehouseVersion = state.warehouseVersion;
            _warehouse = null;
          }

          if (state.optionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.mills.isEmpty) {
            return _EmptyOption(
              message: state.error ?? 'Tidak ada mill yang tersedia',
              onRetry:
                  () => context.read<RwSelectorBloc>().add(
                    const RwSelectorStarted(),
                  ),
            );
          }

          final mill = state.selectedMill;
          final canGo = mill != null && _warehouse != null && _shift != null;

          final String warehouseHint;
          if (mill == null) {
            warehouseHint = 'Pilih mill terlebih dahulu';
          } else if (state.warehouseLoading) {
            warehouseHint = 'Memuat warehouse...';
          } else if (state.warehouses.isEmpty) {
            warehouseHint = 'Tidak ada warehouse di mill ini';
          } else {
            warehouseHint = 'Pilih warehouse';
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 12.h),
                  Image.asset(
                    'assets/images/warehouse.png',
                    width: 220.w,
                    height: 170.w,
                  ),
                  SizedBox(height: 20.h),

                  /// ----- Mill -----
                  const _FieldLabel('Mill', required: true),
                  DropdownButtonFormField<Mill>(
                    /// Mill bisa terpilih otomatis oleh bloc (hanya satu
                    /// mill), jadi key ikut berganti supaya nilainya tampil.
                    key: ValueKey('mill-${mill?.millID}'),
                    initialValue: mill,
                    isExpanded: true,
                    decoration: _decoration(hint: 'Pilih mill'),
                    items:
                        state.mills
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m.millName.isEmpty ? m.millID : m.millName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null || value == mill) return;
                      context.read<RwSelectorBloc>().add(
                        RwSelectorMillChanged(value),
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  /// ----- Warehouse (bergantung pada mill) -----
                  const _FieldLabel('Warehouse', required: true),
                  DropdownButtonFormField<RwWarehouse>(
                    /// Key ikut mill dan isi daftar, supaya dropdown reset
                    /// saat mill berganti dan menampilkan daftar terbaru.
                    key: ValueKey(
                      'wh-${state.warehouseVersion}-'
                      '${state.warehouseLoading}-${state.warehouses.length}',
                    ),
                    initialValue: _warehouse,
                    isExpanded: true,
                    decoration: _decoration(
                      hint: warehouseHint,
                      suffix:
                          state.warehouseLoading
                              ? Padding(
                                padding: EdgeInsets.all(12.w),
                                child: SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : null,
                    ),
                    items:
                        state.warehouses
                            .map(
                              (w) => DropdownMenuItem(
                                value: w,
                                child: Text(
                                  w.descr.isEmpty ? w.whId : w.descr,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        mill == null || state.warehouseLoading
                            ? null
                            : (value) => setState(() => _warehouse = value),
                  ),
                  SizedBox(height: 14.h),

                  /// ----- Shift -----
                  const _FieldLabel('Shift', required: true),
                  DropdownButtonFormField<String>(
                    initialValue: _shift,
                    isExpanded: true,
                    decoration: _decoration(hint: 'Pilih shift'),
                    items:
                        kRwShifts
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _shift = value),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: canGo ? () => _go(mill) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: Text(
                        'Lanjut',
                        style: TextStyle(
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Label di atas field, seperti di web ("Mill *").
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOption extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EmptyOption({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
