class ChatUser {
  final String id;
  final String fullName;
  final String? avatar;

  ChatUser({required this.id, required this.fullName, this.avatar});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}
