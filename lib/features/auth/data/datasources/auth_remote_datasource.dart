import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../app/config/api_config.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return LoginResponseModel.fromJson(data);
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return RegisterResponseModel.fromJson(data);
  }
}
