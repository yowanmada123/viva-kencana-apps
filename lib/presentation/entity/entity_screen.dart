import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/entity/entity_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/entity_repository.dart';
import '../driver/driver_dashboard_screen.dart';
import '../../models/errors/custom_exception.dart';

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
        
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
        child: BlocConsumer<EntityBloc, EntityState>(
          listener: (context, state) {
            if (state is EntityFailure) {
              if (state.exception is UnauthorizedException) {
                context.read<AuthenticationBloc>().add(
                  SetAuthenticationStatus(isAuthenticated: false),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }
          },
          builder: (context, state) {
            if (state is EntityLoaded) {
              final entities = state.entities;
              return GridView.count(
                crossAxisCount: 4,
                children: List.generate(entities.length, (index) {
                  final entity = entities[index];
                  return Container(
                    padding: EdgeInsets.all(4.w),
                    child: Center(
                      child: SizedBox(
                        width: 50.w,
                        height: 50.w,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hexToColor(entity.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w), 
                            ),
                            padding: EdgeInsets.zero, 
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverDashboardScreen(entityId: entity.entityId),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              entity.entityId,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
