import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/controllers/auth_controller.dart';
import '../../../../features/main/presentation/screens/main_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AuthController>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.isLoggedIn) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}
