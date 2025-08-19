import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';

import '../widgets/base_primary_button.dart';
import 'sales_activity_form_checkin_screen.dart';
import 'sales_activity_form_screen.dart';

class SalesActivityDashboardScreen extends StatefulWidget {
  final String salesId;
  final String officeId;
  const SalesActivityDashboardScreen({
    super.key,
    required this.salesId,
    required this.officeId,
  });

  @override
  State<SalesActivityDashboardScreen> createState() =>
      _SalesActivityDashboardScreenState();
}

class _SalesActivityDashboardScreenState extends State<SalesActivityDashboardScreen> {

  @override
  void initState() {
    super.initState();
    context.read<SalesActivityFormCheckInBloc>().add(LoadCheckinStatus());
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
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
          child: BlocBuilder<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
            builder: (context, state) {
              bool isCheckedIn = false;

              if (state is CheckinLoaded) {
                isCheckedIn = state.isCheckedIn;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: BasePrimaryButton(
                      onPressed: isCheckedIn
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SalesActivityFormCheckInScreen(
                                    salesId: widget.salesId,
                                    officeId: widget.officeId,
                                  ),
                                ),
                              );
                            },
                      label: "Check In",
                    ),
                  ),
                  const SizedBox(height: 16),

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
                              salesId: widget.salesId,
                              officeId: widget.officeId,
                            ),
                          ),
                        );
                      },
                      label: "Check Out",
                    ),
                  ),
                  const SizedBox(height: 16),

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
                              salesId: widget.salesId,
                              officeId: widget.officeId,
                            ),
                          ),
                        );
                      },
                      label: "Customer Visit",
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ),
    );
  }
}
