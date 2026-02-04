import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_dtl.dart';

import '../../../bloc/stock_opname/stock_opname_dtl/stock_opname_dtl_bloc.dart';

class OpnameStockDtlScreen extends StatelessWidget {
  final String trId;
  final String millId;
  final String whId;

  const OpnameStockDtlScreen({
    super.key,
    required this.trId,
    required this.millId,
    required this.whId,
  });

  @override
  Widget build(BuildContext context) {
    log('Access OpnameStockDtlScreen');

    return BlocProvider.value(
      value:
          context.read<StockOpnameDtlBloc>()
            ..add(LoadStockOpnameDtl(trId: trId, millId: millId, whId: whId)),
      child: OpnameStockDtlView(trId: trId, millId: millId, whId: whId),
    );
  }
}

class OpnameStockDtlView extends StatefulWidget {
  final String trId;
  final String millId;
  final String whId;

  const OpnameStockDtlView({
    super.key,
    required this.trId,
    required this.millId,
    required this.whId,
  });

  @override
  State<OpnameStockDtlView> createState() => _OpnameStockDtlViewState();
}

class _OpnameStockDtlViewState extends State<OpnameStockDtlView> {
  final TextEditingController _searchCtrl = TextEditingController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  String? binId;
  String? batchId;

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.grey),
  );

  @override
  void dispose() {
    _searchCtrl.dispose();
    qrController?.dispose();
    super.dispose();
  }

  void _clearFilter(BuildContext context) {
    setState(() {
      binId = null;
      batchId = null;
    });

    context.read<StockOpnameDtlBloc>().add(FilterBinBatchStockOpnameDtl());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Opname Detail",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: _openScanner,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _openForm(isAdd: true),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          _filterSection(),
          Expanded(
            child: BlocBuilder<StockOpnameDtlBloc, StockOpnameDtlState>(
              builder: (context, state) {
                if (state is StockOpnameDtlLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StockOpnameDtlError) {
                  return Center(child: Text(state.message));
                }

                if (state is StockOpnameDtlLoaded) {
                  return ListView.builder(
                    itemCount: state.filteredData.length,
                    itemBuilder: (_, i) {
                      final item = state.filteredData[i];

                      return InkWell(
                        onTap: () {
                          _openForm(
                            isAdd: false, // 🔴 UPDATE MODE
                            data: item, // 🔴 DATA DARI LIST
                          );
                        },
                        child: _item(item),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= FILTER =================
  Widget _filterSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: BlocBuilder<StockOpnameDtlBloc, StockOpnameDtlState>(
        builder: (context, state) {
          if (state is! StockOpnameDtlLoaded) {
            return const SizedBox();
          }

          final bins = state.binBatchMap.keys.toList()..sort();
          final batches =
              binId == null ? <String>[] : state.binBatchMap[binId!]!.toList()
                ..sort();

          return Column(
            children: [
              /// ================= SEARCH =================
              SizedBox(
                height: 30,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged:
                      (v) => context.read<StockOpnameDtlBloc>().add(
                        SearchStockOpnameDtl(v),
                      ),
                  style: const TextStyle(fontSize: 10),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 14),
                    hintText: 'Cari Nama Barang / Kode',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// ================= BIN & BATCH =================
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    /// BIN
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: binId,
                        isDense: true,
                        iconSize: 16,
                        decoration: InputDecoration(
                          labelText: 'BIN',
                          labelStyle: const TextStyle(fontSize: 10),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          suffixIcon:
                              binId == null
                                  ? null
                                  : IconButton(
                                    icon: const Icon(Icons.clear, size: 14),
                                    onPressed: () => _clearFilter(context),
                                  ),
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border.copyWith(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        items:
                            bins
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          setState(() {
                            binId = v;
                            batchId = null;
                          });

                          context.read<StockOpnameDtlBloc>().add(
                            FilterBinBatchStockOpnameDtl(binId: binId),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// BATCH
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: batchId,
                        isDense: true,
                        iconSize: 16,
                        decoration: InputDecoration(
                          labelText: 'Batch',
                          labelStyle: const TextStyle(fontSize: 10),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          suffixIcon:
                              batchId == null
                                  ? null
                                  : IconButton(
                                    icon: const Icon(Icons.clear, size: 14),
                                    onPressed: () {
                                      setState(() => batchId = null);

                                      context.read<StockOpnameDtlBloc>().add(
                                        FilterBinBatchStockOpnameDtl(
                                          binId: binId,
                                        ),
                                      );
                                    },
                                  ),
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border.copyWith(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        items:
                            batches
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            batches.isEmpty
                                ? null
                                : (v) {
                                  setState(() => batchId = v);

                                  context.read<StockOpnameDtlBloc>().add(
                                    FilterBinBatchStockOpnameDtl(
                                      binId: binId,
                                      batchId: batchId,
                                    ),
                                  );
                                },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ========================= SCANNER =========================
  void _openScanner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: 300,
            width: 300,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code == null) return;

      try {
        final Map<String, dynamic> result = json.decode(scanData.code!);

        log('SCAN RESULT: $result');

        await controller.pauseCamera();
        Navigator.pop(context); // close scanner

        _openForm(scanResult: result);
      } catch (e) {
        log('INVALID QR FORMAT');
      }
    });
  }

  Widget _edibleCoumn() {
    return Column(
      children: [
        _readonly('TR ID', widget.trId),
        _readonly('WH ID', widget.whId),
        _readonly('BIN ID', binId ?? '-'),

        _editable(label: 'Product Code', controller: TextEditingController()),
        _editable(label: 'Batch', controller: TextEditingController()),
        _editable(label: 'Panjang', controller: TextEditingController()),

        const SizedBox(height: 10),

        _editable(
          label: 'Result Opname Quantity',
          controller: TextEditingController(),
        ),
      ],
    );
  }

  Widget unEdibleColumn(
    StockOpnameDtl? data,
    Map<String, dynamic>? scanResult,
  ) {
    final prodCode = data?.prodCode ?? scanResult?['prod_code'] ?? '';
    final batch = data?.batchId ?? scanResult?['batch_id'] ?? '';
    final panjang = data?.panjang ?? scanResult?['panjang'] ?? '';
    final initialQty = data?.qtyOpname.toString() ?? '';

    final qtyCtrl = TextEditingController(text: initialQty);
    return Column(
      children: [
        _readonly('TR ID', widget.trId),
        _readonly('WH ID', widget.whId),
        _readonly('BIN ID', binId ?? '-'),

        _readonly('Product Code', prodCode),
        _readonly('Batch', batch),
        _readonly('Panjang', panjang.toString()),

        const SizedBox(height: 10),

        _editable(label: 'Result Opname Quantity', controller: qtyCtrl),
      ],
    );
  }

  // ========================= FORM =========================
  void _openForm({
    bool isAdd = false,
    StockOpnameDtl? data,
    Map<String, dynamic>? scanResult,
  }) {
    // ================= RESOLVE DATA =================

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(
            isAdd ? 'Tambah Barang' : 'Update Quantity',
            style: TextStyle(fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: (isAdd) ? _edibleCoumn() : unEdibleColumn(data, scanResult),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isAdd) {
                        // _addOpname(...)
                      } else {
                        // _updateOpname(...)
                      }
                      Navigator.pop(context);
                    },
                    child: Text(isAdd ? 'Tambah' : 'Update'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _editable({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SizedBox(
        height: 40, // 🔴 FIX HEIGHT
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 10),
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }

  // ========================= FIELD =========================
  Widget _readonly(String label, String value) {
    final ctrl = TextEditingController(text: value.isEmpty ? '-' : value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 40, // 🔴 FIX HEIGHT
        child: TextField(
          controller: ctrl,
          readOnly: true,
          style: const TextStyle(fontSize: 10),
          decoration: InputDecoration(
            isDense: true, // 🔴 WAJIB
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8, // 🔴 KUNCI TINGGI
              horizontal: 12,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }

  // ===================== API STUB =====================
  void _updateOpname(String qty) {
    // TODO: hit API update opname_dtl
    debugPrint('UPDATE QTY: $qty');
  }

  void _addOpname(String qty) {
    // TODO: hit API insert opname_dtl
    debugPrint('ADD QTY: $qty');
  }

  /// ================= ITEM =================
  Widget _item(StockOpnameDtl e) {
    return ListTile(
      title: Text(
        e.namaBarang,
        style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${e.prodCode} | Panjang ${e.panjang}',
        style: TextStyle(fontSize: 12.w),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Add ID: ${e.addId}', style: TextStyle(fontSize: 11.w)),
          // Text('Awal: ${e.qtyAwal}', style: TextStyle(fontSize: 11.w)),
          Text('Opn: ${e.qtyOpname}'),
        ],
      ),
    );
  }
}
