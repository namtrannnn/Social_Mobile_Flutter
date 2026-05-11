import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../datasources/chat_remote_datasource.dart';

import '../../../../core/services/chat_socket_service.dart';

import '../models/chat_member.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/chat_user.dart';

class ChatController extends ChangeNotifier {
  final ChatRemoteDatasource remote;
  final ChatSocketService socketService;

  ChatController({required this.remote, required this.socketService});

  List<ChatRoom> roomList = [];
  List<ChatRoom> sourceRoomList = [];
  ChatRoom? currentRoomData;
  ChatUser? receiveUser;
  List<ChatMessage> allMessenger = [];

  List<Map<String, dynamic>> listPeopleToNewMessage = [];
  List<Map<String, dynamic>> listResultByPeopleSearch = [];

  String textSearchNewMessage = '';
  String text = '';
  bool loading = false;
  bool isNewMessage = false;
  bool isGroup = false;

  XFile? pickedImage;

  ChatUser? currentUser;

  void initSocket({required String baseUrl, required String tokenUser}) {
    // socketService.connect(baseUrl: baseUrl, tokenUser: tokenUser);
    socketService.onServerReturnMessage((data) {
      final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
      _changeAllMessages(msg);
    });
  }

  Future<void> initData({required ChatUser me}) async {
    currentUser = me;

    print('================ INIT DATA ================');
    print('currentUser.id: ${currentUser?.id}');
    print('currentUser.fullName: ${currentUser?.fullName}');
    print('currentUser.avatar: ${currentUser?.avatar}');

    final rooms = await remote.getListFriendChat();

    print('rooms.length: ${rooms.length}');
    for (final room in rooms) {
      print('------------------------------------------');
      print('roomId: ${room.roomId}');
      print('typeRoom: ${room.typeRoom}');
      print('members: ${room.members.length}');
      for (final m in room.members) {
        print('member.userId: ${m.userId}');
        print('member.user.id: ${m.user.id}');
        print('member.user.fullName: ${m.user.fullName}');
      }
      print('messages: ${room.messages.length}');
      for (final msg in room.messages) {
        print('msg.id: ${msg.id}');
        print('msg.userId: ${msg.userId}');
        print('msg.content: ${msg.content}');
        print('msg.roomChatId: ${msg.roomChatId}');
        print('createdAt: ${msg.createdAt}');
      }
    }

    rooms.sort((a, b) {
      final lastA = a.messages.isNotEmpty
          ? a.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      final lastB = b.messages.isNotEmpty
          ? b.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      return lastB.compareTo(lastA);
    });

    roomList = rooms;
    sourceRoomList = rooms;

    if (rooms.isNotEmpty) {
      selectRoom(rooms.first);
    }
    notifyListeners();
  }

  void selectRoom(ChatRoom room) {
    currentRoomData = room;
    allMessenger = [...room.messages];
    isGroup = room.typeRoom == 'group';
    isNewMessage = false;

    if (room.typeRoom == 'friend' && currentUser != null) {
      final other = room.members
          .map((e) => e.user)
          .firstWhere(
            (u) => u.id != currentUser!.id,
            orElse: () => room.members.first.user,
          );
      receiveUser = other;
    } else {
      receiveUser = null;
    }

    socketService.joinRoom(room.roomId);
    notifyListeners();
  }

  void openNewMessage() {
    isNewMessage = true;
    isGroup = false;
    currentRoomData = null;
    receiveUser = null;
    allMessenger = [];
    notifyListeners();
  }

  void closeNewMessage() {
    isNewMessage = false;
    roomList = sourceRoomList;
    notifyListeners();
  }

  Future<void> searchPeople(String keyword) async {
    textSearchNewMessage = keyword;
    if (keyword.trim().isEmpty) {
      listPeopleToNewMessage = [];
      notifyListeners();
      return;
    }

    final rs = await remote.searchPeopleToNewMessage(keyword.trim());
    listPeopleToNewMessage = rs;
    notifyListeners();
  }

  void addPeopleResult(Map<String, dynamic> item) {
    final exists = listResultByPeopleSearch.any(
      (e) => e['user']?['_id']?.toString() == item['user']?['_id']?.toString(),
    );
    if (!exists) {
      listResultByPeopleSearch.add(item);
    }
    textSearchNewMessage = '';
    listPeopleToNewMessage = [];
    notifyListeners();
  }

  void removePeopleResult(String userId) {
    listResultByPeopleSearch.removeWhere(
      (e) => e['user']?['_id']?.toString() == userId,
    );
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      throw Exception('Ảnh không vượt quá 2MB');
    }

