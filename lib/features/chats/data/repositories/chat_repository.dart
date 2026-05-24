import 'dart:io';

import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatRepository {
  final ChatRemoteDatasource remote;

  ChatRepository({required this.remote});

  Future<List<ChatRoom>> getListFriendChat() async {
    return await remote.getListFriendChat();
  }

  Future<List<ChatMessage>> getMessagesByRoom({
    required String roomId,
    int page = 1,
    int limit = 30,
  }) async {
    return await remote.getMessagesByRoom(
      roomId: roomId,
      page: page,
      limit: limit,
    );
  }

  Future<ChatRoom> getOrCreateRoomChatFriend(String userId) async {
    return await remote.getOrCreateRoomChatFriend(userId);
  }

  Future<ChatRoom> createRoomChatGroup({
    required String title,
    required List<String> usersId,
  }) async {
    return await remote.createRoomChatGroup(title: title, usersId: usersId);
  }

  Future<List<Map<String, dynamic>>> searchPeopleToNewMessage(
    String keyword,
  ) async {
    return await remote.searchPeopleToNewMessage(keyword);
  }

  Future<Map<String, dynamic>> uploadImageToCloudinary(File file) async {
    return await remote.uploadImageToCloudinary(file);
  }

  Future<Map<String, dynamic>> uploadBytesToCloudinary(
    List<int> bytes,
    String fileName,
  ) async {
    return await remote.uploadBytesToCloudinary(bytes, fileName);
  }
}
