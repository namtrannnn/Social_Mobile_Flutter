import 'package:flutter/material.dart';

import '../../data/repositories/friend_repository.dart';
import '../../data/models/friend_model.dart';

class FriendController extends ChangeNotifier {
  final FriendRepository repository;

  FriendController({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  bool isLoadingFriends = false;
  List<FriendModel> friends = [];
  final Map<String, String> _relationStatusByUserId = {};
  bool isLoadingRequests = false;
  List<FriendModel> receivedRequests = [];
  String getRelationStatusLocal(String userId) {
    return _relationStatusByUserId[userId] ?? 'none';
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

      await loadFriends();

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

  Future<void> loadFriends({String? userId}) async {
    try {
      isLoadingFriends = true;
      errorMessage = null;
      notifyListeners();

      final result = await repository.getListFriends(userId: userId);

      friends = result;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('loadFriends error: $e');
    } finally {
      isLoadingFriends = false;
      notifyListeners();
    }
  }

  void clear() {
    isLoading = false;
    isLoadingFriends = false;
    errorMessage = null;
    friends.clear();
    isLoadingRequests = false;
    receivedRequests.clear();
    _relationStatusByUserId.clear();
    notifyListeners();
  }
}
