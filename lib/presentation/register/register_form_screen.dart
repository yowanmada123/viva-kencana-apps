import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/login-form/login_form_bloc.dart';

class RegisterFormScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController shifController = TextEditingController();

  RegisterFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: BlocBuilder<LoginFormBloc, LoginFormState>(
          builder: (context, state) {
            if (state is LoginFormLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is LoginFormSuccess) {
              return Text('Welcome ${state.user.username}');
            } else if (state is LoginFormError) {
              usernameController.clear();
              passwordController.clear();
              shifController.clear();
              // Show an error message
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            return Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: shifController,
                  decoration: InputDecoration(labelText: 'Shif'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    context.read<LoginFormBloc>().add(
                      LoginFormSubmitted(
                        username: username,
                        password: password,
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
