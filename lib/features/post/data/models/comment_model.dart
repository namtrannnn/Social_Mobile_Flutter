class CommentUserModel {
  final String id;
  final String fullName;
  final String username;
  final String avatar;
  final bool isVerified;

  CommentUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class CommentModel {
  final String id;
  final String post;
  final CommentUserModel user;
  final String content;
  final String? parentComment;

  final String? replyToComment;
  final CommentUserModel? replyToUser;
  final List<CommentUserModel> mentions;

  final int likesCount;
  final String status;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> replies;
  final int repliesCount;
  final bool isPinned;
  final DateTime? pinnedAt;
  final bool isLiked;
  final bool isLikedByPostAuthor;
  CommentModel({
    required this.id,
    required this.post,
    required this.user,
    required this.content,
    required this.parentComment,
    required this.replyToComment,
    required this.replyToUser,
    required this.mentions,
    required this.likesCount,
    required this.status,
    required this.isEdited,
    required this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
    required this.repliesCount,
    required this.isPinned,
    required this.pinnedAt,
    required this.isLiked,
    required this.isLikedByPostAuthor,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      post: json['post']?.toString() ?? '',
      user: CommentUserModel.fromJson(json['user'] ?? {}),
      content: json['content'] ?? '',
      parentComment: json['parentComment']?.toString(),
      replyToComment: json['replyToComment']?.toString(),
      replyToUser: json['replyToUser'] != null
          ? CommentUserModel.fromJson(json['replyToUser'])
          : null,
      mentions: (json['mentions'] as List? ?? [])
          .map((e) => CommentUserModel.fromJson(e))
          .toList(),
      likesCount: json['likesCount'] ?? 0,
      status: json['status'] ?? 'active',
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      replies: (json['replies'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e))
          .toList(),
      repliesCount: json['repliesCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      pinnedAt: json['pinnedAt'] != null
          ? DateTime.tryParse(json['pinnedAt'])
          : null,
      isLiked: json['isLiked'] ?? false,
      isLikedByPostAuthor: json['isLikedByPostAuthor'] ?? false,
    );
  }

  CommentModel copyWith({
    String? content,
    bool? isEdited,
    DateTime? editedAt,
    List<CommentModel>? replies,
    String? status,
    int? likesCount,
    int? repliesCount,
    bool? isPinned,
    DateTime? pinnedAt,
    bool? isLiked,
    bool? isLikedByPostAuthor,
  }) {
    return CommentModel(
      id: id,
      post: post,
      user: user,
      content: content ?? this.content,
      parentComment: parentComment,
      replyToComment: replyToComment,
      replyToUser: replyToUser,
      mentions: mentions,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      isLiked: isLiked ?? this.isLiked,
      isLikedByPostAuthor: isLikedByPostAuthor ?? this.isLikedByPostAuthor,
    );
  }
}
