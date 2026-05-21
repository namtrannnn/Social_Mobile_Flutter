import '../datasources/friend_remote_datasource.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepository({required this.remoteDataSource});

  Future<String> getRelationStatus(String userId) {
    return remoteDataSource.getRelationStatus(userId);
  }

  Future<String> sendRequest(String userId) {
    return remoteDataSource.sendRequest(userId);
  }

  Future<String> cancelRequest(String userId) {
    return remoteDataSource.cancelRequest(userId);
  }

  Future<String> acceptRequest(String userId) {
    return remoteDataSource.acceptRequest(userId);
  }

  Future<String> refuseRequest(String userId) {
    return remoteDataSource.refuseRequest(userId);
  }

  Future<List<FriendModel>> getReceivedRequests() {
    return remoteDataSource.getReceivedRequests();
  }
  // ==========================
  // Friends List
  // ==========================

  Future<List<FriendModel>> getListFriends({String? userId}) {
    return remoteDataSource.getListFriends(userId: userId);
  }
}
