import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/batch/batch_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../models/errors/custom_exception.dart';

import '../../data/repository/batch_repository.dart';

import 'warehouse_content_list_screen.dart';

class WarehouseSelectScreen extends StatelessWidget {
  const WarehouseSelectScreen({super.key, required this.batchID});
  final String batchID;

  @override
  Widget build(BuildContext context) {
    // final warehouseRepository = context.read<WarehouseRepository>();
    final batchRepository = context.read<BatchRepository>();
    final authRepository = context.read<AuthRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BatchBloc(batchRepository: batchRepository),
        ),
        BlocProvider(create: (context) => LogoutBloc(authRepository)),
      ],
      child: WarehouseSelectView(batchID: batchID),
    );
  }
}

class WarehouseSelectView extends StatefulWidget {
  const WarehouseSelectView({super.key, required this.batchID});
  final String batchID;

  @override
  State<WarehouseSelectView> createState() => _WarehouseSelectViewState();
}

class _WarehouseSelectViewState extends State<WarehouseSelectView> {
  @override
  void initState() {
    // final authState = context.read<AuthenticationBloc>().state as Authenticated;
    // user = authState.user;
    context.read<BatchBloc>().add(LoadBatch(deliveryId: widget.batchID));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List Warehouse',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Ganti warna tombol back menjadi hijau
        ),

        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).hintColor,
      body: SafeArea(
        child: BlocConsumer<BatchBloc, BatchState>(
          listener: (context, state) {
            if (state is BatchFailure) {
              if (state.exception is UnauthorizedException) {
                context.read<AuthenticationBloc>().add(
                  SetAuthenticationStatus(isAuthenticated: false),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Unknown error, please contact admin"),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is BatchLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BatchFailure) {
              return Center(child: Text("Unknown error"));
            } else if (state is BatchSuccess) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).hintColor,
                                    size: 40.w,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.batch.driverID,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.w,
                                          color: Color(0xff575353),
                                        ),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 24.w,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            state.batch.vehicleID,
                                            style: TextStyle(
                                              fontSize: 16.w,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.w),
                                decoration: BoxDecoration(
                                  color: Color(0xff8AC8FA),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(
                                        alpha: 0.3.w,
                                      ),
                                      blurRadius: 5.w,
                                      offset: Offset(0, 2.w),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Delivery Order",
                                            style: TextStyle(
                                              fontSize: 12.w,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(6.w),
                                            child: Text(
                                              widget.batchID,
                                              style: TextStyle(
                                                letterSpacing: 6.w,
                                                fontSize: 18.w,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 16.w),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.copy,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8.w),
                            Text(
                              "Silahkan Pilih Gudang",
                              style: TextStyle(
                                fontSize: 16.w,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    sliver: SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.batch.warehouses.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: Colors.black,
                                ),
                              ),
                              minLeadingWidth: 0,
                              title: Text(
                                "${state.batch.warehouses[index].millID} - ${state.batch.warehouses[index].companyID}",
                                style: TextStyle(
                                  fontSize: 14.w,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                state.batch.warehouses[index].descr,
                                style: TextStyle(
                                  fontSize: 12.w,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Start Load ?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          "Jika anda menekan Ya maka waktu Load akan mulai berjalan.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Tidak"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text(
                                              "Ya",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                WareHouseContentListScreen(
                                                  batchID: widget.batchID,
                                                  companyID:
                                                      state
                                                          .batch
                                                          .warehouses[index]
                                                          .companyID,
                                                  millID:
                                                      state
                                                          .batch
                                                          .warehouses[index]
                                                          .millID,
                                                  whID:
                                                      state
                                                          .batch
                                                          .warehouses[index]
                                                          .whID,
                                                ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 4.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    22,
                                    218,
                                    48,
                                  ),
                                ),
                                child: Text(
                                  'Start Loading',
                                  style: TextStyle(
                                    fontSize: 12.w,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
