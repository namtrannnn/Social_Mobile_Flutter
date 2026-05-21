import 'package:flutter/material.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/search_user_model.dart';
import '../../data/repositories/search_repository.dart';

class GlobalSearchController extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  bool isLoading = false;
  String? errorMessage;
  List<SearchUserModel> users = [];

  Future<void> searchUsers(String keyword) async {
    final text = keyword.trim();

    if (text.isEmpty) {
      users = [];
      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final token = await SecureStorageService.getValidToken();

      if (token == null) {
        users = [];
        errorMessage = 'Phiên đăng nhập đã hết hạn';
        return;
      }

      users = await _repository.searchUsers(token: token, keyword: text);
    } catch (e) {
      users = [];
      errorMessage = 'Không thể tìm kiếm người dùng';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    users = [];
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
