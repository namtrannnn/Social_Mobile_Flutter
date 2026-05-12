import '../datasources/post_remote_datasource.dart';
import '../models/post_model.dart';

class PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepository({required this.remoteDataSource});

  Future<FeedPostResult> getFeedPosts(String token, {String? cursor}) {
    return remoteDataSource.getFeedPosts(token, cursor: cursor);
  }

  Future<PostModel> createPost({
    required String token,
    required String caption,
    required String location,
    required List<String> imagePaths,
    required bool allowComments,
    required bool hideLikeCount,
    required bool hideShare,
    required String visibility,

    required List<String> mentions,

    required List<Map<String, dynamic>> taggedUsers,

    required List<String> allowedUsers,
  }) {
    return remoteDataSource.createPost(
      token: token,
      caption: caption,
      location: location,
      imagePaths: imagePaths,
      allowComments: allowComments,
      hideLikeCount: hideLikeCount,
      hideShare: hideShare,
      visibility: visibility,
      mentions: mentions,

      allowedUsers: allowedUsers,
    );
  }

  Future<Map<String, dynamic>> toggleLike({
    required String token,
    required String postId,
  }) {
    return remoteDataSource.toggleLike(token: token, postId: postId);
  }
}
