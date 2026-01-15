import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ViewModel
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            viewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => viewModel.login(_emailCtrl.text, _passCtrl.text, context),
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}