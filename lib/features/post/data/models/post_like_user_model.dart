class PostLikeUserModel {
  final String likeId;
  final DateTime? likedAt;
  final String userId;
  final String fullName;
  final String username;
  final String avatar;
  final bool isVerified;

  PostLikeUserModel({
    required this.likeId,
    required this.likedAt,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
  });

  factory PostLikeUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return PostLikeUserModel(
      likeId: json['likeId'] ?? '',
      likedAt: json['likedAt'] != null
          ? DateTime.tryParse(json['likedAt'])
          : null,
      userId: user['_id'] ?? '',
      fullName: user['fullName'] ?? '',
      username: user['username'] ?? '',
      avatar: user['avatar'] ?? '',
      isVerified: user['isVerified'] ?? false,
    );
  }
}
