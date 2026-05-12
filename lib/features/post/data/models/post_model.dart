class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String caption;
  final List<PostMediaModel> media;
  final String location;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final int sharesCount;
  final bool allowComments;
  final bool hideLikeCount;
  final bool isLiked;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.caption,
    required this.media,
    required this.location,
    required this.hashtags,
    required this.likesCount,
    required this.commentsCount,
    required this.savesCount,
    required this.sharesCount,
    required this.allowComments,
    required this.hideLikeCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};

    return PostModel(
      id: json['_id'] ?? '',
      authorId: author['_id'] ?? '',
      authorName: author['fullName'] ?? '',
      authorAvatar: author['avatar'] ?? '',
      caption: json['caption'] ?? '',
      media: (json['media'] as List? ?? [])
          .map((e) => PostMediaModel.fromJson(e))
          .toList(),
      location: json['location'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      savesCount: json['savesCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      allowComments: json['allowComments'] ?? true,
      hideLikeCount: json['hideLikeCount'] ?? false,
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? caption,
    List<PostMediaModel>? media,
    String? location,
    List<String>? hashtags,
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    int? sharesCount,
    bool? allowComments,
    bool? hideLikeCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      caption: caption ?? this.caption,
      media: media ?? this.media,
      location: location ?? this.location,
      hashtags: hashtags ?? this.hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savesCount: savesCount ?? this.savesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      allowComments: allowComments ?? this.allowComments,
      hideLikeCount: hideLikeCount ?? this.hideLikeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get firstImageUrl {
    if (media.isEmpty) return '';
    return media.first.url;
  }
}

class PostMediaModel {
  final String id;
  final String url;
  final String publicId;
  final String type;
  final String thumbnail;
  final int width;
  final int height;

  PostMediaModel({
    required this.id,
    required this.url,
    required this.publicId,
    required this.type,
    required this.thumbnail,
    required this.width,
    required this.height,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['_id'] ?? '',
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
      type: json['type'] ?? 'image',
      thumbnail: json['thumbnail'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}
