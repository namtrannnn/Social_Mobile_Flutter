class ProfileGridPostModel {
  final String id;
  final String caption;
  final ProfileMediaModel? firstMedia;
  final int mediaCount;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;

  ProfileGridPostModel({
    required this.id,
    required this.caption,
    required this.firstMedia,
    required this.mediaCount,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory ProfileGridPostModel.fromJson(Map<String, dynamic> json) {
    return ProfileGridPostModel(
      id: json['_id'] ?? '',

      caption: json['caption'] ?? json['caption'] ?? '',

      firstMedia: json['firstMedia'] != null
          ? ProfileMediaModel.fromJson(json['firstMedia'])
          : null,

      mediaCount: json['mediaCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class ProfileMediaModel {
  final String url;
  final String publicId;
  final String type;
  final String thumbnail;
  final int width;
  final int height;

  ProfileMediaModel({
    required this.url,
    required this.publicId,
    required this.type,
    required this.thumbnail,
    required this.width,
    required this.height,
  });

  factory ProfileMediaModel.fromJson(Map<String, dynamic> json) {
    return ProfileMediaModel(
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
      type: json['type'] ?? 'image',
      thumbnail: json['thumbnail'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}
