class NotificationModel {
  final String id;

  final NotificationUser sender;

  final String type;

  final String title;

  final String message;

  final String? refId;

  final String? refType;

  final bool isRead;

  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.sender,
    required this.type,
    required this.title,
    required this.message,
    required this.refId,
    required this.refType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',

      sender: NotificationUser.fromJson(json['sender'] ?? {}),

      type: json['type'] ?? '',

      title: json['title'] ?? '',

      message: json['message'] ?? '',

      refId: json['refId'],

      refType: json['refType'],

      isRead: json['isRead'] ?? false,

      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationUser {
  final String id;

  final String fullName;

  final String username;

  final String avatar;

  final bool isVerified;

  NotificationUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.isVerified,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['_id'] ?? '',

      fullName: json['fullName'] ?? '',

      username: json['username'] ?? '',

      avatar: json['avatar'] ?? '',

      isVerified: json['isVerified'] ?? false,
    );
  }
}
