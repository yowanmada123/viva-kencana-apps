import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/login-form/login_form_bloc.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_key.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_manager.dart';
import '../../data/repository/auth_repository.dart';

class LoginFormScreen extends StatelessWidget {
  const LoginFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();

    return BlocProvider(
      create: (context) => LoginFormBloc(authRepository),
      child: LoginFormView(),
    );
  }
}

class LoginFormView extends StatefulWidget {
  const LoginFormView({super.key});

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController shifController = TextEditingController();


  bool rememberMe = true;
  bool _obscurePassword = true;
  
  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  void _loadRememberedLogin() async {
    final pref = SharedPreferencesManager(key: SharedPreferencesKey.loginRememberKey);
    final data = await pref.read();
    if (data != null) {
      final decoded = json.decode(data);
      usernameController.text = decoded['username'];
      passwordController.text = decoded['password'];
      setState(() {
        rememberMe = true;
      });
    } else {
      setState(() {
        rememberMe = false;
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    shifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: deviceSize.height * 0.05),
                Center(
                  child: Image.asset(
                    'assets/images/viva-logo.png',
                    width: 200.w,
                    height: 200.w,
                  ),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(fontSize: 14.w),
                    isCollapsed: true,
                  ),
                ),
                SizedBox(height: 20.w),
                TextFormField(
                  controller: passwordController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 16,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        splashRadius: 14,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    isDense: true,
                    alignLabelWithHint: true,
                  ),
                  obscureText: _obscurePassword,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text("Remember Me"),
                  ],
                ),
                BlocConsumer<LoginFormBloc, LoginFormState>(
                  listener: (context, state) {
                    if (state is LoginFormError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xffEB5757),
                        ),
                      );
                    } else if (state is LoginFormSuccess) {
                      if (rememberMe) {
                        SharedPreferencesManager(key: SharedPreferencesKey.loginRememberKey)
                          .write(json.encode({
                            'username': usernameController.text,
                            'password': passwordController.text,
                          }));
                      } else {
                        SharedPreferencesManager(key: SharedPreferencesKey.loginRememberKey)
                          .clear();
                      }
                        
                      BlocProvider.of<AuthenticationBloc>(context).add(
                        SetAuthenticationStatus(
                          isAuthenticated: true,
                          user: state.user,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        if (state is! LoginFormLoading) {
                          final username = usernameController.text;
                          final password = passwordController.text;
                          if (username.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Username atau password kosong'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Color(0xffEB5757),
                              ),
                            );
                            return;
                          }
                          context.read<LoginFormBloc>().add(
                            LoginFormSubmitted(
                              username: username,
                              password: password,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Builder(
                        builder: (BuildContext context) {
                          if (state is LoginFormLoading) {
                            return CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            );
                          } else {
                            return Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                const Spacer(),

                FutureBuilder(
                  future: PackageInfo.fromPlatform(), 
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Loading...");
                    }

                    final info = snapshot.data!;

                    return Column(
                      children: [
                        Text(
                          "${info.appName} (All rights reserved)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Version ${info.version} (kencana.org)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
