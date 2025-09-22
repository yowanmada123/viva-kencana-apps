import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_manager.dart';
import '../../data/repository/auth_repository.dart';
import '../widgets/base_pop_up.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String name = '-';
  String? username;

  Future<void> loadUserData() async {
    final SharedPreferencesManager authSharedPref = SharedPreferencesManager(key: 'auth');
    final dataString = await authSharedPref.read();

    if (dataString != null) {
      final Map<String, dynamic> data = json.decode(dataString);
      final user = data['user'];
      setState(() {
        name = user['name1'] ?? '-';
        username = user['username'].trim() ?? '-';
      });
    }
  }

  @override
  void initState() {    
    loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LogoutBloc(authRepository)),
      ],
      child: Scaffold(
        appBar: AppBar(
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
        ),
        body: Column(
          children: [
            Container(
              height: 180.w,
              width: double.infinity,
              padding: EdgeInsets.only(top: 12.w),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 48.w,
                    backgroundColor: Theme.of(context).hintColor,
                    child: Icon(
                      Icons.person,
                      size: 64.w,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.w,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "@$username",
                    style: TextStyle(fontSize: 12.w, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFE8F0FD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.w),
                    topRight: Radius.circular(20.w),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocConsumer<LogoutBloc, LogoutState>(
                      listener: (context, state) {
                        if (state is LogoutFailure) {
                          BlocProvider.of<AuthenticationBloc>(context).add(
                            SetAuthenticationStatus(isAuthenticated: false),
                          );
                        } else if (state is LogoutSuccess) {
                          BlocProvider.of<AuthenticationBloc>(context).add(
                            SetAuthenticationStatus(isAuthenticated: false),
                          );
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      },
                      builder: (context, state) {
                        return InkWell(
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
                                      context.read<LogoutBloc>().add(
                                        LogoutPressed(),
                                      );
                                    }
                                  },
                                  question: "Apakah Anda yakin ingin keluar dari aplikasi?",
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.w,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Theme.of(context).primaryColor,
                                          size: 20.w,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontSize: 14.w,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.w,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
