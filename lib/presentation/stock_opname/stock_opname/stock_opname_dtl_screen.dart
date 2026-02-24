import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'package:vivakencanaapp/bloc/stock_opname/barang_jadi_list/barang_jadi_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/prod_master/prod_master_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_dtl/stock_opname_dtl_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/wh_bin/wh_bin_bloc.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_dtl.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_hdr.dart';

import '../../../bloc/stock_opname/opname_update/opname_update_bloc.dart';
import '../../../data/data_providers/shared-preferences/shared_preferences_manager.dart';

/// ================= POPUP MODE =================
enum OpnamePopupMode { fromList, fromScan, addNew }

enum OpnameUpdateMode { overwrite, add }

class OpnameStockDtlScreen extends StatelessWidget {
  final StockOpnameHdr e;

  const OpnameStockDtlScreen({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<ProdMasterBloc>()..add(LoadProdMaster()),
        ),
        BlocProvider.value(
          value:
              context.read<WHBinBloc>()
                ..add(LoadWHBin(millId: e.millId, whId: e.whId)),
        ),
      ],
      child: OpnameStockDtlView(e: e),
    );
  }
}

class OpnameStockDtlView extends StatefulWidget {
  final StockOpnameHdr e;

  const OpnameStockDtlView({super.key, required this.e});

  @override
  State<OpnameStockDtlView> createState() => _OpnameStockDtlViewState();
}

class _OpnameStockDtlViewState extends State<OpnameStockDtlView> {
  /// ================= LIST =================
  final TextEditingController _searchCtrl = TextEditingController();
  String? binId;
  // String? batchId;
  bool isFromScan = false;
  StockOpnameDtl? _selectedItem;

  /// ================= SCANNER =================
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool _shouldApplyBinFilter = false;
  List<StockOpnameDtl> _binFilteredData = [];

  /// ================= POPUP CONTROLLERS =================
  final TextEditingController namaBarangCtrl = TextEditingController();
  final TextEditingController prodCodeCtrl = TextEditingController();
  final TextEditingController qualityId = TextEditingController();
  final TextEditingController batchCtrl = TextEditingController();
  final TextEditingController panjangCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  /// ================= POPUP STATE =================
  String addId = '';
  String torId = '';
  String acpId = '';
  // String qualityId = '';
  String ordFlag = 'N';
  String userId = '';

