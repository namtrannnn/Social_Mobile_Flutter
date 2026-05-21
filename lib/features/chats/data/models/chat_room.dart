import 'chat_member.dart';
import 'chat_message.dart';

class ChatRoomLastMessage {
  final String? messageId;
  final String? sender;
  final String content;
  final int imagesCount;
  final DateTime? createdAt;

  ChatRoomLastMessage({
    this.messageId,
    this.sender,
    this.content = '',
    this.imagesCount = 0,
    this.createdAt,
  });

  factory ChatRoomLastMessage.fromJson(Map<String, dynamic> json) {
    return ChatRoomLastMessage(
      messageId: json['message_id']?.toString(),
      sender: json['sender']?.toString(),
      content: (json['content'] ?? '').toString(),
      imagesCount: json['imagesCount'] is int ? json['imagesCount'] : 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class ChatRoom {
  final String roomId;
  final String typeRoom; // friend | group
  final String? title;
  final String? avatar;
  final String? status;
  final String? theme;
  final List<ChatMember> members;
  final List<ChatMessage> messages;
  final ChatRoomLastMessage? lastMessage;

  ChatRoom({
    required this.roomId,
    required this.typeRoom,
    this.title,
    this.avatar,
    this.status,
    this.theme,
    required this.members,
    required this.messages,
    this.lastMessage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['lastMessage'];

    return ChatRoom(
      roomId: (json['roomId'] ?? json['_id'] ?? '').toString(),
      typeRoom: (json['typeRoom'] ?? 'friend').toString(),
      title: json['title']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
      theme: json['theme']?.toString(),
      members: (json['members'] as List<dynamic>? ?? [])
          .where((e) => e != null && e is Map)
          .map((e) => ChatMember.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .where((e) => e != null && e is Map)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      lastMessage: lastMessageJson is Map
          ? ChatRoomLastMessage.fromJson(
              Map<String, dynamic>.from(lastMessageJson),
            )
          : null,
    );
  }

  ChatRoom copyWith({
    String? roomId,
    String? typeRoom,
    String? title,
    String? avatar,
    String? status,
    String? theme,
    List<ChatMember>? members,
    List<ChatMessage>? messages,
    ChatRoomLastMessage? lastMessage,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      typeRoom: typeRoom ?? this.typeRoom,
      title: title ?? this.title,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
