import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';
import '../models/profile_post_grid_model.dart';
import '../../../post/data/models/post_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepository({required this.remoteDataSource});

  Future<ProfileModel> getMyProfile({required String token}) {
    return remoteDataSource.getMyProfile(token: token);
  }

  Future<ProfileModel> getUserProfile({
    required String token,
    required String userId,
  }) {
    return remoteDataSource.getUserProfile(token: token, userId: userId);
  }

  Future<List<ProfileGridPostModel>> getUserPostGrid({
    required String token,
    required String userId,
    int limit = 30,
    String? cursor,
  }) {
    return remoteDataSource.getUserPostGrid(
      token: token,
      userId: userId,
      limit: limit,
      cursor: cursor,
    );
  }

  Future<List<PostModel>> getUserPostFeed({
    required String token,
    required String userId,
    int limit = 20,
    String? cursor,
  }) {
    return remoteDataSource.getUserPostFeed(
      token: token,
      userId: userId,
      limit: limit,
      cursor: cursor,
    );
  }

  Future<ProfileUserModel> updateProfile({
    required String token,
    required String fullName,
    required String username,
    required String bio,
    required bool isPrivate,
    String? avatarPath,
  }) {
    return remoteDataSource.updateProfile(
      token: token,
      fullName: fullName,
      username: username,
      bio: bio,
      isPrivate: isPrivate,
      avatarPath: avatarPath,
    );
  }
}
