import 'chat_member.dart';
import 'chat_message.dart';

class ChatRoom {
  final String roomId;
  final String typeRoom; // friend | group
  final String? title;
  final List<ChatMember> members;
  final List<ChatMessage> messages;

  ChatRoom({
    required this.roomId,
    required this.typeRoom,
    this.title,
    required this.members,
    required this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: (json['roomId'] ?? json['_id'] ?? '').toString(),
      typeRoom: (json['typeRoom'] ?? 'friend').toString(),
      title: json['title']?.toString(),
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => ChatMember.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  ChatRoom copyWith({
    String? roomId,
    String? typeRoom,
    String? title,
    List<ChatMember>? members,
    List<ChatMessage>? messages,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      typeRoom: typeRoom ?? this.typeRoom,
      title: title ?? this.title,
      members: members ?? this.members,
      messages: messages ?? this.messages,
    );
  }
}
