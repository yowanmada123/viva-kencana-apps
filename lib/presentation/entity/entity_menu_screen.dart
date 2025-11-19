import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/authorization/access_menu/access_menu_bloc.dart';
import '../../bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/authorization_repository.dart';
import '../../data/repository/sales_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/menu.dart';
import '../../utils/strict_location.dart';
import '../qr_code/qr_code_screen.dart';
import '../sales_activity/sales_activity_dashboard_screen.dart';

class EntityMenuScreen extends StatelessWidget {
  const EntityMenuScreen({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context) {
    log('Access to presentation/entity/entitiy_menu_screen.dart'); 
    final authRepository = context.read<AuthRepository>();
    final authorizationRepository = context.read<AuthorizationRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LogoutBloc(authRepository)),
        BlocProvider(
          create:
              (context) =>
              
                  AccessMenuBloc(authorizationRepository)
                    ..add(LoadAccessMenu(entityId: entityId)),
        ),
      ],
      child: MyGridLayout(entityId: entityId),
    );
  }
}

class MyGridLayout extends StatefulWidget {
  const MyGridLayout({super.key, required this.entityId});

  final String entityId;

  @override
  _MyGridLayoutState createState() => _MyGridLayoutState();
}

class _MyGridLayoutState extends State<MyGridLayout> {
  String? _loadingMenuId;

  Map<String, dynamic>? getButton(SubMenu submenu, BuildContext context) {
    final menuId = submenu.menuId;
    final caption = submenu.menuCaption;
    final icon = _getIconForMenuId(menuId);

    Future<void> Function()? routeAction;

    switch (menuId) {
      case 'confirmLoading':
        routeAction = () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QrCodeScreen()),
          );
        };
        break;
      case 'mnuSalesActivity':
        routeAction = () async {
          final bloc = context.read<SalesActivityFormCheckInBloc>();
          final salesRepository = context.read<SalesActivityRepository>();
          final position = await StrictLocation.getCurrentPosition();

          bloc.add(const LoadSalesData());
          bool isHandled = false;
          Timer(const Duration(seconds: 3), () {
            if (!isHandled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Permintaan terlalu lama, coba lagi"),
                ),
              );
            }
          });

          final salesState = bloc.state;
          if (salesState is SalesDataSuccess) {
            final salesId = salesState.sales.salesId;

            if (salesId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ID Sales belum terdaftarkan")),
              );
              return;
            }

            if (position.isMocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Perangkat terdeteksi menggunakan lokasi palsu",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            isHandled = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: SalesActivityFormCheckInBloc(salesActivityRepository: salesRepository),
                      child: SalesActivityDashboardScreen(
                        sales: salesState.sales,
                      ),
                    ),
              ),
            );
          } else if (salesState is SalesDataError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ID Sales belum terdaftarkan")),
            );
            isHandled = true;
          }
        };
        break;
      default:
        routeAction = null;
    }

    return {
      'menuId': menuId,
      'icon': icon,
      'text': caption,
      'action': routeAction,
    };
  }

  SubMenu attachAction(BuildContext context, SubMenu submenu) {
    switch (submenu.menuId) {
      case 'confirmLoading':
        return submenu.copyWith(
          action: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QrCodeScreen()),
            );
          },
        );

      case 'mnuSalesActivity':
        return submenu.copyWith(
          action: () async {
            final bloc = context.read<SalesActivityFormCheckInBloc>();
            final salesRepository = context.read<SalesActivityRepository>();
            final position = await StrictLocation.getCurrentPosition();

            bloc.add(const LoadSalesData());
            bool isHandled = false;

            Timer(const Duration(seconds: 3), () {
              if (!isHandled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Permintaan terlalu lama, coba lagi")),
                );
              }
            });

            final salesState = bloc.state;
            if (salesState is SalesDataSuccess) {
              final salesId = salesState.sales.salesId;

              if (salesId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ID Sales belum terdaftarkan")),
                );
                return;
              }

              if (position.isMocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Perangkat terdeteksi menggunakan lokasi palsu"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              isHandled = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: SalesActivityFormCheckInBloc(
                      salesActivityRepository: salesRepository,
                    ),
                    child: SalesActivityDashboardScreen(
                      sales: salesState.sales,
                    ),
                  ),
                ),
              );
            } else if (salesState is SalesDataError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ID Sales belum terdaftarkan")),
              );
              isHandled = true;
            }
          },
        );

      default:
        return submenu.copyWith(action: null);
    }
  }

  IconData _getIconForMenuId(String? menuId) {
    switch (menuId) {
      case 'confirmLoading':
        return Icons.local_shipping;
      case 'mnuSalesActivity':
        return Icons.location_searching;
      default:
        return Icons.menu;
    }
  }

  void _navigateToScreen(
    BuildContext context,
    SubMenu submenu,
    bool isLoading,
  ) async {
    if (isLoading) return;

    if (submenu.action == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fitur belum tersedia")),
      );
      return;
    }

    setState(() {
      _loadingMenuId = submenu.menuId;
    });

    await submenu.action!();

    setState(() {
      _loadingMenuId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.entityId,
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
        margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: BlocConsumer<AccessMenuBloc, AccessMenuState>(
          listener: (context, state) {
            if (state is AccessMenuLoadFailure) {
              if (state.exception is UnauthorizedException) {
                context.read<AuthenticationBloc>().add(
                  SetAuthenticationStatus(isAuthenticated: false),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }
          },
          builder: (context, state) {
            if (state is AccessMenuLoadSuccess) {
              final menus = state.menus;
              if (menus.isEmpty) {
                return Center(child: Text("Tidak ada menu yang dapat diakses."));
              }
              return buildGroupMenu(context, menus);
            } else if (state is AccessMenuLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text("Tidak ada menu yang dapat diakses."));
            }
          },
        ),
      ),
    );
  }

  Widget buildGroupMenu(BuildContext context, List<Menu> menus) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      itemBuilder: (context, menuIndex) {
        final menu = menus[menuIndex];
        final submenus = menu.submenus;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.w,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.w),
                child: Text(
                  "Pilihan menu operasional untuk ${menu.menuHeaderCaption}",
                  style: TextStyle(
                    fontSize: 12.w,
                    color: Colors.black87,
                  ),
                ),
              ),

              Column(
                children: List.generate(submenus.length, (submenuIndex) {
                  final submenu = attachAction(context, submenus[submenuIndex]);
                  final iconCode = int.tryParse(submenu.icon) ?? Icons.help.codePoint;
                  final isLoading = _loadingMenuId == submenu.menuId;

                  return GestureDetector(
                    onTap: () => _navigateToScreen(context, submenu, isLoading),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                                  color: Colors.white,
                                  size: 20.w,
                                ),
                          ),
                          SizedBox(width: 12.w),
                    
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoading ? 'Loading...' : submenu.menuCaption,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff1E4694),
                                  ),
                                ),
                                SizedBox(height: 4.w),
                                Text(
                                  "Let's see ${submenu.menuCaption} process",
                                  style: TextStyle(
                                    fontSize: 12.w,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    
                          if (!isLoading)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.w,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