  /// ================= UI =================
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.grey),
  );

  @override
  void dispose() {
    _searchCtrl.dispose();
    namaBarangCtrl.dispose();
    prodCodeCtrl.dispose();
    batchCtrl.dispose();
    panjangCtrl.dispose();
    qtyCtrl.dispose();
    remarkCtrl.dispose();
    qrController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // log('Access to presentation/entity/entitiy_screen.dart');
    loadUserData();
    super.initState();
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        /// ✅ FIX 1: FILTER DIJALANKAN SETELAH DATA LOADED
        BlocListener<StockOpnameDtlBloc, StockOpnameDtlState>(
          listener: (context, state) {
            if (state is StockOpnameDtlLoaded &&
                _shouldApplyBinFilter &&
                binId != null) {
              _searchCtrl.clear();
              _shouldApplyBinFilter = false;

              final filtered =
                  state.allData.where((e) => e.binId == binId).toList();

              setState(() {
                _binFilteredData = filtered;
              });

              context.read<StockOpnameDtlBloc>().add(
                FilterBinBatchStockOpnameDtl(binId: binId),
              );
            }
          },
        ),

        BlocListener<OpnameBloc, OpnameState>(
          listener: (context, state) {
            if (state is OpnameSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opname berhasil disimpan')),
              );

              _searchCtrl.clear();
              _selectedItem = null;

              if (binId != null) {
                // 🔴 FORCE FULL RELOAD
                context.read<StockOpnameDtlBloc>().add(
                  LoadStockOpnameDtl(
                    trId: widget.e.trId,
                    millId: widget.e.millId,
                    whId: widget.e.whId,
                    binId: binId!,
                  ),
                );

                // 🔴 REAPPLY FILTER (INI YANG SEBELUMNYA HILANG)
                context.read<StockOpnameDtlBloc>().add(
                  FilterBinBatchStockOpnameDtl(binId: binId!),
                );
              }
            }

            if (state is OpnameError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal Opname, ${state.message}')),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Opname Detail',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.w,
            ),
          ),
        ),

        /// ================= FAB =================
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'scan',
              onPressed: () {
                context.read<BarangJadiBloc>().add(ClearBarangJadi());
                _openScanner();
              },
              child: const Icon(Icons.qr_code_scanner),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'add',
              onPressed: () {
                _openForm(mode: OpnamePopupMode.addNew);
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),

        /// ================= BODY =================
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'TR ID: ${widget.e.trId}',
                    style: TextStyle(
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Row(
                children: [
                  Icon(Icons.cabin, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Warehouse ID: ${widget.e.whId}',
                    style: TextStyle(fontSize: 12.w, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Row(
                children: [
                  Text(
                    'Category: ${widget.e.catDesc}',
                    style: TextStyle(
                      fontSize: 12.w,
                      color: const Color.fromARGB(255, 15, 15, 15),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= FILTER SECTION =================
            _filterSection(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    'Stock Opname List',
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 100, 100, 100),
                    ),
                  ),
                ),
              ],
            ),

            /// ================= LIST SECTION =================
            Expanded(
              child:
                  binId == null
                      ? const Center(
                        child: Text(
                          'Silakan pilih BIN terlebih dahulu',
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                      : BlocBuilder<StockOpnameDtlBloc, StockOpnameDtlState>(
                        builder: (context, state) {
                          if (state is StockOpnameDtlLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is StockOpnameDtlError) {
                            return Center(child: Text(state.message));
                          }
                          if (state is StockOpnameDtlLoaded) {
                            if (state.filteredData.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Data opname tidak ditemukan',
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: state.filteredData.length,
                              itemBuilder: (_, i) {
                                final item = state.filteredData[i];
                                return InkWell(
                                  onTap: () {
                                    _selectedItem = item;
                                    _openForm(
                                      mode: OpnamePopupMode.fromList,
                                      data: item,
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
      ),
    );
  }

  /// ================= FILTER UI =================
  Widget _filterSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          /// SEARCH — 3/4 WIDTH
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchCtrl,
                enabled: binId != null,
                onChanged: (v) {
                  if (binId == null) return;

                  final keyword = v.toLowerCase();

                  final result =
                      keyword.isEmpty
                          ? _binFilteredData
                          : _binFilteredData
                              .where(
                                (e) =>
                                    e.namaBarang.toLowerCase().contains(
                                      keyword,
                                    ) ||
                                    e.prodCode.toLowerCase().contains(keyword),
                              )
                              .toList();

                  context.read<StockOpnameDtlBloc>().emit(
                    StockOpnameDtlLoaded(
                      allData: _binFilteredData,
                      filteredData: result,
                      binBatchMap: {},
                    ),
                  );
                },
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 14),
                  hintText: 'Cari Nama Barang / Kode',
                  border: border,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// BIN — 1/4 WIDTH
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 40,
              child: BlocBuilder<WHBinBloc, WHBinState>(
                builder: (context, binState) {
                  if (binState is WHBinLoading) {
                    return const SizedBox();
                  }

                  if (binState is WHBinError) {
                    return Text(
                      binState.message,
                      style: const TextStyle(fontSize: 12),
                    );
                  }

                  if (binState is! WHBinLoaded) {
                    return const SizedBox();
                  }

                  return DropdownButtonFormField<String>(
                    value: binId,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: InputDecoration(
                      isDense: true,
                      // prefixIcon: const Icon(Icons.warehouse, size: 14),
                      labelText: 'BIN',
                      labelStyle: const TextStyle(fontSize: 8),
                      border: border,
                    ),
                    items:
                        binState.data
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.binId,
                                child: Text(
                                  e.binId,
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      if (v == null) return;

                      setState(() {
                        binId = v;
                        _shouldApplyBinFilter = true;
                      });

                      context.read<StockOpnameDtlBloc>().add(
                        LoadStockOpnameDtl(
                          trId: widget.e.trId,
                          millId: widget.e.millId,
                          whId: widget.e.whId,
                          binId: v,
                        ),
                      );

                      context.read<StockOpnameDtlBloc>().add(
                        FilterBinBatchStockOpnameDtl(binId: v),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SCANNER =================
  void _openScanner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              height: 300,
              width: 300,
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
            ),
          ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code == null) return;
      final result = json.decode(scanData.code!);
      await controller.pauseCamera();
      Navigator.pop(context);
      _openFormFromScan(scanResult: result);
    });
  }

  void _openFormFromScan({required Map<String, dynamic> scanResult}) {
    isFromScan = true;
    // ===== RESET STATE FORM =====
    context.read<BarangJadiBloc>().add(ClearBarangJadi());

    namaBarangCtrl.clear();
    prodCodeCtrl.clear();
    batchCtrl.clear();
    panjangCtrl.clear();
    qtyCtrl.clear();
    qualityId.clear();

    addId = '';
    torId = '';
    acpId = '';
    ordFlag = 'N';

    // ===== ISI DARI QR =====
    final prodCode = scanResult['prod_code'] ?? '';

    prodCodeCtrl.text = prodCode;
    batchCtrl.text = scanResult['batch_id'] ?? '';
    panjangCtrl.text = scanResult['panjang']?.toString() ?? '';
    qualityId.text = scanResult['quality_id'] ?? '';
    ordFlag = scanResult['ord_flag'] ?? 'N';

    // ===== TRIGGER AUTO SEARCH BARANG =====
    context.read<BarangJadiBloc>().add(SearchBarangJadiFromScan(prodCode));

    // ===== OPEN DIALOG =====
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final prodMasterBloc = context.read<ProdMasterBloc>();
        prodMasterBloc.add(LoadProdMaster());

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: prodMasterBloc),
            BlocProvider.value(value: context.read<BarangJadiBloc>()),
          ],
          child: BlocListener<BarangJadiBloc, BarangJadiState>(
            listener: (context, state) {
              if (state is BarangJadiLoaded && state.selected != null) {
                namaBarangCtrl.text = state.selected!.namaBarang;
                prodCodeCtrl.text = state.selected!.barangJadiId;
                qualityId.text = state.selected!.grade;

                context.read<BarangJadiBloc>().add(ClearBarangJadi());
              }
            },
            child: AlertDialog(
              title: const Text(
                'Tambah Barang (Scan)',
                style: TextStyle(fontSize: 14),
              ),
              content: SingleChildScrollView(
                child: _addFormContent(), // reuse existing form UI
              ),
              actions: _dialogActions(OpnamePopupMode.addNew),
            ),
          ),
        );
      },
    );
  }

  /// ================= OPEN FORM =================
  void _openForm({
    required OpnamePopupMode mode,
    StockOpnameDtl? data,
    Map<String, dynamic>? scanResult,
  }) {
    context.read<BarangJadiBloc>().add(ClearBarangJadi());

    namaBarangCtrl.clear();
    prodCodeCtrl.clear();
    batchCtrl.clear();
    panjangCtrl.clear();
    qtyCtrl.clear();
    qualityId.clear();

    addId = '';
    torId = '';
    acpId = '';
    // qualityId = '';
    ordFlag = 'N';

    if (mode == OpnamePopupMode.fromList && data != null) {
      namaBarangCtrl.text = data.namaBarang;
      prodCodeCtrl.text = data.prodCode;
      batchCtrl.text = data.batchId;
      panjangCtrl.text = data.panjang.toString();
      qtyCtrl.text = data.qtyOpname.toString();
      remarkCtrl.text = data.remark.toString();
      addId = data.addId;
      torId = data.torId;
      binId = data.binId;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final prodMasterBloc = context.read<ProdMasterBloc>();
        prodMasterBloc.add(LoadProdMaster()); // ⬅️ WAJIB DI SINI

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: prodMasterBloc),
            BlocProvider.value(value: context.read<BarangJadiBloc>()),
          ],
          child: AlertDialog(
            title: Text(
              mode == OpnamePopupMode.addNew
                  ? 'Tambah Barang'
                  : 'Update Quantity',
              style: const TextStyle(fontSize: 14),
            ),
            content: SingleChildScrollView(
              child:
                  mode == OpnamePopupMode.addNew
                      ? _addFormContent()
                      : _popupContent(),
            ),
            actions: _dialogActions(mode),
          ),
        );
      },
    );
  }

  List<Widget> _dialogActions(OpnamePopupMode mode) {
    return [
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                namaBarangCtrl.clear();
                prodCodeCtrl.clear();
                qtyCtrl.clear();
                qualityId.clear();
                qtyCtrl.clear();
                panjangCtrl.clear();
                remarkCtrl.clear();
                Navigator.pop(context);
                context.read<BarangJadiBloc>().add(ClearBarangJadi());
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _handleSubmitWithCheck();
              },
              child: Text('Simpan'),
            ),
          ),
        ],
      ),
    ];
  }

  /// ================= ADD FORM (BARU) =================
  Widget _addFormContent() {
    return Column(
      children: [
        /// ================= PRODUCT CODE =================
        _readonlyCtrl('Product Code', prodCodeCtrl),

        /// ================= NAMA BARANG =================
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: namaBarangCtrl,
              style: TextStyle(fontSize: 12),
              onChanged:
                  (v) =>
                      context.read<BarangJadiBloc>().add(SearchBarangJadi(v)),
              decoration: InputDecoration(
                labelText: 'Nama Barang*',
                isDense: true,
                border: border,
                labelStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        BlocBuilder<BarangJadiBloc, BarangJadiState>(
          builder: (context, state) {
            if (state is BarangJadiLoading) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            }

            if (state is BarangJadiLoaded && state.data.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.data.length,
                  itemBuilder: (_, i) {
                    final item = state.data[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        item.namaBarang,
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        item.barangJadiId,
                        style: const TextStyle(fontSize: 10),
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        namaBarangCtrl.text = item.namaBarang;
                        prodCodeCtrl.text = item.barangJadiId;
                        qualityId.text = item.grade;
                        context.read<BarangJadiBloc>().add(ClearBarangJadi());
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        _editableLong('Panjang', panjangCtrl),

        BlocBuilder<ProdMasterBloc, ProdMasterState>(
          builder: (context, state) {
            if (state is! ProdMasterLoaded) return const SizedBox();

            return SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 12, color: Colors.black),
                isExpanded: true, // ⬅️ WAJIB
                value: torId.isEmpty ? null : torId,
                decoration: InputDecoration(
                  labelText: 'Tor ID',
                  border: border,
                  isDense: true,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                items:
                    state.prodTor.map((e) {
                      return DropdownMenuItem(
                        value: e.torId,
                        child: Text(
                          '${e.torId} - ${e.descr}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    torId = v ?? '';
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        BlocBuilder<ProdMasterBloc, ProdMasterState>(
          builder: (context, state) {
            // log('STATE PROD MASTER = $state');
            if (state is ProdMasterLoading) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            }

            if (state is ProdMasterError) {
              return Text(state.message);
            }

            if (state is! ProdMasterLoaded) {
              return const SizedBox();
            }

            return SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 12, color: Colors.black),
                isExpanded: true, // ⬅️ WAJIB DITAMBAHKAN
                value: addId.isEmpty ? null : addId,
                decoration: InputDecoration(
                  labelText: 'Add ID',
                  border: border,
                  isDense: true,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                items:
                    state.prodAdd.map((e) {
                      return DropdownMenuItem(
                        value: e.addId,
                        child: Text(
                          '${e.addId} - ${e.descr}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    addId = v ?? '';
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // _editable('Batch', batchCtrl),
        _qtytable('Qty Opname*', qtyCtrl),
        const SizedBox(height: 8),
        _binDropdown(),
      ],
    );
  }

  /// ================= UPDATE FORM =================
  Widget _popupContent() {
    return Column(
      children: [
        _readonlyCtrl('Product Code', prodCodeCtrl),
        _readonlyCtrl('Nama Barang', namaBarangCtrl),
        _editableLong('Panjang', panjangCtrl),
        BlocBuilder<ProdMasterBloc, ProdMasterState>(
          builder: (context, state) {
            // log('STATE PROD MASTER = $state');
            if (state is ProdMasterLoading) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            }

            if (state is ProdMasterError) {
              return Text(state.message);
            }

            if (state is! ProdMasterLoaded) {
              return const SizedBox();
            }

            return SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 12, color: Colors.black),
                isExpanded: true, // ⬅️ WAJIB DITAMBAHKAN
                value: addId.isEmpty ? null : addId,
                decoration: InputDecoration(
                  labelText: 'Add ID',
                  border: border,
                  isDense: true,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                items:
                    state.prodAdd.map((e) {
                      return DropdownMenuItem(
                        value: e.addId,
                        child: Text(
                          '${e.addId} - ${e.descr}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    addId = v ?? '';
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        BlocBuilder<ProdMasterBloc, ProdMasterState>(
          builder: (context, state) {
            if (state is! ProdMasterLoaded) return const SizedBox();

            return SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                style: TextStyle(fontSize: 12, color: Colors.black),
                isExpanded: true, // ⬅️ WAJIB
                value: torId.isEmpty ? null : torId,
                decoration: InputDecoration(
                  labelText: 'Tor ID',
                  border: border,
                  isDense: true,
                  labelStyle: TextStyle(fontSize: 12),
                ),
                items:
                    state.prodTor.map((e) {
                      return DropdownMenuItem(
                        value: e.torId,
                        child: Text(
                          '${e.torId} - ${e.descr}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  setState(() {
                    torId = v ?? '';
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // _editable('Batch', batchCtrl),
        _qtytable('Qty Opname*', qtyCtrl),
      ],
    );
  }

  void _submitOpname() {
    // print("mill_id : ${widget.millId}");
    // print("whId : ${widget.whId}");
    // print("binId : $binId");
    // print("trId : ${widget.trId}");
    // print("prodCode : ${prodCodeCtrl.text}");
    // print("addId : $addId");
    // print("torId : $torId");
    // print("panjang : ${panjangCtrl.text}");
    // print("batchId : ${batchCtrl.text}");
    // print("remark : ${remarkCtrl.text}");
    // print("qtyOpname : ${qtyCtrl.text}");
    // print("userId2 : $userId");
    context.read<OpnameBloc>().add(
      SubmitOpnameUpdate(
        millId: widget.e.millId,
        whId: widget.e.whId,
        binId: binId ?? '',
        trId: widget.e.trId,
        prodCode: prodCodeCtrl.text,
        addId: addId,
        torId: torId,
        panjang: panjangCtrl.text,
        qualityId: qualityId.text,
        batchId: batchCtrl.text,
        remark: remarkCtrl.text,
        qtyOpname: qtyCtrl.text,
        userId2: userId,
      ),
    );
  }

  Widget _qtytable(String label, TextEditingController ctrl) {
    OutlineInputBorder greenBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: ctrl,
          style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
            enabledBorder: greenBorder,
            focusedBorder: greenBorder,
            disabledBorder: greenBorder,
            errorBorder: greenBorder,
            focusedErrorBorder: greenBorder,
            border: greenBorder,
          ),
        ),
      ),
    );
  }

  Widget _editableLong(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          controller: ctrl,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            border: border,
            labelStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _binDropdown() {
    return BlocBuilder<WHBinBloc, WHBinState>(
      builder: (context, state) {
        if (state is WHBinLoading) {
          return const SizedBox(height: 40);
        }

        if (state is WHBinError) {
          return Text(state.message, style: const TextStyle(fontSize: 12));
        }

        if (state is! WHBinLoaded) {
          return const SizedBox();
        }

        return SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            value: binId,
            isExpanded: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            decoration: InputDecoration(
              labelText: 'BIN ID',
              isDense: true,
              border: border,
              labelStyle: const TextStyle(fontSize: 12),
            ),
            items:
                state.data.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.binId,
                    child: Text(e.binId, style: const TextStyle(fontSize: 10)),
                  );
                }).toList(),
            onChanged: (v) {
              setState(() {
                binId = v;
              });
            },
          ),
        );
      },
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            border: border,
            labelStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _readonlyCtrl(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 45,
        child: TextField(
          controller: ctrl,
          readOnly: true,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            border: border,
            labelStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// ================= LIST ITEM =================
  Widget _item(StockOpnameDtl e) {
    return ListTile(
      title: Text(
        e.namaBarang,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${e.prodCode}, P : ${e.panjang}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text('Opn: ${e.qtyOpname}'),
    );
  }

  void _showOverwriteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Opname',
            style: TextStyle(fontSize: 14),
          ),
          content: const Text(
            'Barang telah di opname.\n\n'
            'Apakah ingin overwrite atau menambahkan quantity dengan data yang sudah ada?',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // OVERWRITE
                Navigator.pop(context);
                _submitOpname();
                Navigator.pop(context); // tutup popup form
              },
              child: const Text('Overwrite'),
            ),
            ElevatedButton(
              onPressed: () {
                // TAMBAH QTY
                final existingQty = _selectedItem?.qtyOpname ?? 0;
                final inputQty = double.tryParse(qtyCtrl.text) ?? 0;

                qtyCtrl.text = (existingQty + inputQty).toString();

                Navigator.pop(context);
                _submitOpname();
                Navigator.pop(context);
              },
              child: const Text('Tambah Qty'),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmitWithCheck() {
    // KASUS ADD BARU (tidak pilih item lama)
    if (_selectedItem == null || _selectedItem!.dtCek == null) {
      _submitOpname();
      Navigator.pop(context);
      return;
    }

    final old = _selectedItem!;

    // ================= CEK DEFAULT DATE (BELUM PERNAH OPNAME)
    final dtCek = old.dtCek!;
    final isDefaultDate =
        dtCek.year == 1900 && dtCek.month == 1 && dtCek.day == 1;

    if (isDefaultDate) {
      _submitOpname();
      Navigator.pop(context);
      return;
    }

    // ================= CEK APAKAH BARANG MASIH "SAMA"
    final isSameItem =
        old.prodCode == prodCodeCtrl.text &&
        old.addId == addId &&
        old.torId == torId &&
        old.panjang.toString() == panjangCtrl.text &&
        old.binId == binId;

    // 🔴 JIKA BEDA IDENTITAS BARANG → ANGGAP BARANG BARU
    if (!isSameItem) {
      _submitOpname();
      Navigator.pop(context);
      return;
    }

    // ================= HANYA DI SINI POPUP MUNCUL
    // Artinya:
    // - Barang sama
    // - Sudah pernah opname
    // - User hanya ubah QTY
    _showOverwriteDialog();
  }

  Future<void> loadUserData() async {
    final SharedPreferencesManager authSharedPref = SharedPreferencesManager(
      key: 'auth',
    );
    final dataString = await authSharedPref.read();

    if (dataString != null) {
      final Map<String, dynamic> data = json.decode(dataString);
      final user = data['user'];
      // print(user);
      setState(() {
        userId = user['user_id2'] ?? '-';
        // dept = user['dept_id'].trim() == "" ? '-' : user['dept_id'].trim();
      });
    }
  }
}
