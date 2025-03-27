import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivakencanaapp/data/repository/auth_repository.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/login-form/login_form_bloc.dart';

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

class LoginFormView extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController shifController = TextEditingController();

  LoginFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/viva-logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: shifController,
                decoration: InputDecoration(labelText: 'Shift'),
              ),
              SizedBox(height: 30),
              BlocConsumer<LoginFormBloc, LoginFormState>(
                listener: (context, state) {
                  if (state is LoginFormError) {
                    usernameController.clear();
                    passwordController.clear();
                    shifController.clear();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is LoginFormSuccess) {
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
                        final shif = shifController.text;
                        context.read<LoginFormBloc>().add(
                          LoginFormSubmitted(
                            username: username,
                            password: password,
                            shif: shif,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                          return Text('Login');
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
