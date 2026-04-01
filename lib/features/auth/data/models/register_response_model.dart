import 'user_model.dart';

class RegisterResponseModel {
  final int code;
  final String message;
  final UserModel? user;

  RegisterResponseModel({
    required this.code,
    required this.message,
    required this.user,
  });

  bool get isSuccess => code == 200;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      code: json['code'] ?? 400,
      message: json['message'] ?? 'Có lỗi xảy ra',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
