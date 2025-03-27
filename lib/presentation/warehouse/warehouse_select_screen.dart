import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/data/repository/warehouse_repository.dart';
import '../../bloc/expedition/list-warehouse/list_warehouse_bloc.dart';
import 'warehouse_content_list_screen.dart';

class WarehouseSelectScreen extends StatelessWidget {
  const WarehouseSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final warehouseRepository = context.read<WarehouseRepository>();
    // final authRepository = context.read<AuthRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  ListWarehouseBloc(warehouseRepository: warehouseRepository),
        ),
      ],
      child: WarehouseSelectView(),
    );
  }
}

class WarehouseSelectView extends StatefulWidget {
  const WarehouseSelectView({super.key});

  @override
  State<WarehouseSelectView> createState() => _WarehouseSelectViewState();
}

class _WarehouseSelectViewState extends State<WarehouseSelectView> {
  @override
  void initState() {
    // final authState = context.read<AuthenticationBloc>().state as Authenticated;
    // user = authState.user;
    context.read<ListWarehouseBloc>().add(
      LoadListWarehouse(deliveryId: '5011250200017'),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Loading Dock',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).hintColor,
      body: SafeArea(
        child: CustomScrollView(
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
                            children: [
                              Text(
                                'Nama Gudang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff575353),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 24,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'B 1234 XYZ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).disabledColor,
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
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(6.0),
                                      child: Text(
                                        "11246126819",
                                        style: TextStyle(
                                          letterSpacing: 6,
                                          fontSize: 18,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
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
                child: BlocBuilder<ListWarehouseBloc, ListWarehouseState>(
                  builder: (context, state) {
                    if (state is ListWarehouseLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ListWarehouseFailure) {
                      return Center(child: Text("Error: ${state.message}"));
                    } else if (state is ListWarehouseSuccess) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            state.warehouses.length, // Jumlah item dalam list
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: FlutterLogo(),
                              title: Text(
                                state.warehouses[index].descr,
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  final id = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const WareHouseContentListScreen(),
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
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
