import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../bloc/sales_activity/history_visit/history_visit_detail/sales_activity_history_visit_detail_bloc.dart';
import '../../models/sales_activity/history_visit.dart';

class SalesActivityHistoryDetailScreen extends StatefulWidget {
  final HistoryVisit visit;
  const SalesActivityHistoryDetailScreen({
    super.key,
    required this.visit,
  });

  @override
  State<SalesActivityHistoryDetailScreen> createState() =>
      _SalesActivityHistoryDetailScreenState();
}

class _SalesActivityHistoryDetailScreenState extends State<SalesActivityHistoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesActivityHistoryVisitDetailBloc>().add(LoadHistoryDetail(widget.visit.trId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail - ${widget.visit.trId}',
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
        child: BlocBuilder<SalesActivityHistoryVisitDetailBloc, SalesActivityHistoryVisitDetailState>(
          builder: (context, state) {
            if (state is HistoryDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryDetailFailure) {
              return Center(
                child: Text(
                  "Gagal memuat detail: ${state.exception}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is HistoryDetailLoaded) {
              final details = state.details;
              if (details.isEmpty) {
                return const Center(child: Text("Tidak ada riwayat detail"));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.w, left: 4.w),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.visit.trDate)),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final d = details[index];
                        final Color mainColor = d.startEndPoint == 'OS'
                          ? Colors.green.shade400.withValues(alpha: 0.8)
                          : Colors.red.shade400.withValues(alpha: 0.8);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 4,
                          child: Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 110.w,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    bottomLeft: Radius.circular(12.r),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('hh:mm a').format(DateTime.parse(d.trDate)),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${d.customerName} - ${d.customerCity}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      Text(
                                        d.gpsAddress,
                                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Customer ID: ${d.customerId == "" ? "-" : d.customerId}",
                                        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Vehicle: ${d.salesVehicle}",
                                        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                      ),
                                      SizedBox(height: 4.w),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}