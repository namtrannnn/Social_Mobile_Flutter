import 'package:flutter/material.dart';

import '../../data/datasources/user_remote_datasource.dart';
import '../../data/models/simple_user_model.dart';

class UserSearchController extends ChangeNotifier {
  final UserRemoteDataSource userRemoteDataSource;

  UserSearchController({required this.userRemoteDataSource});

  List<SimpleUserModel> users = [];
  bool isLoading = false;
  String? error;

  Future<void> searchUsers({
    required String token,
    required String keyword,
  }) async {
    if (keyword.trim().isEmpty) {
      users = [];
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      users = await userRemoteDataSource.searchUsers(
        token: token,
        keyword: keyword.trim(),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    users = [];
    error = null;
    notifyListeners();
  }
}
