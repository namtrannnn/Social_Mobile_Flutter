import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ChatRemoteDatasource {
  Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _decodeResponse(http.Response response) async {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception('Response không phải JSON: ${response.body}');
    }
  }

  // GET /api/v1/chat
  Future<List<ChatRoom>> getListFriendChat() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chat');

    final response = await http.get(url, headers: await _headers());

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      final message = data is Map ? data['message'] : null;
      throw Exception(message ?? 'API chat lỗi: ${response.statusCode}');
    }

    if (data is! List) {
      throw Exception('Dữ liệu chat không phải List');
    }

    return data.where((e) => e != null && e is Map).map<ChatRoom>((e) {
      return ChatRoom.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  // GET /api/v1/chat/:roomId/messages?page=1&limit=30
  Future<List<ChatMessage>> getMessagesByRoom({
    required String roomId,
    int page = 1,
    int limit = 30,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/chat/$roomId/messages?page=$page&limit=$limit',
    );

    final response = await http.get(url, headers: await _headers());

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      final message = data is Map ? data['message'] : null;
      throw Exception(
        message ?? 'API lấy tin nhắn lỗi: ${response.statusCode}',
      );
    }

    final messages = data is Map ? data['messages'] : null;

    if (messages is! List) {
      throw Exception('Dữ liệu messages không phải List');
    }

    return messages.where((e) => e != null && e is Map).map<ChatMessage>((e) {
      return ChatMessage.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  // POST /api/v1/room-chat/get-or-create-friend
  Future<ChatRoom> getOrCreateRoomChatFriend(String userId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/room-chat/get-or-create-friend',
    );

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'userId': userId}),
    );

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      final message = data is Map ? data['message'] : null;
      throw Exception(
        message ?? 'API get-or-create-friend lỗi: ${response.statusCode}',
      );
    }

    if (data is! Map) {
      throw Exception('Dữ liệu room không phải Object');
    }

    return ChatRoom.fromJson(Map<String, dynamic>.from(data));
  }

  // POST /api/v1/room-chat/create
  Future<ChatRoom> createRoomChatGroup({
    required String title,
    required List<String> usersId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/room-chat/create');

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'title': title, 'usersId': usersId}),
    );

    final data = await _decodeResponse(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = data is Map ? data['message'] : null;
      throw Exception(
        message ?? 'API create room group lỗi: ${response.statusCode}',
      );
    }

    if (data is! Map) {
      throw Exception('Dữ liệu group room không phải Object');
    }

    return ChatRoom.fromJson(Map<String, dynamic>.from(data));
  }

  // GET /api/v1/user/search?q=...
  // GET /api/v1/user/search?q=...
  Future<List<Map<String, dynamic>>> searchPeopleToNewMessage(
    String keyword,
  ) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword.trim());

    final url = Uri.parse('${ApiConfig.baseUrl}/user/search?q=$encodedKeyword');

    final response = await http.get(url, headers: await _headers());

    print('SEARCH CHAT USER URL: $url');
    print('SEARCH CHAT USER STATUS: ${response.statusCode}');
    print('SEARCH CHAT USER BODY: ${response.body}');

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      final message = data is Map ? data['message'] : null;
      throw Exception(
        message ?? 'API search user chat lỗi: ${response.statusCode}',
      );
    }

    final users = data is Map ? data['data'] : null;

    return (users as List? ?? []).where((e) => e != null && e is Map).map((e) {
      final user = Map<String, dynamic>.from(e as Map);

      return {'user': user};
    }).toList();
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

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception('Upload Cloudinary lỗi: ${response.statusCode}');
    }

    if (data is! Map) {
      throw Exception('Cloudinary response không phải Object');
    }

    return Map<String, dynamic>.from(data);
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

    final data = await _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception('Upload bytes Cloudinary lỗi: ${response.statusCode}');
    }

    if (data is! Map) {
      throw Exception('Cloudinary response không phải Object');
    }

    return Map<String, dynamic>.from(data);
  }
}
