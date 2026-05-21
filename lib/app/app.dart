import 'package:flutter/material.dart';

import 'routes/route_names.dart';
import 'routes/app_routes.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/services/socket_service.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/main/presentation/screens/main_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingLogin = true;
  String _initialRoute = RouteNames.login;

  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await SecureStorageService.getValidToken();

    if (!mounted) return;

    setState(() {
      _initialRoute = token != null && token.isNotEmpty
          ? RouteNames.main
          : RouteNames.login;
      _isCheckingLogin = false;
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLogin) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NHD',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NHD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: _initialRoute == RouteNames.main
          ? const MainScreen()
          : const LoginScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
