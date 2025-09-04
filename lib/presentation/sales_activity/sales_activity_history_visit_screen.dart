import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../bloc/sales_activity/history_visit/sales_activity_history_visit_bloc.dart';
import '../../models/sales_activity/sales_info.dart';
import 'sales_activity_history_detail_screen.dart';

class SalesActivityHistoryVisitScreen extends StatefulWidget {
  final SalesInfo sales;
  const SalesActivityHistoryVisitScreen({
    super.key,
    required this.sales,
  });

  @override
  State<SalesActivityHistoryVisitScreen> createState() =>
      _SalesActivityHistoryVisitScreenState();
}

class _SalesActivityHistoryVisitScreenState extends State<SalesActivityHistoryVisitScreen> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    startDateController = TextEditingController(text: _formatDate(today));
    endDateController = TextEditingController(text: _formatDate(today));

    context.read<SalesActivityHistoryVisitBloc>().add(
          LoadHistoryVisit(startDate: today.toString(), endDate: today.toString()),
        );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Future<void> _pickDate(TextEditingController controller, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year, 12, 31),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);

      context.read<SalesActivityHistoryVisitBloc>().add(
            LoadHistoryVisit(
              startDate: DateTime.parse(startDateController.text.split("/").reversed.join("-")).toString(),
              endDate: DateTime.parse(endDateController.text.split("/").reversed.join("-")).toString(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Visit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Start Date"),
                    onTap: () => _pickDate(startDateController, true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "End Date"),
                    onTap: () => _pickDate(endDateController, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            Expanded(
              child: BlocBuilder<SalesActivityHistoryVisitBloc, SalesActivityHistoryVisitState>(
                builder: (context, state) {
                  if (state is HistoryVisitLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HistoryVisitLoaded) {
                    if (state.visits.isEmpty) {
                      return const Center(child: Text("Tidak ada riwayat kunjungan"));
                    }
                    return ListView.builder(
                      itemCount: state.visits.length,
                      itemBuilder: (context, index) {
                        final visit = state.visits[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalesActivityHistoryDetailScreen(visit: visit),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.w),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${visit.entityId} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(visit.trDate))}",
                                    style: TextStyle(
                                      fontSize: 16.w,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.w),
                                  Text("Tr ID: ${visit.trId}"),
                                  Text("Sales ID: ${visit.salesId}"),
                                  Text("User ID: ${visit.userId2}"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is HistoryVisitFailure) {
                    return Center(child: Text("Gagal memuat data: ${state.exception}"));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}