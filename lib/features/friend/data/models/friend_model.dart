class FriendModel {
  final String id;
  final String fullName;
  final String? username;
  final String? avatar;
  final bool isVerified;
  final String? roomChatId;

  FriendModel({
    required this.id,
    required this.fullName,
    this.username,
    this.avatar,
    this.isVerified = false,
    this.roomChatId,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      isVerified: json['isVerified'] == true,
      roomChatId: json['roomChatId']?.toString(),
    );
  }
}