    pickedImage = file;
    notifyListeners();
  }

  void removeImage() {
    pickedImage = null;
    notifyListeners();
  }

  String _getLastName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isEmpty ? '' : parts.last;
  }

  String _makeGroupTitle() {
    if (listResultByPeopleSearch.isEmpty) return 'Nhóm mới';

    final names = listResultByPeopleSearch
        .map((u) => _getLastName(u['user']['fullName'].toString()))
        .toList();

    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]}, ${names[1]}';
    return '${names[0]}, ${names[1]} +${names.length - 2}';
  }

  Future<void> sendCurrentMessage() async {
    if (currentUser == null) return;
    if (text.trim().isEmpty && pickedImage == null) return;

    loading = true;
    notifyListeners();

    try {
      String? roomChatId = currentRoomData?.roomId;
      bool nextIsGroup = isGroup;

      ChatImage? uploadedImage;

      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final result = kIsWeb
            ? await remote.uploadBytesToCloudinary(bytes, pickedImage!.name)
            : await remote.uploadBytesToCloudinary(bytes, pickedImage!.name);

        uploadedImage = ChatImage(
          url: result['url'].toString(),
          publicId: result['public_id']?.toString(),
        );
      }

      if (roomChatId == null && isNewMessage) {
        if (listResultByPeopleSearch.length == 1) {
          final picked = listResultByPeopleSearch.first;
          final toUserId = picked['user']?['_id']?.toString();

          if (toUserId == null || toUserId.isEmpty) {
            throw Exception('Thiếu userId người nhận');
          }

          roomChatId = picked['roomChatId']?.toString();
          if (roomChatId == null || roomChatId.isEmpty) {
            final rs = await remote.getOrCreateRoomChatFriend(toUserId);
            roomChatId = rs['_id']?.toString();
          }

          nextIsGroup = false;
        } else {
          final usersId = listResultByPeopleSearch
              .map((e) => e['user']['_id'].toString())
              .toList();

          final newRoom = await remote.createRoomChatGroup(
            title: _makeGroupTitle(),
            usersId: usersId,
          );

          roomChatId = newRoom['_id']?.toString();
          nextIsGroup = true;

          currentRoomData = ChatRoom(
            roomId: roomChatId ?? '',
            typeRoom: 'group',
            title: newRoom['title']?.toString(),
            members: (newRoom['members'] as List<dynamic>? ?? [])
                .map((e) => ChatMember.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
            messages: [],
          );
        }
      }

      if (roomChatId == null || roomChatId.isEmpty) {
        throw Exception('Thiếu roomChatId để gửi');
      }

      final newMessage = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}',
        userId: currentUser!.id,
        roomChatId: roomChatId,
        content: text.trim().isEmpty ? null : text.trim(),
        images: uploadedImage != null ? [uploadedImage] : [],
        createdAt: DateTime.now(),
        user: {
          '_id': currentUser!.id,
          'avatar': currentUser!.avatar,
          'fullName': currentUser!.fullName,
        },
      );

      _handleSendMessageLocal(newMessage, nextIsGroup);
      socketService.joinRoom(roomChatId);
      socketService.sendMessage(newMessage.toSocketJson());

      text = '';
      pickedImage = null;
      isGroup = nextIsGroup;
      isNewMessage = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _handleSendMessageLocal(ChatMessage message, bool nextIsGroup) {
    allMessenger = [...allMessenger, message];

    bool found = false;
    final updatedRooms = roomList.map((room) {
      if (room.roomId == message.roomChatId) {
        found = true;
        final next = room.copyWith(messages: [...room.messages, message]);
        return next;
      }
      return room;
    }).toList();

    if (!found) {
      final newRoom = ChatRoom(
        roomId: message.roomChatId,
        typeRoom: nextIsGroup ? 'group' : 'friend',
        title: currentRoomData?.title,
        members: currentRoomData?.members ?? [],
        messages: [message],
      );
      updatedRooms.insert(0, newRoom);
      currentRoomData = newRoom;
    }

    updatedRooms.sort((a, b) {
      final lastA = a.messages.isNotEmpty
          ? a.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      final lastB = b.messages.isNotEmpty
          ? b.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      return lastB.compareTo(lastA);
    });

    roomList = updatedRooms;
    sourceRoomList = updatedRooms;
  }

  void _changeAllMessages(ChatMessage incoming) {
    final roomId = incoming.roomChatId;
    if (roomId.isEmpty) return;

    bool found = false;
    final updated = roomList.map((room) {
      if (room.roomId == roomId) {
        found = true;
        return room.copyWith(messages: [...room.messages, incoming]);
      }
      return room;
    }).toList();

    if (!found) {
      updated.insert(
        0,
        ChatRoom(
          roomId: roomId,
          typeRoom: 'friend',
          title: '',
          members: [],
          messages: [incoming],
        ),
      );
    }

    updated.sort((a, b) {
      final lastA = a.messages.isNotEmpty
          ? a.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      final lastB = b.messages.isNotEmpty
          ? b.messages.last.createdAt.millisecondsSinceEpoch
          : 0;
      return lastB.compareTo(lastA);
    });

    roomList = updated;
    sourceRoomList = updated;

    if (currentRoomData?.roomId == roomId) {
      allMessenger = [...allMessenger, incoming];
    }

    notifyListeners();
  }

  @override
  void dispose() {
    socketService.removeServerReturnMessage();
    super.dispose();
  }
}
