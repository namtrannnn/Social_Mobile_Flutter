import '../datasources/friend_remote_datasource.dart';
import '../models/friend_user_model.dart';

class FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepository(this.remoteDataSource);

  Future<List<FriendUserModel>> getSuggestions() {
    return remoteDataSource.getSuggestions();
  }

  Future<List<FriendUserModel>> getAcceptFriends() {
    return remoteDataSource.getAcceptFriends();
  }

  Future<List<FriendUserModel>> getRequestFriends() {
    return remoteDataSource.getRequestFriends();
  }

  Future<List<FriendUserModel>> getListFriends() {
    return remoteDataSource.getListFriends();
  }

  Future<void> addFriend(String userId) {
    return remoteDataSource.addFriend(userId);
  }

  Future<void> acceptFriend(String userId) {
    return remoteDataSource.acceptFriend(userId);
  }

  Future<void> refuseFriend(String userId) {
    return remoteDataSource.refuseFriend(userId);
  }

  Future<void> cancelFriend(String userId) {
    return remoteDataSource.cancelFriend(userId);
  }
}
