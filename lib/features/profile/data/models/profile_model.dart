class ProfileModel {
  final ProfileUserModel user;
  final ProfileStatsModel stats;
  final ProfileRelationModel relation;

  ProfileModel({
    required this.user,
    required this.stats,
    required this.relation,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: ProfileUserModel.fromJson(json['user'] ?? {}),
      stats: ProfileStatsModel.fromJson(json['stats'] ?? {}),
      relation: ProfileRelationModel.fromJson(json['relation'] ?? {}),
    );
  }
  ProfileModel copyWith({
    ProfileUserModel? user,
    ProfileStatsModel? stats,
    ProfileRelationModel? relation,
  }) {
    return ProfileModel(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      relation: relation ?? this.relation,
    );
  }
}

class ProfileUserModel {
  final String id;
  final String fullName;
  final String username;
  final String avatar;
  final String bio;
  final bool isVerified;
  final bool isPrivate;

  ProfileUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.isVerified,
    required this.isPrivate,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
    );
  }
}

class ProfileStatsModel {
  final int postsCount;
  final int followersCount;
  final int followingCount;

  ProfileStatsModel({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      postsCount: json['postsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }
}

class ProfileRelationModel {
  final bool isMe;
  final bool isFollowing;
  final bool isFriend;

  ProfileRelationModel({
    required this.isMe,
    required this.isFollowing,
    required this.isFriend,
  });

  factory ProfileRelationModel.fromJson(Map<String, dynamic> json) {
    return ProfileRelationModel(
      isMe: json['isMe'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      isFriend: json['isFriend'] ?? false,
    );
  }
}
