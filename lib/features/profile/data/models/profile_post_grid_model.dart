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
    final media = json['media'];

    ProfileMediaModel? parsedFirstMedia;
    int parsedMediaCount = 0;

    // Case 1: API grid cũ trả firstMedia
    if (json['firstMedia'] != null &&
        json['firstMedia'] is Map<String, dynamic>) {
      parsedFirstMedia = ProfileMediaModel.fromJson(
        json['firstMedia'] as Map<String, dynamic>,
      );
    }

    // Case 2: API mentions/detail trả media[]
    if (parsedFirstMedia == null && media is List && media.isNotEmpty) {
      final firstItem = media.first;

      if (firstItem is Map<String, dynamic>) {
        parsedFirstMedia = ProfileMediaModel.fromJson(firstItem);
      }
    }

    if (json['mediaCount'] != null) {
      parsedMediaCount = _toInt(json['mediaCount']);
    } else if (media is List) {
      parsedMediaCount = media.length;
    }

    return ProfileGridPostModel(
      id: json['_id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      firstMedia: parsedFirstMedia,
      mediaCount: parsedMediaCount,
      likesCount: _toInt(json['likesCount']),
      commentsCount: _toInt(json['commentsCount']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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
      url: json['url']?.toString() ?? '',
      publicId: json['public_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'image',
      thumbnail: json['thumbnail']?.toString() ?? '',
      width: _toInt(json['width']),
      height: _toInt(json['height']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
