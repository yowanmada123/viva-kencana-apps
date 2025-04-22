import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/delivery_detail/delivery_detail_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/batch_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../widgets/base_pop_up.dart';

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Logout Not Success")));
                } else if (state is LogoutSuccess) {
                  BlocProvider.of<AuthenticationBloc>(
                    context,
                  ).add(SetAuthenticationStatus(isAuthenticated: false));
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    showDialog<bool>(
                      context: context,
                      builder: (BuildContext childContext) {
                        return BasePopUpDialog(
                          noText: "Tidak",
                          yesText: "Ya",
                          onNoPressed: () {},
                          onYesPressed: () {
                            if (state is! LogoutLoading) {
                              context.read<LogoutBloc>().add(LogoutPressed());
                            }
                          },
                          question:
                              "Apakah Anda yakin ingin keluar dari aplikasi?",
                        );
                      },
                    );
                  },
                  child: Icon(Icons.logout, color: Colors.white),
                );
              },
            ),
          ),
        ],
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
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Company ID : ${widget.companyID}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
                                    size: 15,
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
                                    fontSize: 18,
                                    color: Color(0xff575353),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                    size: 15,
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
                                    fontSize: 18,
                                    color: Color(0xff575353),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xff8AC8FA),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      blurRadius: 5,
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
                                              fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(6.0),
                                            child: Text(
                                              widget.batchID,
                                              style: TextStyle(
                                                letterSpacing: 6,
                                                fontSize: 18,
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
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Cancel Load",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .green, // Warna latar belakang tombol
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // Mengatur radius sudut
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Confirm Load",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       "List Barang",
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontFamily: "Poppins",
                            //         fontWeight: FontWeight.w700,
                            //       ),
                            //     ),
                            //     SizedBox(width: 8.0),
                            //     Expanded(
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(10),
                            //           boxShadow: [
                            //             BoxShadow(
                            //               color: Colors.grey.withValues(
                            //                 alpha: 0.2,
                            //               ),
                            //               blurRadius: 5,
                            //               offset: Offset(0, 2),
                            //             ),
                            //           ],
                            //         ),
                            //         height: 40,
                            //         child: TextField(
                            //           style:
                            //               Theme.of(
                            //                 context,
                            //               ).textTheme.labelSmall,
                            //           decoration: InputDecoration(
                            //             labelText: 'Search',
                            //             labelStyle:
                            //                 Theme.of(
                            //                   context,
                            //                 ).textTheme.labelSmall,
                            //             hintStyle:
                            //                 Theme.of(
                            //                   context,
                            //                 ).textTheme.labelSmall,
                            //             prefixStyle:
                            //                 Theme.of(
                            //                   context,
                            //                 ).textTheme.labelSmall,
                            //             suffixStyle:
                            //                 Theme.of(
                            //                   context,
                            //                 ).textTheme.labelSmall,
                            //             prefixIcon: Icon(Icons.search),
                            //             border: InputBorder.none,
                            //             contentPadding: EdgeInsets.symmetric(),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     SizedBox(width: 8),
                            //   ],
                            // ),
                            // SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ]),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    sliver: SliverToBoxAdapter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            state
                                .deliveryDetail
                                .length, // Jumlah item dalam list
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column for Order Description and ID
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Order ID: ${state.deliveryDetail[index].orderID}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Delivery ID: ${state.deliveryDetail[index].delivID}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Tr Type: ${state.deliveryDetail[index].trType}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Order ID: ${state.deliveryDetail[index].orderID}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Qty Ship: ${state.deliveryDetail[index].qtyShip}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "Deskripsi: ${state.deliveryDetail[index].descr}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Right Column for Action Buttons
                                  // Column(
                                  //   children: [
                                  //     IconButton(
                                  //       icon: Icon(
                                  //         Icons.edit,
                                  //         color: Colors.blue,
                                  //       ),
                                  //       onPressed: () {},
                                  //     ),
                                  //     IconButton(
                                  //       icon: Icon(
                                  //         Icons.delete,
                                  //         color: Colors.red,
                                  //       ),
                                  //       onPressed: () {},
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          );

                          // ListTile(
                          //   title: Text(
                          //     state.deliveryDetail[index].descr,
                          //   ), // Menampilkan item
                          //   onTap: () {
                          //     // Tindakan yang akan dilakukan ketika item dipilih
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(content: Text('You tapped on1')),
                          //     );
                          //   },
                          // );
                        },
                      ),
                    ),
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

// 'BlocBuilder<ListVehicleBloc, ListVehicleState>(
//                   builder: (context, state) {
//                     if (state is ListVehicleLoading) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (state is ListVehicleLoadSuccess ||
//                         state is ListVehicleLoadFailure) {
//                       return GridView.builder(
//                         padding: EdgeInsets.zero,
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10.0,
//                           mainAxisSpacing: 10.0,
//                           childAspectRatio: 0.80,
//                         ),
//                         itemCount: state.vehicles.length,
//                         itemBuilder: (context, index) {
//                           return BuildGridItem(vehicle: state.vehicles[index]);
//                         },
//                       );
//                     }
//                     return Container();
//                   },
//                 ),'
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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
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
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 2),
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
        final authState =
            context.read<AuthenticationBloc>().state as Authenticated;
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  Text(
                    getStatusVehicle(vehicle),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(width: 5),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: getStatusColor(vehicle),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SvgPicture.asset(
                getImagePath(vehicle),
                width: 80,
                height: 70,
              ),
            ),
            Positioned(
              bottom: 15,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Text(
                    vehicle.vehicleID,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  SizedBox(height: 5),
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
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: Colors.white, size: 24),
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
