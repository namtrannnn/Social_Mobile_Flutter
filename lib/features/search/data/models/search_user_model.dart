class SearchUserModel {
  final String id;
  final String fullName;
  final String? username;
  final String avatar;
  final bool isVerified;

  SearchUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'],
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}
