import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/entity/entity_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/entity_repository.dart';
import '../driver/driver_dashboard_screen.dart';
import '../widgets/base_pop_up.dart';

class EntityScreen extends StatelessWidget {
  const EntityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final entityRepository = context.read<EntityRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LogoutBloc(authRepository)),
        BlocProvider(
          create:
              (context) =>
                  EntityBloc(entityRepository: entityRepository)
                    ..add(LoadEntity()),
        ),
      ],
      child: MyGridLayout(),
    );
  }
}

class MyGridLayout extends StatelessWidget {
  final List<Map<String, dynamic>> buttons = [
    {'text': 'Loading', 'color': Color(0xff1E4694)},
    {'text': 'Packing', 'color': Color(0xffF79D2A)},
    {'text': 'Selesai', 'color': Color(0xff28A745)},
    {'text': 'Cancel', 'color': Color(0xffDC3545)},
  ];

  void _navigateToScreen(BuildContext context, int index, String? name) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: name),
            builder: (context) => DriverDashboardScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E4694),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'VIVA KENCANA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutFailure) {
                  BlocProvider.of<AuthenticationBloc>(
                    context,
                  ).add(SetAuthenticationStatus(isAuthenticated: false));
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
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
        child: BlocBuilder<EntityBloc, EntityState>(
          builder: (context, state) {
            if (state is EntityLoaded) {
              final entities = state.entities;
              return GridView.count(
                crossAxisCount: 4,
                children: List.generate(entities.length, (index) {
                  final entity = entities[index];
                  return Container(
                    padding: EdgeInsets.all(4.w),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: '/dashboard'),
                              builder: (context) => DriverDashboardScreen(),
                            ),
                            (route) => route.isCurrent,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: hexToColor(entity.color),
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            entity.entityId,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            } else if (state is EntityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Text("Entitas tidak ditemukan");
            }
          },
        ),
      ),
    );
  }
}
