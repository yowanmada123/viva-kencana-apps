import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/cancel_load/cancel_load_bloc.dart';
import '../../bloc/confirm_load/confirm_load_bloc.dart';
import '../../bloc/delivery_detail/delivery_detail_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/batch_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../qr_code/qr_code_screen.dart';

class WareHouseContentListScreen extends StatelessWidget {
  const WareHouseContentListScreen({
    super.key,
    required this.batchID,
    required this.companyID,
    required this.millID,
    required this.whID,
  });

  final String batchID;
  final String companyID;
  final String millID;
  final String whID;

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final batchRepository = context.read<BatchRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => DeliveryDetailBloc(batchRepository: batchRepository),
        ),
        BlocProvider(
          create:
              (context) => ConfirmLoadBloc(batchRepository: batchRepository),
        ),
        BlocProvider(
          create: (context) => CancelLoadBloc(batchRepository: batchRepository),
        ),
        BlocProvider(create: (context) => LogoutBloc(authRepository)),
      ],
      child: WareHouseContentListView(
        batchID: batchID,
        companyID: companyID,
        millID: millID,
        whID: whID,
      ),
    );
  }
}

class WareHouseContentListView extends StatefulWidget {
  const WareHouseContentListView({
    super.key,
    required this.batchID,
    required this.companyID,
    required this.millID,
    required this.whID,
  });

  final String batchID;
  final String companyID;
  final String millID;
  final String whID;

  @override
  State<WareHouseContentListView> createState() => _WareHouseContentListState();
}

class _WareHouseContentListState extends State<WareHouseContentListView> {
  Timer? _timer;
  late final User user;

