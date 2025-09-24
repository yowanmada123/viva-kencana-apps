import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import '../../models/sales_activity/sales_info.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_form_checkin_screen.dart';
import 'sales_activity_form_screen.dart';
import 'sales_activity_history_visit_screen.dart';

class SalesActivityDashboardScreen extends StatefulWidget {
  final SalesInfo sales;
  const SalesActivityDashboardScreen({
    super.key,
    required this.sales,
  });

  @override
  State<SalesActivityDashboardScreen> createState() =>
      _SalesActivityDashboardScreenState();
}

class _SalesActivityDashboardScreenState extends State<SalesActivityDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesActivityFormCheckInBloc>().add(LoadSalesData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Activity',
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
      body: Column(
        children: [
          BlocBuilder<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
            builder: (context, state) {
              if (state is SalesDataLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SalesDataSuccess) {
                final sales = state.sales;
                return Column(
                  children: [
                    buildCheckCard(time: sales.todayCheckin, isCheckin: true),
                    buildCheckCard(time: sales.todayCheckout, isCheckin: false),
                  ],
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Gagal memuat data sales, coba lagi"),
                      BasePrimaryButton(
                        onPressed: () {
                          context.read<SalesActivityFormCheckInBloc>().add(LoadSalesData());
                        },
                        label: "COba lagi",
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 32.w),
                child: BlocBuilder<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
                  builder: (context, state) {

                    if (state is SalesDataSuccess){
                      bool isCheckedIn = state.sales.todayCheckin.isNotEmpty;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: BasePrimaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesActivityFormCheckInScreen(
                                      sales: widget.sales,
                                      isCheckIn: true,
                                    ),
                                  ),
                                );
                              },
                              label: "Check In",
                            ),
                          ),
                          SizedBox(height: 4.w),
              
                          SizedBox(
                            width: double.infinity,
                            child: BasePrimaryButton(
                              onPressed: () {
                                if (!isCheckedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Anda belum check-in hari ini")),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesActivityFormCheckInScreen(
                                      sales: widget.sales,
                                    ),
                                  ),
                                );
                              },
                              label: "Check Out",
                            ),
                          ),
                          SizedBox(height: 4.w),
              
                          SizedBox(
                            width: double.infinity,
                            child: BasePrimaryButton(
                              onPressed: () {
                                if (!isCheckedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Anda belum check-in hari ini")),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesActivityFormScreen(
                                      sales: widget.sales,
                                    ),
                                  ),
                                );
                              },
                              label: "Customer Visit",
                            ),
                          ),
                          SizedBox(height: 4.w),

                          SizedBox(
                            width: double.infinity,
                            child: BasePrimaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SalesActivityHistoryVisitScreen(
                                      sales: widget.sales,
                                    ),
                                  ),
                                );
                              },
                              label: "History Visit",
                            ),
                          ),
                        ],
                      );
                    } else if (state is SalesDataLoading) {
                      return Center(child: const CircularProgressIndicator());
                    } else {
                      return Center(child: const Text("Gagal memuat data sales"));
                    }
                  },
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  Padding buildCheckCard({
    required String? time,
    required bool isCheckin,
  }) {
    DateTime? parsedTime;
    if (time != null) {
      try {
        parsedTime = DateFormat("HH:mm:ss dd-MM-yyyy").parse(time);
      } catch (_) {
        parsedTime = null;
      }
    }

    String formattedTime =
        parsedTime != null ? DateFormat("HH:mm").format(parsedTime) : "-";
    String formattedDate =
        parsedTime != null ? DateFormat("dd-MM-yyyy").format(parsedTime) : "-";

    final Color mainColor = isCheckin
        ? Colors.green.shade400
        : Colors.red.shade400;

    final String label = isCheckin ? "Last Checkin" : "Last Checkout";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.w, horizontal: 16.0.w),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 80.w,
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
                padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 8.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$formattedTime o'clock",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
