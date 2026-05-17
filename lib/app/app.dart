import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/controllers/auth_controller.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository.dart';

import '../features/friend/data/controllers/friend_controller.dart';
import '../features/friend/data/datasources/friend_remote_datasource.dart';
import '../features/friend/data/repositories/friend_repository.dart';

import '../features/chats/data/controllers/chat_controller.dart';
import '../features/chats/data/datasources/chat_remote_datasource.dart';

import 'routes/route_names.dart';
import 'routes/app_routes.dart';
import '../core/services/socket_service.dart';
import '../core/services/chat_socket_service.dart';
import '../core/storage/secure_storage_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingLogin = true;
  String _initialRoute = RouteNames.login;

  late final AuthRemoteDataSource _authDataSource;
  late final AuthRepository _authRepository;

  late final FriendRemoteDataSource _friendDataSource;
  late final FriendRepository _friendRepository;

  late final ChatRemoteDatasource _chatDataSource;

  late final SocketService _socketService;
  late final ChatSocketService _chatSocketService;

  @override
  void initState() {
    super.initState();

    _authDataSource = AuthRemoteDataSource();
    _authRepository = AuthRepository(_authDataSource);

    _friendDataSource = FriendRemoteDataSource();
    _friendRepository = FriendRepository(_friendDataSource);

    _chatDataSource = ChatRemoteDatasource();

    _socketService = SocketService();
    _chatSocketService = ChatSocketService();

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await SecureStorageService.getValidToken();

    if (!mounted) return;

    setState(() {
      _initialRoute = (token != null && token.isNotEmpty)
          ? RouteNames.main
          : RouteNames.login;
      _isCheckingLogin = false;
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _chatSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLogin) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(_authRepository, _socketService),
        ),
        ChangeNotifierProvider(
          create: (_) => FriendController(_friendRepository, _socketService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatController(
            remote: _chatDataSource,
            socketService: _chatSocketService,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: _initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
