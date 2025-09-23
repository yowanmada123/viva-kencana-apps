import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/entity/entity_bloc.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_manager.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/entity_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../driver/driver_dashboard_screen.dart';
import '../setting/setting_screen.dart';

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
      child: GridLayout(),
    );
  }
}

class GridLayout extends StatefulWidget {
  const GridLayout({super.key});

  @override
  State<GridLayout> createState() => _GridLayoutState();
}

class _GridLayoutState extends State<GridLayout> {
  String name = '-';
  String? dept;

  Future<void> loadUserData() async {
    final SharedPreferencesManager authSharedPref = SharedPreferencesManager(key: 'auth');
    final dataString = await authSharedPref.read();

    if (dataString != null) {
      final Map<String, dynamic> data = json.decode(dataString);
      final user = data['user'];
      setState(() {
        name = user['name1'] ?? '-';
        dept = user['dept_id'].trim() ?? '-';
      });
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  String getGreeting() {
    final nowUtc = DateTime.now().toUtc();
    final wibTime = nowUtc.add(const Duration(hours: 7));
    final hour = wibTime.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  void initState() {    
    loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                'Viva Kencana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.w,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: BlocConsumer<LogoutBloc, LogoutState>(
                    listener: (context, state) {
                      if (state is LogoutSuccess || state is LogoutFailure) {
                        context.read<AuthenticationBloc>().add(
                            SetAuthenticationStatus(isAuthenticated: false));
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => SettingScreen(),
                            )
                          );
                        },
                        child: Icon(Icons.settings, color: Colors.white),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(right: 16.w),
                  child: Icon(Icons.category_sharp),
                )
              ]
            ),
            Positioned(
              bottom: -30.w,
              left: 16.w,
              right: 16.w,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffD2F801),
                              borderRadius: BorderRadius.circular(15.w)
                            ),
                            padding: EdgeInsets.all(4..w),
                            child: Icon(Icons.person, color: Color(0xff595959), size: 28.w,),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 140.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "👋 ${getGreeting()}",
                                  style: TextStyle(
                                    fontSize: 10.w,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 12.w, color: Theme.of(context).primaryColor),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              "$dept department",
                              style: TextStyle(
                                fontSize: 10.w
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Let’s see your entity",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: Text(
                      "see all",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                    if (entities.isEmpty) {
                      return const Center(
                        child: Text(
                          "Entitas tidak ditemukan",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: List.generate(entities.length, (index) {
                          final entity = entities[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverDashboardScreen(entityId: entity.entityId),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 100.w,
                                    width: double.infinity,
                                    child: entity.urlImage != "" && entity.urlImage.isNotEmpty
                                      ? Image.network(
                                          entity.urlImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(child: Icon(Icons.broken_image, size: 40.w, color: Theme.of(context).disabledColor));
                                          },
                                        )
                                      : Center(child: Icon(Icons.image, size: 40.w, color: Theme.of(context).disabledColor)),
                                  ),
                                                      
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 4.w),
                                    child: Text(
                                      entity.description,
                                      style: TextStyle(
                                        fontSize: 12.w,
                                        fontWeight: FontWeight.w500
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: hexToColor(entity.color),
                                              radius: 10.w,
                                            ),
                                            SizedBox(width: 4.w),
                                            SizedBox(
                                              width: 50.w,
                                              child: Text(
                                                entity.entityId,
                                                style: TextStyle(
                                                  fontSize: 10.w,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                                      
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0), 
                                            minimumSize: Size(0, 20.w),
                                            backgroundColor: Theme.of(context).primaryColor,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DriverDashboardScreen(entityId: entity.entityId),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "See more",
                                            style: TextStyle(
                                              fontSize: 10.w,
                                              color: Theme.of(context).hintColor,
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ),
                          );
                        }),
                      ),
                    );
                  } else if (state is EntityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Text("Entitas tidak ditemukan");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
