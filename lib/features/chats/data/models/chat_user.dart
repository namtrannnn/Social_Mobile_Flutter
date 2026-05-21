class ChatUser {
  final String id;
  final String fullName;
  final String? username;
  final String? avatar;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastActiveAt;
  ChatUser({
    required this.id,
    required this.fullName,
    this.username,
    this.avatar,
    this.isVerified = false,
    this.isOnline = false,
    this.lastActiveAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == true) return true;
      if (value == 1) return true;
      if (value?.toString().toLowerCase() == 'true') return true;
      return false;
    }

    return ChatUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      isVerified: parseBool(json['isVerified']),
      isOnline: parseBool(json['isOnline']),
      lastActiveAt: DateTime.tryParse(json['lastActiveAt']?.toString() ?? ''),
    );
  }

  ChatUser copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatar,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastActiveAt,
  }) {
    return ChatUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'avatar': avatar,
      'isVerified': isVerified,
      'isOnline': isOnline,
    };
  }
}
