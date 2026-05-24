import 'package:flutter/material.dart';

import '../../data/repositories/friend_repository.dart';
import '../../data/models/friend_model.dart';

class FriendController extends ChangeNotifier {
  final FriendRepository repository;

  FriendController({required this.repository});

  bool isLoading = false;
  String? errorMessage;

  // =========================
  // FRIEND LIST BY USER
  // =========================

  final Map<String, List<FriendModel>> _friendsByUserId = {};
  final Map<String, bool> _loadingFriendsByUserId = {};

  // Giữ lại biến cũ để các màn khác chưa sửa vẫn không lỗi
  List<FriendModel> friends = [];
  bool isLoadingFriends = false;

  final Map<String, String> _relationStatusByUserId = {};

  bool isLoadingRequests = false;
  List<FriendModel> receivedRequests = [];

  String getRelationStatusLocal(String userId) {
    return _relationStatusByUserId[userId] ?? 'none';
  }

  List<FriendModel> getFriendsByUserId(String userId) {
    return _friendsByUserId[userId] ?? [];
  }

  bool isLoadingFriendsByUserId(String userId) {
    return _loadingFriendsByUserId[userId] ?? false;
  }

  Future<void> loadRelationStatus(String userId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final status = await repository.getRelationStatus(userId);

      _relationStatusByUserId[userId] = status;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('loadRelationStatus error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest(String userId) async {
    final oldStatus = getRelationStatusLocal(userId);

    try {
      _relationStatusByUserId[userId] = 'pending_sent';
      errorMessage = null;
      notifyListeners();

      final status = await repository.sendRequest(userId);

      _relationStatusByUserId[userId] = status;
      notifyListeners();
    } catch (e) {
      _relationStatusByUserId[userId] = oldStatus;
      errorMessage = e.toString();
      notifyListeners();

      debugPrint('sendRequest error: $e');
    }
  }

  Future<void> cancelRequest(String userId) async {
    final oldStatus = getRelationStatusLocal(userId);

    try {
      _relationStatusByUserId[userId] = 'none';
      errorMessage = null;
      notifyListeners();

      final status = await repository.cancelRequest(userId);

      _relationStatusByUserId[userId] = status;
      notifyListeners();
    } catch (e) {
      _relationStatusByUserId[userId] = oldStatus;
      errorMessage = e.toString();
      notifyListeners();

      debugPrint('cancelRequest error: $e');
    }
  }

  Future<void> acceptRequest(String userId) async {
    final oldStatus = getRelationStatusLocal(userId);

    try {
      _relationStatusByUserId[userId] = 'friend';
      errorMessage = null;
      notifyListeners();

      final status = await repository.acceptRequest(userId);

      _relationStatusByUserId[userId] = status;

      receivedRequests.removeWhere((item) => item.id == userId);

      // Load lại danh sách bạn bè của chính mình
      await loadFriends(refresh: true);

      notifyListeners();
    } catch (e) {
      _relationStatusByUserId[userId] = oldStatus;
      errorMessage = e.toString();
      notifyListeners();

      debugPrint('acceptRequest error: $e');
    }
  }

  Future<void> refuseRequest(String userId) async {
    final oldStatus = getRelationStatusLocal(userId);

    try {
      _relationStatusByUserId[userId] = 'none';
      errorMessage = null;
      notifyListeners();

      final status = await repository.refuseRequest(userId);

      _relationStatusByUserId[userId] = status;

      receivedRequests.removeWhere((item) => item.id == userId);

      notifyListeners();
    } catch (e) {
      _relationStatusByUserId[userId] = oldStatus;
      errorMessage = e.toString();
      notifyListeners();

      debugPrint('refuseRequest error: $e');
    }
  }

  void updateRelationStatusFromSocket({
    required String userId,
    required String status,
  }) {
    _relationStatusByUserId[userId] = status;
    notifyListeners();
  }

  Future<void> loadReceivedRequests() async {
    try {
      isLoadingRequests = true;
      errorMessage = null;
      notifyListeners();

      final result = await repository.getReceivedRequests();

      receivedRequests = result;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('loadReceivedRequests error: $e');
    } finally {
      isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> loadFriends({String? userId, bool refresh = false}) async {
    final key = userId ?? 'me';

    if ((_loadingFriendsByUserId[key] ?? false) && !refresh) return;

    try {
      _loadingFriendsByUserId[key] = true;
      isLoadingFriends = true;
      errorMessage = null;
      notifyListeners();

      final result = await repository.getListFriends(userId: userId);

      _friendsByUserId[key] = result;

      // Giữ tương thích code cũ
      friends = result;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('loadFriends error: $e');
    } finally {
      _loadingFriendsByUserId[key] = false;
      isLoadingFriends = false;
      notifyListeners();
    }
  }

  void clearFriendsOfUser(String? userId) {
    final key = userId ?? 'me';

    _friendsByUserId.remove(key);
    _loadingFriendsByUserId.remove(key);

    if (key == 'me') {
      friends.clear();
    }

    notifyListeners();
  }

  void clear() {
    isLoading = false;
    isLoadingFriends = false;
    errorMessage = null;

    friends.clear();
    _friendsByUserId.clear();
    _loadingFriendsByUserId.clear();

    isLoadingRequests = false;
    receivedRequests.clear();
    _relationStatusByUserId.clear();

    notifyListeners();
  }
}
