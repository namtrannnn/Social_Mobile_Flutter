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
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  ProfileUserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatar,
    String? bio,
    bool? isVerified,
    bool? isPrivate,
  }) {
    return ProfileUserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
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

  ProfileStatsModel copyWith({
    int? postsCount,
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileStatsModel(
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

class ProfileRelationModel {
  final bool isMe;
  final bool isFollowing;
  final bool isFriend;
  final String relationStatus;

  ProfileRelationModel({
    required this.isMe,
    required this.isFollowing,
    required this.isFriend,
    required this.relationStatus,
  });

  factory ProfileRelationModel.fromJson(Map<String, dynamic> json) {
    final bool isMe = json['isMe'] ?? false;
    final bool isFollowing = json['isFollowing'] ?? false;
    final bool isFriend = json['isFriend'] ?? false;

    final String relationStatus =
        json['relationStatus'] ??
        json['status'] ??
        json['relation_status'] ??
        _getFallbackStatus(isMe: isMe, isFriend: isFriend);

    return ProfileRelationModel(
      isMe: isMe,
      isFollowing: isFollowing,
      isFriend: isFriend,
      relationStatus: relationStatus,
    );
  }

  static String _getFallbackStatus({
    required bool isMe,
    required bool isFriend,
  }) {
    if (isMe) return 'self';
    if (isFriend) return 'friend';
    return 'none';
  }

  ProfileRelationModel copyWith({
    bool? isMe,
    bool? isFollowing,
    bool? isFriend,
    String? relationStatus,
  }) {
    return ProfileRelationModel(
      isMe: isMe ?? this.isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      isFriend: isFriend ?? this.isFriend,
      relationStatus: relationStatus ?? this.relationStatus,
    );
  }
}
