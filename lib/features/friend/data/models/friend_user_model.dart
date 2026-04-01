class FriendUserModel {
  final String id;
  final String fullName;
  final String avatar;

  FriendUserModel({
    required this.id,
    required this.fullName,
    required this.avatar,
  });

  factory FriendUserModel.fromJson(Map<String, dynamic> json) {
    return FriendUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
