import 'chat_user.dart';

class ChatMember {
  final String? userId;
  final ChatUser user;

  ChatMember({this.userId, required this.user});

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return ChatMember(
      userId: json['user_id']?.toString(),
      user: ChatUser.fromJson(userJson),
    );
  }
}
