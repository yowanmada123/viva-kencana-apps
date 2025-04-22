import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/data/repository/batch_repository.dart';
import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/batch/batch_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../widgets/base_pop_up.dart';
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutFailure) {
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
                } else if (state is LogoutSuccess) {
                  BlocProvider.of<AuthenticationBloc>(
                    context,
                  ).add(SetAuthenticationStatus(isAuthenticated: false));
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                        padding: EdgeInsets.all(8.0),
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
                                    size: 40,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.batch.driverID,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xff575353),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 24,
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          state.batch.vehicleID,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                            "Delivery Order",
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
                            SizedBox(height: 8.0),
                            Text(
                              "Silahkan Pilih Gudang",
                              style: TextStyle(
                                fontSize: 16,
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
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              minLeadingWidth: 0,
                              title: Text(
                                state.batch.warehouses[index].whID,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                state.batch.warehouses[index].descr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  final id = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              WareHouseContentListScreen(
                                                batchID: widget.batchID,
                                                companyID:
                                                    state.batch.companyID,
                                                millID: state.batch.millID,
                                                whID:
                                                    state
                                                        .batch
                                                        .warehouses[index]
                                                        .whID,
                                              ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: Text(
                                  'Pilih',
                                  style: TextStyle(
                                    fontSize: 12,
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

                  // SliverPadding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //   sliver: SliverToBoxAdapter(
                  //     child: BlocBuilder<ListWarehouseBloc, ListWarehouseState>(
                  //       builder: (context, state) {
                  //         if (state is ListWarehouseLoading) {
                  //           return Center(child: CircularProgressIndicator());
                  //         } else if (state is ListWarehouseFailure) {
                  //           return Center(child: Text("Error: ${state.message}"));
                  //         } else if (state is ListWarehouseSuccess) {
                  //           return ListView.builder(
                  //             shrinkWrap: true,
                  //             physics: NeverScrollableScrollPhysics(),
                  //             itemCount:
                  //                 state.warehouses.length, // Jumlah item dalam list
                  //             itemBuilder: (context, index) {
                  //               return Card(
                  //                 child: ListTile(
                  //                   leading: FlutterLogo(),
                  //                   title: Text(
                  //                     state.warehouses[index].whID,
                  //                     style: TextStyle(
                  //                       fontSize: 12,
                  //                       color: Colors.black,
                  //                     ),
                  //                   ),
                  //                   trailing: ElevatedButton(
                  //                     onPressed: () {
                  //                       final id = Navigator.push(
                  //                         context,
                  //                         MaterialPageRoute(
                  //                           builder:
                  //                               (context) =>
                  //                                   const WareHouseContentListScreen(),
                  //                         ),
                  //                       );
                  //                     },
                  //                     style: ElevatedButton.styleFrom(
                  //                       padding: EdgeInsets.symmetric(
                  //                         horizontal: 24,
                  //                         vertical: 8,
                  //                       ),
                  //                       shape: RoundedRectangleBorder(
                  //                         borderRadius: BorderRadius.circular(8),
                  //                       ),
                  //                       backgroundColor:
                  //                           Theme.of(context).primaryColor,
                  //                     ),
                  //                     child: Text(
                  //                       'Pilih',
                  //                       style: TextStyle(
                  //                         fontSize: 12,
                  //                         fontWeight: FontWeight.bold,
                  //                         color: Colors.white,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //           );
                  //         }
                  //         return Container();
                  //       },
                  //     ),
                  //   ),
                  // ),
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
