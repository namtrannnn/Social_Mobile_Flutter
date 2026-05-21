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

    final rawUserId = json['user_id'];
    String parsedUserId = '';

    if (rawUserId is Map) {
      parsedUserId = (rawUserId['_id'] ?? rawUserId['id'] ?? '').toString();
    } else {
      parsedUserId = (rawUserId ?? '').toString();
    }

    final rawRoomId = json['roomChatId'] ?? json['room_chat_id'];
    String parsedRoomId = '';

    if (rawRoomId is Map) {
      parsedRoomId = (rawRoomId['_id'] ?? rawRoomId['id'] ?? '').toString();
    } else {
      parsedRoomId = (rawRoomId ?? '').toString();
    }

    return ChatMessage(
      id: (json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
          .toString(),
      userId: parsedUserId,
      roomChatId: parsedRoomId,
      content: json['content']?.toString(),
      images: parsedImages,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toSocketJson() {
    return {
      'roomChatId': roomChatId,
      'content': content,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}
