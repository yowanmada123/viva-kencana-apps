import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/authorization/access_menu/access_menu_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/authorization_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/menu.dart';
import '../qr_code/qr_code_screen.dart';
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

class MyGridLayout extends StatelessWidget {
  Map<String, dynamic>? getButton(SubMenu submenu) {
    final menuId = submenu.menuId;
    final caption = submenu.menuCaption;

    final icon = _getIconForMenuId(menuId);
    Widget Function()? routeBuilder;
    switch (menuId) {
      case 'confirmLoading':
        routeBuilder = () => QrCodeScreen(); 
        break;
      default:
        routeBuilder = null;
    }

    return {
      'icon': icon,
      'text': caption,
      'route': routeBuilder,
    };
  }

  IconData _getIconForMenuId(String? menuId) {
    switch (menuId) {
      case 'confirmLoading':
        return Icons.local_shipping;
      case 'packing':
        return Icons.inventory;
      default:
        return Icons.menu;
    }
  }

  void _navigateToScreen(BuildContext context, Map<String, dynamic> button) {
    final routeBuilder = button['route'] as Widget Function()?;

    if (routeBuilder == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fitur belum tersedia")));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeBuilder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E4694),
        iconTheme: const IconThemeData(color: Colors.white),
        // leading: IconButton(
        //   icon: Icon(Icons.menu, color: Color(0xffffffff)),
        //   onPressed: () => print("Menu"),
        // ),
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
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst);
              }
            }
          },
          builder: (context, state) {
            if (state is AccessMenuLoadSuccess) {
              final menus = state.menus;
              return _buildGroupMenu(context, menus);
            } else if (state is AccessMenuLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text("Tidak ada menu yang dapat diakses.")
              );
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
          final button = getButton(submenu);
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
    return Container(
      padding: EdgeInsets.all(4.w),
      child: SizedBox.square(
        dimension: 80.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xff1E4694),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: GestureDetector(
                onTap: () => _navigateToScreen(context, button),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xff1E4694),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Icon(
                    button['icon'],
                    size: 24.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.w),
            Text(
                button['text'],
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.w,
                  color: const Color(0xff1E4694),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
