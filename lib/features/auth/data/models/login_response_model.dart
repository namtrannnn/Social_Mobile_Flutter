import 'user_model.dart';

class LoginResponseModel {
  final int code;
  final String message;
  final String? tokenUser;
  final UserModel? user;

  LoginResponseModel({
    required this.code,
    required this.message,
    required this.tokenUser,
    required this.user,
  });

  bool get isSuccess => code == 200;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      code: json['code'] ?? 400,
      message: json['message'] ?? 'Có lỗi xảy ra',
      tokenUser: json['tokenUser'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
