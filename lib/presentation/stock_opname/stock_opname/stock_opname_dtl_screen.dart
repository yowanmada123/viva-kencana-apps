import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Timer? _debounce;

  String? binId;
  String? batchId;

  void _reload() {
    context.read<StockOpnameDtlBloc>().add(
      LoadStockOpnameDtl(
        trId: widget.trId,
        millId: widget.millId,
        whId: widget.whId,
        binId: binId,
        batchId: batchId,
        search: _searchCtrl.text.trim(),
      ),
    );
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _reload);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
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
                  return RefreshIndicator(
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      itemCount: state.data.length,
                      itemBuilder: (_, i) => _item(state.data[i]),
                    ),
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
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari Nama Barang',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'BIN'),
                  onChanged: (v) {
                    binId = v.isEmpty ? null : v;
                    _reload();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Batch'),
                  onChanged: (v) {
                    batchId = v.isEmpty ? null : v;
                    _reload();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= ITEM =================
  Widget _item(StockOpnameDtl e) {
    return ListTile(
      title: Text(
        e.namaBarang,
        style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${e.prodCode}, Panjang: ${e.panjang}",
        style: TextStyle(fontSize: 11.w),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Awal: ${e.qtyAwal}'), Text('Opn: ${e.qtyOpname}')],
      ),
    );
  }
}
