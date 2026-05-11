import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat_room.dart';
import '../../../../app/config/api_config.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ChatRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatRoom>> getListFriendChat() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chat');

    final response = await http.get(url, headers: await _headers());

    print("🔥 CHAT API STATUS: ${response.statusCode}");
    print("🔥 CHAT API BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('API chat lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu chat không phải List');
    }

    return data.map<ChatRoom>((e) {
      return ChatRoom.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  Future<Map<String, dynamic>> getOrCreateRoomChatFriend(String userId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/room-chat/get-or-create-friend',
    );

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('API get-or-create-friend lỗi: ${response.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> createRoomChatGroup({
    required String title,
    required List<String> usersId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/room-chat/create');

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'title': title, 'usersId': usersId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('API create room group lỗi: ${response.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> searchPeopleToNewMessage(
    String keyword,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/users/search-people-to-new-message?keyword=$keyword',
    );

    final response = await http.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('API search user chat lỗi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final friends = (data['friends'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return friends;
  }

  Future<Map<String, dynamic>> uploadImageToCloudinary(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/dn2u3dcrh/upload'),
    );

    request.fields['upload_preset'] = 'p2qqbz5d';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload Cloudinary lỗi: ${response.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> uploadBytesToCloudinary(
    List<int> bytes,
    String fileName,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/dn2u3dcrh/upload'),
    );

    request.fields['upload_preset'] = 'p2qqbz5d';
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload bytes Cloudinary lỗi: ${response.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
