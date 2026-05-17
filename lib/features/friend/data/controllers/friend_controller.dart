import 'package:flutter/material.dart';
import '../../../../core/services/socket_service.dart';
import '../models/friend_user_model.dart';
import '../repositories/friend_repository.dart';

class FriendController extends ChangeNotifier {
  final FriendRepository repository;
  final SocketService socketService;

  FriendController(this.repository, this.socketService);

  bool isLoading = false;
  String? errorMessage;

  List<FriendUserModel> suggestions = [];
  List<FriendUserModel> acceptFriends = [];
  List<FriendUserModel> requestFriends = [];
  List<FriendUserModel> listFriends = [];

  Future<void> loadAll() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      suggestions = await repository.getSuggestions();
      acceptFriends = await repository.getAcceptFriends();
      requestFriends = await repository.getRequestFriends();
      listFriends = await repository.getListFriends();
    } catch (e) {
      errorMessage = 'Không tải được dữ liệu bạn bè';
      print('FriendController loadAll error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFriend(String userId) async {
    // socketService.addFriend(userId);
    await Future.delayed(const Duration(milliseconds: 300));
    await loadAll();
  }

  Future<void> cancelFriend(String userId) async {
    // socketService.cancelFriend(userId);
    await Future.delayed(const Duration(milliseconds: 300));
    await loadAll();
  }

  Future<void> acceptFriend(String userId) async {
    // socketService.acceptFriend(userId);
    await Future.delayed(const Duration(milliseconds: 300));
    await loadAll();
  }

  Future<void> refuseFriend(String userId) async {
    // socketService.refuseFriend(userId);
    await Future.delayed(const Duration(milliseconds: 300));
    await loadAll();
  }
}
