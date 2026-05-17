import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/friend_user_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage_service.dart';

class FriendRemoteDataSource {
  Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<FriendUserModel>> getSuggestions() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/not-friend');
    final response = await http.get(url, headers: await _headers());

    // print('getSuggestions URL: $url');
    // print('getSuggestions status: ${response.statusCode}');
    // print('getSuggestions body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('API suggestions lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu suggestions không phải List');
    }

    return data.map<FriendUserModel>((e) {
      return FriendUserModel.fromJson(e);
    }).toList();
  }

  Future<List<FriendUserModel>> getAcceptFriends() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/accept');
    final response = await http.get(url, headers: await _headers());

    // print('getAcceptFriends URL: $url');
    // print('getAcceptFriends status: ${response.statusCode}');
    // print('getAcceptFriends body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('API accept lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu accept không phải List');
    }

    return data.map<FriendUserModel>((e) {
      return FriendUserModel.fromJson(e);
    }).toList();
  }

  Future<List<FriendUserModel>> getRequestFriends() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/request');
    final response = await http.get(url, headers: await _headers());

    // print('getRequestFriends URL: $url');
    // print('getRequestFriends status: ${response.statusCode}');
    // print('getRequestFriends body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('API request lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu request không phải List');
    }

    return data.map<FriendUserModel>((e) {
      return FriendUserModel.fromJson(e);
    }).toList();
  }

  Future<List<FriendUserModel>> getListFriends() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/friends');
    final response = await http.get(url, headers: await _headers());

    // print('getListFriends URL: $url');
    // print('getListFriends status: ${response.statusCode}');
    // print('getListFriends body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('API friends lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu friends không phải List');
    }

    return data.map<FriendUserModel>((e) {
      return FriendUserModel.fromJson(e);
    }).toList();
  }

  Future<void> addFriend(String userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/add-friend/$userId');
    await http.post(url, headers: await _headers());
  }

  Future<void> acceptFriend(String userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/accept-friend/$userId');
    await http.post(url, headers: await _headers());
  }

  Future<void> refuseFriend(String userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/refuse-friend/$userId');
    await http.post(url, headers: await _headers());
  }

  Future<void> cancelFriend(String userId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/cancel-friend/$userId');
    await http.post(url, headers: await _headers());
  }
}
