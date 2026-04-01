class ChatImage {
  final String url;
  final String? publicId;

  ChatImage({required this.url, this.publicId});

  factory ChatImage.fromJson(Map<String, dynamic> json) {
    return ChatImage(
      url: (json['url'] ?? '').toString(),
      publicId: json['public_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'public_id': publicId};
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String roomChatId;
  final String? content;
  final List<ChatImage> images;
  final DateTime createdAt;
  final Map<String, dynamic>? user;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.roomChatId,
    this.content,
    required this.images,
    required this.createdAt,
    this.user,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];

    List<ChatImage> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .where((e) => e != null && e is Map)
          .map((e) => ChatImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return ChatMessage(
      id: (json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      userId: (json['user_id'] ?? '').toString(),
      roomChatId: (json['roomChatId'] ?? json['room_chat_id'] ?? '').toString(),
      content: json['content']?.toString(),
      images: parsedImages,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      user: json['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toSocketJson() {
    return {
      '_id': id,
      'user_id': userId,
      'roomChatId': roomChatId,
      'content': content,
      'images': images.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (user != null) 'user': user,
    };
  }
}
