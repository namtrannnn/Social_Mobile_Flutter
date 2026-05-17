import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/config/api_config.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  final SocketService socketService;
  AuthController(this.repository, this.socketService);

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;
  String? tokenUser;
  bool isCheckingAuth = true;
  bool isLoggedIn = false;

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await repository.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.isSuccess) {
        currentUser = response.user;
        tokenUser = response.tokenUser;
        isLoggedIn = true;
        // SAVE TOKEN
        if (tokenUser != null && tokenUser!.isNotEmpty) {
          await SecureStorageService.saveToken(tokenUser!);
        }
        final expiredAt = DateTime.now().add(const Duration(days: 3));

        await SecureStorageService.saveExpiredAt(expiredAt.toIso8601String());
        if (currentUser?.id != null && currentUser!.id.isNotEmpty) {
          await SecureStorageService.saveUserId(currentUser!.id);
        }
        if (tokenUser != null && tokenUser!.isNotEmpty) {
          socketService.connect(
            baseUrl: ApiConfig.socketUrl,
            token: tokenUser!,
          );
        }

        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await repository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password.trim(),
      );

      if (response.isSuccess) {
        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    isCheckingAuth = true;
    notifyListeners();

    final token = await SecureStorageService.getValidToken();

    if (token != null) {
      tokenUser = token;
      isLoggedIn = true;
    } else {
      tokenUser = null;
      currentUser = null;
      isLoggedIn = false;
    }

    isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> logout() async {
    socketService.disconnect();

    await Future.delayed(const Duration(milliseconds: 300));

    await SecureStorageService.clearAuth();

    currentUser = null;
    tokenUser = null;
    isLoggedIn = false;

    notifyListeners();
  }
}
