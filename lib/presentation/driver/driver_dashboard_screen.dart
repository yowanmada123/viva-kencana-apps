import 'dart:async';

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
import '../widgets/base_pop_up.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context) {
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
      child: MyGridLayout(),
    );
  }
}

class MyGridLayout extends StatefulWidget {
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
    Map<String, dynamic> button,
    bool isLoading,
  ) async {
    final action = button['action'] as Future<void> Function()?;
    final menuId = button['menuId'] as String?;

    if (action == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fitur belum tersedia")));
      return;
    }

    if (isLoading) return null;

    setState(() {
      _loadingMenuId = menuId;
    });

    await action();

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
              return _buildGroupMenu(context, menus);
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

  Widget _buildGroupMenu(BuildContext context, List<dynamic> menus) {
    final List<Map<String, dynamic>> submenus = [];

    for (var menu in menus) {
      if (menu.submenus != null) {
        for (var submenu in menu.submenus) {
          final button = getButton(submenu, context);
          if (button != null) submenus.add(button);
        }
      }
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(submenus.length, (index) {
        final button = submenus[index];
        return _buildMenuCard(context, button);
      }),
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> button) {
    final isLoading = _loadingMenuId == button['menuId'];
    return Container(
      padding: EdgeInsets.all(4.w),
      child: GestureDetector(
        onTap: () => _navigateToScreen(context, button, isLoading),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.w),
              ),
              child:
                  isLoading
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
                      : Icon(button['icon'], size: 24.w, color: Colors.white),
            ),
            SizedBox(height: 4.w),
            Expanded(
              child: Text(
                isLoading ? 'Loading...' : button['text'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.w,
                  color: const Color(0xff1E4694),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
