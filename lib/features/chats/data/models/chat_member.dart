import 'chat_user.dart';

class ChatMember {
  final String? userId;
  final String role;
  final ChatUser user;

  ChatMember({this.userId, required this.role, required this.user});

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['user'])
        : Map<String, dynamic>.from(json);

    return ChatMember(
      userId: json['user_id']?.toString(),
      role: (json['role'] ?? 'member').toString(),
      user: ChatUser.fromJson(userJson),
    );
  }

  ChatMember copyWith({String? userId, String? role, ChatUser? user}) {
    return ChatMember(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      user: user ?? this.user,
    );
  }
}
