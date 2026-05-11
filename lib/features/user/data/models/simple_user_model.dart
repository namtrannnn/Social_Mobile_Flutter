class SimpleUserModel {
  final String id;
  final String fullName;
  final String username;
  final String avatar;
  final bool isVerified;

  SimpleUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
  });

  factory SimpleUserModel.fromJson(Map<String, dynamic> json) {
    return SimpleUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}