  @override
  void initState() {
    context.read<DeliveryDetailBloc>().add(
      LoadDeliveryDetail(
        batchID: widget.batchID,
        companyID: widget.companyID,
        millID: widget.millID,
        whID: widget.whID,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Detail',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Ganti warna tombol back menjadi hijau
        ),

        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).hintColor,
      body: SafeArea(
        child: BlocConsumer<DeliveryDetailBloc, DeliveryDetailState>(
          listener: (context, state) {
            if (state is DeliveryDetailFailure) {
              if (state.exception is UnauthorizedException) {
                context.read<AuthenticationBloc>().add(
                  SetAuthenticationStatus(isAuthenticated: false),
                );
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
            if (state is DeliveryDetailLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is DeliveryDetailFailure) {
              return Center(child: Text("Unknown error"));
            } else if (state is DeliveryDetailSuccess) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.w,
                          horizontal: 8.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Company ID : ${widget.companyID}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.w,
                                    color: Color(0xff575353),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: widget.companyID),
                                    ).then((_) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "companyID copied to clipboard",
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: Theme.of(context).disabledColor,
                                    size: 15.w,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Mill ID : ${widget.millID}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.w,
                                    color: Color(0xff575353),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: widget.millID),
                                    ).then((_) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "millID copied to clipboard",
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: Theme.of(context).disabledColor,
                                    size: 15.w,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Warehouse ID : ${widget.whID}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.w,
                                    color: Color(0xff575353),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: widget.whID),
                                    ).then((_) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "whID copied to clipboard",
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: Theme.of(context).disabledColor,
                                    size: 15.w,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.w),
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: BoxDecoration(
                                  color: Color(0xff8AC8FA),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(
                                        alpha: 0.3.w,
                                      ),
                                      blurRadius: 5.w,
                                      offset: Offset(0, 2),
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
                                            "Batch ID",
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
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: widget.batchID),
                                          ).then((_) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Batch ID copied to clipboard",
                                                ),
                                              ),
                                            );
                                          });
                                        },
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
                          ],
                        ),
                      ),
                    ]),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children:
                            state.groupedItems.keys.map((key) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Order ID:  ",
                                      style: TextStyle(
                                        fontSize: 8.w,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          key,
                                          style: TextStyle(
                                            fontSize: 16.w,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () async {
                                            await Clipboard.setData(
                                              ClipboardData(text: key),
                                            ).then((_) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Order ID copied to clipboard",
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            color: Colors.black,
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  for (var item
                                      in state.groupedItems[key]!) ...[
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.w,
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(16.w),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Left Column for Order Description and ID
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Delivery ID",
                                                            style: TextStyle(
                                                              fontSize: 8.w,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                item.delivID,
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      12.w,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5.w,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  await Clipboard.setData(
                                                                    ClipboardData(
                                                                      text:
                                                                          item.delivID,
                                                                    ),
                                                                  ).then((_) {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                              "Delivery ID copied to clipboard",
                                                                            ),
                                                                      ),
                                                                    );
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  Icons.copy,
                                                                  color:
                                                                      const Color.fromARGB(
                                                                        255,
                                                                        66,
                                                                        66,
                                                                        66,
                                                                      ),
                                                                  size: 12.w,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Icon(
                                                        Icons.security,
                                                        size: 18.w,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    item.descr,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.w),
                                                  Text(
                                                    "Quantity : ${item.qtyShip} pcs",
                                                    style: TextStyle(
                                                      fontSize: 12.w,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.w),
                                                  Text(
                                                    "Length: ${double.parse(item.lengthShip).toStringAsFixed(2)} m",
                                                    style: TextStyle(
                                                      fontSize: 12.w,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                  ],
                                ],
                              );
                            }).toList(),
                      ),

                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   physics: NeverScrollableScrollPhysics(),
                      //   // itemCount: state.deliveryDetail.length,
                      //   itemCount: state.deliveryDetail.length,
                      //   itemBuilder: (context, index) {
                      //     return Card(
                      //       elevation: 5,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(15.w),
                      //       ),
                      //       child: Container(
                      //         padding: EdgeInsets.all(16.w),
                      //         child: Row(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             // Left Column for Order Description and ID
                      //             Expanded(
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.spaceBetween,
                      //                     children: [
                      //                       Column(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment.start,
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         children: [
                      //                           Text(
                      //                             "Order ID:",
                      //                             style: TextStyle(
                      //                               fontSize: 8.w,
                      //                               fontWeight: FontWeight.bold,
                      //                             ),
                      //                           ),
                      //                           Row(
                      //                             children: [
                      //                               Text(
                      //                                 state
                      //                                     .deliveryDetail[index]
                      //                                     .orderID,
                      //                                 style: TextStyle(
                      //                                   fontSize: 14.w,
                      //                                   fontWeight:
                      //                                       FontWeight.w400,
                      //                                 ),
                      //                               ),
                      //                               const SizedBox(width: 5),
                      //                               GestureDetector(
                      //                                 onTap: () async {
                      //                                   await Clipboard.setData(
                      //                                     ClipboardData(
                      //                                       text:
                      //                                           state
                      //                                               .deliveryDetail[index]
                      //                                               .orderID,
                      //                                     ),
                      //                                   ).then((_) {
                      //                                     ScaffoldMessenger.of(
                      //                                       context,
                      //                                     ).showSnackBar(
                      //                                       SnackBar(
                      //                                         content: Text(
                      //                                           "Order ID copied to clipboard",
                      //                                         ),
                      //                                       ),
                      //                                     );
                      //                                   });
                      //                                 },
                      //                                 child: Icon(
                      //                                   Icons.copy,
                      //                                   color: Colors.black,
                      //                                   size: 12,
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       Column(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment.start,
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         children: [
                      //                           Text(
                      //                             "Delivery ID",
                      //                             style: TextStyle(
                      //                               fontSize: 8.w,
                      //                             ),
                      //                           ),
                      //                           Row(
                      //                             children: [
                      //                               Text(
                      //                                 state
                      //                                     .deliveryDetail[index]
                      //                                     .delivID,
                      //                                 style: TextStyle(
                      //                                   fontSize: 12.w,
                      //                                   fontWeight:
                      //                                       FontWeight.w400,
                      //                                 ),
                      //                               ),
                      //                               SizedBox(width: 5.w),
                      //                               GestureDetector(
                      //                                 onTap: () async {
                      //                                   await Clipboard.setData(
                      //                                     ClipboardData(
                      //                                       text:
                      //                                           state
                      //                                               .deliveryDetail[index]
                      //                                               .delivID,
                      //                                     ),
                      //                                   ).then((_) {
                      //                                     ScaffoldMessenger.of(
                      //                                       context,
                      //                                     ).showSnackBar(
                      //                                       SnackBar(
                      //                                         content: Text(
                      //                                           "Delivery ID copied to clipboard",
                      //                                         ),
                      //                                       ),
                      //                                     );
                      //                                   });
                      //                                 },
                      //                                 child: Icon(
                      //                                   Icons.copy,
                      //                                   color:
                      //                                       const Color.fromARGB(
                      //                                         255,
                      //                                         66,
                      //                                         66,
                      //                                         66,
                      //                                       ),
                      //                                   size: 12.w,
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       Icon(Icons.security, size: 18.w),
                      //                     ],
                      //                   ),
                      //                   SizedBox(height: 2),

                      //                   SizedBox(height: 2),
                      //                   Text(
                      //                     state.deliveryDetail[index].descr,
                      //                     style: TextStyle(
                      //                       fontSize: 14,
                      //                       fontWeight: FontWeight.w500,
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 2.w),
                      //                   Text(
                      //                     "Quantity : ${state.deliveryDetail[index].qtyShip} pcs",
                      //                     style: TextStyle(fontSize: 12.w),
                      //                   ),
                      //                   SizedBox(height: 2.w),
                      //                   Text(
                      //                     "Length: ${double.parse(state.deliveryDetail[index].lengthShip).toStringAsFixed(2)} m",
                      //                     style: TextStyle(fontSize: 12.w),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.isConfirmed) ...[
                              BlocConsumer<CancelLoadBloc, CancelLoadState>(
                                listener: (context, state) {
                                  if (state is CancelLoadError) {
                                    if (state.message != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(state.message!)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Terjadi kesalahan, coba beberapa saat lagi",
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (state is CancelLoadSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Cancel Load Success"),
                                      ),
                                    );
                                    context.read<DeliveryDetailBloc>().add(
                                      LoadDeliveryDetail(
                                        batchID: widget.batchID,
                                        companyID: widget.companyID,
                                        millID: widget.millID,
                                        whID: widget.whID,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Container(
                                    height: 35.w,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        if (state is! CancelLoadLoading) {
                                          context.read<CancelLoadBloc>().add(
                                            CancelLoadSubmitted(
                                              batchID: widget.batchID,
                                              companyID: widget.companyID,
                                              millID: widget.millID,
                                              whID: widget.whID,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "Cancel Load",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ] else if (!state.isConfirmed) ...[
                              Container(
                                width: double.infinity,
                                height: 35.w,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: BlocConsumer<
                                  ConfirmLoadBloc,
                                  ConfirmLoadState
                                >(
                                  listener: (context, state) {
                                    if (state is ConfirmLoadError) {
                                      if (state.message != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(state.message!),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Terjadi kesalahan, coba beberapa saat lagi",
                                            ),
                                          ),
                                        );
                                      }
                                    } else if (state is ConfirmLoadSuccess) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("Confirm Load Success"),
                                        ),
                                      );
                                      Navigator.of(context).popUntil(
                                        ModalRoute.withName(
                                          QrCodeScreen.routeName,
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return TextButton(
                                      onPressed: () {
                                        if (state is! ConfirmLoadLoading) {
                                          context.read<ConfirmLoadBloc>().add(
                                            ConfirmLoadSubmitted(
                                              batchID: widget.batchID,
                                              companyID: widget.companyID,
                                              millID: widget.millID,
                                              whID: widget.whID,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "Confirm Load",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            SizedBox(height: 8.w),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}

String getImagePath(Vehicle vehicle) {
  if (!vehicle.isBanned) {
    if (vehicle.isDelivery) {
      return 'assets/svg/otw.svg';
    } else if (vehicle.isIdle) {
      return 'assets/svg/iddle.svg';
    } else if (vehicle.isLoading) {
      return 'assets/svg/load.svg';
    } else if (vehicle.isReady) {
      return 'assets/svg/ready.svg';
    } else {
      return 'assets/svg/na.svg';
    }
  } else {
    return 'assets/svg/ban.svg';
  }
}

String getStatusVehicle(Vehicle vehicle) {
  if (!vehicle.isBanned) {
    if (vehicle.isDelivery) {
      return 'Kirim';
    } else if (vehicle.isIdle) {
      return 'Tersedia';
    } else if (vehicle.isLoading) {
      return 'Muat';
    } else if (vehicle.isReady) {
      return 'Siap';
    } else {
      return "-";
    }
  } else {
    return 'Blokir';
  }
}

Color getStatusColor(Vehicle vehicle) {
  if (!vehicle.isBanned) {
    if (vehicle.isDelivery) {
      return Color(0xff1700E5);
    } else if (vehicle.isIdle) {
      return Color(0xffD9D9D9);
    } else if (vehicle.isLoading) {
      return Color(0xffFFD301);
    } else if (vehicle.isReady) {
      return Color(0xff66ED12);
    } else {
      return Color.fromARGB(255, 88, 88, 88);
    }
  } else {
    return Color(0xffFF0000);
  }
}

class BuildSection extends StatelessWidget {
  final String title;
  final Color color;
  final int value;

  const BuildSection({
    super.key,
    required this.title,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.w),
          ),
        ),
        SizedBox(width: 5),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 10.w,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class BuildGridItem extends StatelessWidget {
  final Vehicle vehicle;

  const BuildGridItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!vehicle.isBanned) {
          // final listVehicleBloc = context.read<ListVehicleBloc>();
          final reload = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              // final ExpeditionRepository expeditionRepository = context.read();
              return MultiBlocProvider(
                providers: [
                  // BlocProvider(
                  //   create:
                  //       (context) => UpdateVehicleStatusBloc(
                  //         expeditionRepository: expeditionRepository,
                  //       ),
                  // ),
                  // BlocProvider.value(value: listVehicleBloc),
                ],
                child: ConfirmationDialog(vehicle: vehicle),
              );
            },
          );

          if (reload != null) {
            if (reload) {
              // context.read<ListVehicleBloc>().add(
              //   LoadListVehicle(userId: authState.user.userID),
              // );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Update Success")));
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Update Gagal")));
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3.w),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10.w,
              right: 10.w,
              child: Row(
                children: [
                  Text(
                    getStatusVehicle(vehicle),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(width: 5.w),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: getStatusColor(vehicle),
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SvgPicture.asset(
                getImagePath(vehicle),
                width: 80.w,
                height: 70.w,
              ),
            ),
            Positioned(
              bottom: 15.w,
              left: 10.w,
              right: 10.w,
              child: Column(
                children: [
                  Text(
                    vehicle.vehicleID,
                    style: TextStyle(color: Colors.black, fontSize: 14.w),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    // vehicle.driverName.isEmpty ? "" : vehicle.driverName,
                    vehicle.expDescr,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10.w,
              right: 10.w,
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: Colors.white, size: 24.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final Vehicle vehicle;

  const ConfirmationDialog({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    String message = "";
    if (!vehicle.isBanned && vehicle.isIdle) {
      message =
          "Apakah Anda ingin mengaktifkan kendaraan dengan pengemudi ${vehicle.expDescr}, plat nomor ${vehicle.vehicleID}";
    } else {
      message =
          "Kendaraan dengan pengemudi ${vehicle.expDescr}, plat nomor ${vehicle.vehicleID}";
    }
    return AlertDialog(
      title: Text(
        (!vehicle.isBanned)
            ? (vehicle.isIdle)
                ? 'Konfirmasi'
                : 'Informasi'
            : 'Informasi',
      ),
      content: Text(message, style: Theme.of(context).textTheme.labelMedium),
      actions: <Widget>[
        if (!vehicle.isBanned) ...[
          if (vehicle.isIdle) ...[
            TextButton(
              child: Text(
                "Tidak",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            // BlocConsumer<UpdateVehicleStatusBloc, UpdateVehicleStatusState>(
            //   listener: (context, state) {
            //     if (state is UpdateVehicleStatusSuccess) {
            //       Navigator.of(context).pop(true);
            //     } else if (state is UpdateVehicleStatusFailure) {
            //       Navigator.of(context).pop(false);
            //     }
            //   },
            //   builder: (context, state) {
            //     if (state is UpdateVehicleStatusLoading) {
            //       return CircularProgressIndicator(
            //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //       );
            //     } else {
            //       return TextButton(
            //         child: Text(
            //           "Ya",
            //           style: TextStyle(
            //             fontFamily: "Poppins",
            //             fontSize: 12,
            //             color: Theme.of(context).primaryColor,
            //           ),
            //         ),
            //         onPressed: () {
            //           context.read<UpdateVehicleStatusBloc>().add(
            //             UpdateVehicleToReady(vehicleID: vehicle.vehicleID),
            //           );
            //         },
            //       );
            //     }
            //   },
            // ),
          ],
        ],
      ],
    );
  }
}
