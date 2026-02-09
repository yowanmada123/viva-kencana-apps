import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'package:vivakencanaapp/bloc/stock_opname/barang_jadi_list/barang_jadi_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/prod_master/prod_master_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_dtl/stock_opname_dtl_bloc.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_dtl.dart';

import '../../../bloc/stock_opname/opname_update/opname_update_bloc.dart';
import '../../../data/data_providers/shared-preferences/shared_preferences_manager.dart';

/// ================= POPUP MODE =================
enum OpnamePopupMode { fromList, fromScan, addNew }

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

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value:
              context.read<StockOpnameDtlBloc>()..add(
                LoadStockOpnameDtl(trId: trId, millId: millId, whId: whId),
              ),
        ),
        BlocProvider.value(
          value: context.read<ProdMasterBloc>()..add(LoadProdMaster()),
        ),
      ],
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
  /// ================= LIST =================
  final TextEditingController _searchCtrl = TextEditingController();
  String? binId;
  String? batchId;

  /// ================= SCANNER =================
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

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
    return BlocListener<OpnameBloc, OpnameState>(
      listener: (context, state) {
        if (state is OpnameSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opname berhasil disimpan')),
          );

          // reload list
          context.read<StockOpnameDtlBloc>().add(
            LoadStockOpnameDtl(
              trId: widget.trId,
              millId: widget.millId,
              whId: widget.whId,
            ),
          );
        }

        if (state is OpnameError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
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
      child: BlocBuilder<StockOpnameDtlBloc, StockOpnameDtlState>(
        builder: (context, state) {
          if (state is! StockOpnameDtlLoaded) return const SizedBox();

          final bins = state.binBatchMap.keys.toList()..sort();
          final batches =
              binId == null ? <String>[] : state.binBatchMap[binId!]!.toList()
                ..sort();

          return Column(
            children: [
              SizedBox(
                height: 40,
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
                    border: border,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: binId,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'BIN',
                          labelStyle: TextStyle(fontSize: 12),
                          isDense: true,
                          border: border,
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
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: batchId,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Batch',
                          labelStyle: TextStyle(fontSize: 12),
                          isDense: true,
                          border: border,
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

    // if (mode == OpnamePopupMode.fromScan && scanResult != null) {
    //   prodCodeCtrl.text = scanResult['prod_code'] ?? '';
    //   batchCtrl.text = scanResult['batch_id'] ?? '';
    //   panjangCtrl.text = scanResult['panjang']?.toString() ?? '';
    //   qualityId.text = scanResult['quality_id'] ?? '';
    //   ordFlag = scanResult['ord_flag'] ?? 'N';
    // }

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
                _submitOpname();
                Navigator.pop(context);
                // mode == OpnamePopupMode.addNew
                //     ? _addOpname(qtyCtrl.text)
                //     : _updateOpname(qtyCtrl.text);
                // Navigator.pop(context);
              },
              child: Text(mode == OpnamePopupMode.addNew ? 'Tambah' : 'Update'),
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

        /// ================= SEARCH RESULT =================
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

        _readonlyCtrl('Product Code', prodCodeCtrl),
        _readonlyCtrl('Quality ID', qualityId),

        /// ================= ADD ID =================
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

        /// ================= TOR ID =================
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

        /// ================= INPUT LAIN =================
        _editable('Qty Opname*', qtyCtrl),
        _editableLong('Panjang', panjangCtrl),
        _editable('Batch', batchCtrl),
        _editable('Remark', remarkCtrl),

        const SizedBox(height: 8),
        _readonly('TR ID', widget.trId),
        _readonly('WH ID', widget.whId),
        _readonly('BIN ID', binId ?? '-'),
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
        millId: widget.millId,
        whId: widget.whId,
        binId: binId ?? '',
        trId: widget.trId,
        prodCode: prodCodeCtrl.text,
        addId: addId,
        torId: torId,
        panjang: panjangCtrl.text,
        batchId: batchCtrl.text,
        remark: remarkCtrl.text,
        qtyOpname: qtyCtrl.text,
        userId2: userId,
      ),
    );
  }

  /// ================= UPDATE FORM =================
  Widget _popupContent() {
    return Column(
      children: [
        _readonlyCtrl('Nama Barang', namaBarangCtrl),
        _readonlyCtrl('Product Code', prodCodeCtrl),
        _editable('Qty Opname*', qtyCtrl),
        _readonly('Quality ID', qualityId.text),
        _readonly('Add ID', addId),
        _readonly('Tor ID', torId),
        _editableLong('Panjang', panjangCtrl),
        _editable('Batch', batchCtrl),
        _editable('Remark', remarkCtrl),

        const SizedBox(height: 8),
        _readonly('TR ID', widget.trId),
        _readonly('WH ID', widget.whId),
        _readonly('BIN ID', binId ?? '-'),
      ],
    );
  }

  /// ================= FIELD HELPERS =================
  Widget _editable(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: TextField(
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
        height: 40,
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

  /// ================= API STUB =================
  void _updateOpname(String qty) {
    debugPrint('UPDATE $qty');
  }

  void _addOpname(String qty) {
    debugPrint('ADD $qty');
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
