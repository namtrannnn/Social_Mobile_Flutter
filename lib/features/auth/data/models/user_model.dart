class FriendListItem {
  final String userId;
  final String roomChatId;

  FriendListItem({required this.userId, required this.roomChatId});

  factory FriendListItem.fromJson(Map<String, dynamic> json) {
    return FriendListItem(
      userId: json['user_id']?.toString() ?? '',
      roomChatId: json['room_chat_id']?.toString() ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String tokenUser;
  final String avatar;
  final String status;
  final int? position;
  final bool isVerified;
  final String role;
  final String statusOnline;
  final List<String> requestFriends;
  final List<String> acceptFriends;
  final List<FriendListItem> friendList;
  final bool deleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.tokenUser,
    required this.avatar,
    required this.status,
    required this.position,
    required this.isVerified,
    required this.role,
    required this.statusOnline,
    required this.requestFriends,
    required this.acceptFriends,
    required this.friendList,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final friendListRaw = json['friendList'] as List<dynamic>? ?? [];

    return UserModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      tokenUser: json['tokenUser'] ?? '',
      avatar: json['avatar'] ?? '',
      status: json['status'] ?? 'active',
      position: json['position'],
      isVerified: json['isVerified'] ?? false,
      role: json['role'] ?? 'user',
      statusOnline: json['statusOnline'] ?? '',
      requestFriends: List<String>.from(json['requestFriends'] ?? []),
      acceptFriends: List<String>.from(json['acceptFriends'] ?? []),
      friendList: friendListRaw
          .map((e) => FriendListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      deleted: json['deleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
