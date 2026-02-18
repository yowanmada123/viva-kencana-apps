import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_event.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_state.dart';
import 'package:vivakencanaapp/models/mill.dart';
import 'package:vivakencanaapp/presentation/stock_opname/stock_opname/stock_opname_dtl_screen.dart';
import 'package:vivakencanaapp/utils/datetime_convertion.dart';

class OpnameStockHdrScreen extends StatelessWidget {
  final Mill mill;
  const OpnameStockHdrScreen({super.key, required this.mill});

  @override
  Widget build(BuildContext context) {
    log('Access to lib/presentation/qr_code_opname/qr_code_opname_screen.dart');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value:
              context.read<OpnameStockHdrBloc>()
                ..add(LoadOpnameStockHdr(millId: mill.millID)),
        ),
      ],
      child: OpnameStockHdrView(mill: mill),
    );
  }
}

class OpnameStockHdrView extends StatefulWidget {
  final Mill mill;
  const OpnameStockHdrView({super.key, required this.mill});

  @override
  State<OpnameStockHdrView> createState() => _OpnameStockHdrViewState();
}

class _OpnameStockHdrViewState extends State<OpnameStockHdrView> {
  String? selectedWh;
  String? selectedBin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Opname Stock",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: BlocBuilder<OpnameStockHdrBloc, OpnameStockHdrState>(
            builder: (context, state) {
              /// 🔄 LOADING
              if (state is OpnameStockHdrLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              /// ❌ ERROR
              if (state is OpnameStockHdrError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OpnameStockHdrBloc>().add(
                          LoadOpnameStockHdr(millId: widget.mill.millID),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              /// ✅ SUCCESS
              if (state is OpnameStockHdrLoaded) {
                final data = state.data;

                if (data.isEmpty) {
                  return const Center(
                    child: Text('Data opname tidak tersedia'),
                  );
                }

                final whList = data.map((e) => e.whId).toSet().toList();
                // final binList = data.map((e) => e.binId).toSet().toList();

                final filteredData =
                    data.where((e) {
                      final whMatch =
                          selectedWh == null || e.whId == selectedWh;
                      final binMatch = selectedBin == null;
                      return whMatch && binMatch;
                    }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 HEADER
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icon(
                              //   Icons.table_chart,
                              //   size: 18,
                              //   color: Colors.grey.shade700,
                              // ),
                              // const SizedBox(width: 8),
                              Text(
                                'Stock Opname List',
                                style: TextStyle(
                                  fontSize: 16.w,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.cabin,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.mill.millName,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 SUMMARY CARD
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryItem(
                                label: 'Total Data',
                                value: data.length.toString(),
                                icon: Icons.list_alt,
                              ),
                              _summaryItem(
                                label: 'Warehouse',
                                value: whList.length.toString(),
                                icon: Icons.warehouse,
                              ),
                              // _summaryItem(
                              //   label: 'Bin',
                              //   value: binList.length.toString(),
                              //   icon: Icons.inventory_2,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 SECTION TITLE
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          'Opname Data',
                          style: TextStyle(
                            fontSize: 13.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 TABLE (NO SELECT)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          horizontalMargin: 0,
                          headingRowHeight: 36,
                          // dataRowHeight: 40,
                          columnSpacing: 10,
                          columns: [
                            _header('Category'),

                            _header('WH'),

                            // _header('BIN'),
                            _header('TR ID'),
                            _header('Open Date'),
                            // _header('Prod'),
                            // _header('Batch'),
                            _header('Action'),

                            // _header('Qty Awal'),
                            // _header('Qty Opname'),
                          ],
                          rows:
                              filteredData.map((e) {
                                return DataRow(
                                  cells: [
                                    _cell(e.catDesc),
                                    _cell(e.whId),

                                    // _cell(e.binId),
                                    _cell(e.trId),
                                    _cell(
                                      e.trDate != null
                                          ? formatDateDMY(e.trDate)
                                          : '',
                                    ),
                                    // _cell(e.prodCode),
                                    // _cell(e.batchId),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          // print(e);
                                          // NAVIGATE TO DTL
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => OpnameStockDtlScreen(
                                                    trId: e.trId,
                                                    millId: e.millId,
                                                    whId: e.whId,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // _cell(e.qtyAwal.toStringAsFixed(2)),
                                    // _cell(e.qtyOpname.toStringAsFixed(2)),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 10.w, color: Colors.grey)),
      ],
    );
  }

  DataColumn _header(String text) {
    return DataColumn(
      label: Text(
        text,
        style: TextStyle(fontSize: 11.w, fontWeight: FontWeight.w600),
      ),
    );
  }

  DataCell _cell(String text) {
    return DataCell(Text(text, style: TextStyle(fontSize: 11.w)));
  }
}
