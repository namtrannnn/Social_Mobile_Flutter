import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/socket_service.dart';

import '../../data/models/chat_message.dart';
import '../../data/models/chat_room.dart';
import '../../data/models/chat_user.dart';
import '../../data/repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository repository;
  final SocketService socketService;

  ChatController({required this.repository, required this.socketService});

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
  bool isLoadingRooms = false;
  bool isNewMessage = false;
  bool isGroup = false;

  XFile? pickedImage;

  ChatUser? currentUser;

  bool _socketInited = false;

  // =========================
  // TYPING STATUS
  // =========================

  bool isReceiveTyping = false;
  String? typingRoomId;
  String? typingUserId;
  String? typingFullName;

  bool _isMeTyping = false;
  Timer? _typingTimer;
  Timer? _receiveTypingTimer;

  // =========================
  // INIT SOCKET
  // =========================

  void initSocket() {
    if (_socketInited) return;
    _socketInited = true;

    socketService.listenChatMessage((data) {
      final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
      _changeAllMessages(msg);
    });

    socketService.listenChatError((data) {
      debugPrint('❌ CHAT ERROR: $data');
    });
    socketService.listenTypingStart((data) {
      _handleTypingStart(data);
    });

    socketService.listenTypingStop((data) {
      _handleTypingStop(data);
    });
    socketService.listenUserOnline((data) {
      final userId = data['userId']?.toString();
      if (userId != null && userId.isNotEmpty) {
        updateUserOnlineStatus(userId, true);
      }
    });

    socketService.listenUserOffline((data) {
      final userId = data['userId']?.toString();
      final lastActiveAt = DateTime.tryParse(
        data['lastActiveAt']?.toString() ?? '',
      );

      if (userId != null && userId.isNotEmpty) {
        updateUserOnlineStatus(userId, false, lastActiveAt: lastActiveAt);
      }
    });
  }

  // =========================
  // INIT DATA
  // =========================

  Future<void> initData({required ChatUser me}) async {
    currentUser = me;
    initSocket();

    isLoadingRooms = true;
    notifyListeners();

    try {
      final rooms = await repository.getListFriendChat();

      rooms.sort(_sortRoomByLastMessageDesc);

      roomList = rooms;
      sourceRoomList = rooms;

      // Mobile thường nên để null để hiện list chat trước.
      // Nếu bạn muốn tự động mở room đầu tiên thì mở comment đoạn này.
      /*
      if (rooms.isNotEmpty) {
        selectRoom(rooms.first);
      }
      */
    } finally {
      isLoadingRooms = false;
      notifyListeners();
    }
  }

  // =========================
  // SELECT ROOM
  // =========================

  void selectRoom(ChatRoom room) {
    currentRoomData = room;
    allMessenger = [...room.messages];

    isGroup = room.typeRoom == 'group';
    isNewMessage = false;

    _resolveReceiveUser(room);

    socketService.joinRoom(room.roomId);

    isReceiveTyping = false;
    typingRoomId = null;
    typingUserId = null;
    typingFullName = null;
    _receiveTypingTimer?.cancel();

    notifyListeners();
  }

  Future<void> selectRoomAndLoadMessages(ChatRoom room) async {
    selectRoom(room);

    try {
      final messages = await repository.getMessagesByRoom(
        roomId: room.roomId,
        page: 1,
        limit: 30,
      );

      allMessenger = messages;

      roomList = roomList.map((item) {
        if (item.roomId == room.roomId) {
          return item.copyWith(messages: messages);
        }
        return item;
      }).toList();

      sourceRoomList = roomList;

      currentRoomData = room.copyWith(messages: messages);

      notifyListeners();
    } catch (e) {
      debugPrint('Load messages error: $e');
    }
  }

  void _resolveReceiveUser(ChatRoom room) {
    if (room.typeRoom == 'friend' && currentUser != null) {
      final others = room.members
          .map((e) => e.user)
          .where((u) => u.id != currentUser!.id)
          .toList();

      receiveUser = others.isNotEmpty ? others.first : null;
    } else {
      receiveUser = null;
    }
  }

  // =========================
  // NEW MESSAGE MODE
  // =========================

  void openNewMessage() {
    isNewMessage = true;
    isGroup = false;
    currentRoomData = null;
    receiveUser = null;
    allMessenger = [];
    listPeopleToNewMessage = [];
    listResultByPeopleSearch = [];
    textSearchNewMessage = '';
    notifyListeners();
  }

  void _stopTypingState() {
    _typingTimer?.cancel();
    _receiveTypingTimer?.cancel();

    _isMeTyping = false;
    isReceiveTyping = false;
    typingRoomId = null;
    typingUserId = null;
    typingFullName = null;
  }

  void backToRoomList() {
    final roomId = currentRoomData?.roomId;
    if (roomId != null && roomId.isNotEmpty) {
      _stopMeTyping(roomId);
    }

    currentRoomData = null;
    isNewMessage = false;
    receiveUser = null;
    allMessenger = [];

    _stopTypingState();

    notifyListeners();
  }

  void closeNewMessage() {
    isNewMessage = false;
    roomList = sourceRoomList;
    listPeopleToNewMessage = [];
    listResultByPeopleSearch = [];
    textSearchNewMessage = '';
    notifyListeners();
  }

  // =========================
  // SEARCH PEOPLE
  // =========================

  Future<void> searchPeople(String keyword) async {
    textSearchNewMessage = keyword;

    if (keyword.trim().isEmpty) {
      listPeopleToNewMessage = [];
      notifyListeners();
      return;
    }

    final rs = await repository.searchPeopleToNewMessage(keyword.trim());
    listPeopleToNewMessage = rs;

    notifyListeners();
  }

  void addPeopleResult(Map<String, dynamic> item) {
    final userId = item['user']?['_id']?.toString();

    if (userId == null || userId.isEmpty) return;

    final exists = listResultByPeopleSearch.any(
      (e) => e['user']?['_id']?.toString() == userId,
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

  // =========================
  // PICK IMAGE
  // =========================

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

  // =========================
  // SEND MESSAGE
  // =========================

  Future<void> sendCurrentMessage() async {
    if (currentUser == null) return;
    if (text.trim().isEmpty && pickedImage == null) return;

    loading = true;
    notifyListeners();

    try {
      String? roomChatId = currentRoomData?.roomId;
      bool nextIsGroup = isGroup;
      ChatRoom? roomForNewMessage;

      ChatImage? uploadedImage;

      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();

        final result = await repository.uploadBytesToCloudinary(
          bytes,
          pickedImage!.name,
        );

        uploadedImage = ChatImage(
          url: result['url'].toString(),
          publicId: result['public_id']?.toString(),
        );
      }

      // Nếu đang ở màn hình tạo tin nhắn mới thì tạo/lấy room trước.
      if ((roomChatId == null || roomChatId.isEmpty) && isNewMessage) {
        if (listResultByPeopleSearch.isEmpty) {
          throw Exception('Bạn chưa chọn người nhận');
        }

        if (listResultByPeopleSearch.length == 1) {
          final picked = listResultByPeopleSearch.first;
          final toUserId = picked['user']?['_id']?.toString();

          if (toUserId == null || toUserId.isEmpty) {
            throw Exception('Thiếu userId người nhận');
          }

          roomForNewMessage = await repository.getOrCreateRoomChatFriend(
            toUserId,
          );

          roomChatId = roomForNewMessage.roomId;
          nextIsGroup = false;
        } else {
          final usersId = listResultByPeopleSearch
              .map((e) => e['user']?['_id']?.toString())
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList();

          roomForNewMessage = await repository.createRoomChatGroup(
            title: _makeGroupTitle(),
            usersId: usersId,
          );

          roomChatId = roomForNewMessage.roomId;
          nextIsGroup = true;
        }

        currentRoomData = roomForNewMessage;
        if (roomForNewMessage != null) {
          _resolveReceiveUser(roomForNewMessage);
        }
      }

      if (roomChatId == null || roomChatId.isEmpty) {
        throw Exception('Thiếu roomChatId để gửi');
      }

      final localMessage = ChatMessage(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}',
        userId: currentUser!.id,
        roomChatId: roomChatId,
        content: text.trim().isEmpty ? null : text.trim(),
        images: uploadedImage != null ? [uploadedImage] : [],
        createdAt: DateTime.now(),
        user: {
          '_id': currentUser!.id,
          'avatar': currentUser!.avatar,
          'fullName': currentUser!.fullName,
          'username': currentUser!.username,
          'isVerified': currentUser!.isVerified,
        },
      );

      _stopMeTyping(roomChatId);
      _handleSendMessageLocal(
        localMessage,
        nextIsGroup,
        roomForNewMessage: roomForNewMessage,
      );

      socketService.joinRoom(roomChatId);
      socketService.sendMessage(localMessage.toSocketJson());

      text = '';
      pickedImage = null;
      isGroup = nextIsGroup;
      isNewMessage = false;
      listPeopleToNewMessage = [];
      listResultByPeopleSearch = [];
      textSearchNewMessage = '';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _handleSendMessageLocal(
    ChatMessage message,
    bool nextIsGroup, {
    ChatRoom? roomForNewMessage,
  }) {
    allMessenger = [...allMessenger, message];

    bool found = false;

    final updatedRooms = roomList.map((room) {
      if (room.roomId == message.roomChatId) {
        found = true;

        return room.copyWith(
          messages: [...room.messages, message],
          lastMessage: ChatRoomLastMessage(
            messageId: message.id,
            sender: message.userId,
            content: message.content ?? '',
            imagesCount: message.images.length,
            createdAt: message.createdAt,
          ),
        );
      }

      return room;
    }).toList();

    if (!found) {
      final newRoom =
          roomForNewMessage?.copyWith(
            messages: [message],
            lastMessage: ChatRoomLastMessage(
              messageId: message.id,
              sender: message.userId,
              content: message.content ?? '',
              imagesCount: message.images.length,
              createdAt: message.createdAt,
            ),
          ) ??
          ChatRoom(
            roomId: message.roomChatId,
            typeRoom: nextIsGroup ? 'group' : 'friend',
            title: currentRoomData?.title,
            avatar: currentRoomData?.avatar,
            status: currentRoomData?.status,
            theme: currentRoomData?.theme,
            members: currentRoomData?.members ?? [],
            messages: [message],
            lastMessage: ChatRoomLastMessage(
              messageId: message.id,
              sender: message.userId,
              content: message.content ?? '',
              imagesCount: message.images.length,
              createdAt: message.createdAt,
            ),
          );

      updatedRooms.insert(0, newRoom);
      currentRoomData = newRoom;
    }

    updatedRooms.sort(_sortRoomByLastMessageDesc);

    roomList = updatedRooms;
    sourceRoomList = updatedRooms;
  }
  // =========================
  // TYPING
  // =========================

  void onMessageTextChanged(String value) {
    text = value;

    final roomId = currentRoomData?.roomId;

    if (roomId == null || roomId.isEmpty) {
      notifyListeners();
      return;
    }

    final content = value.trim();

    // Nếu ô input rỗng thì stop typing ngay
    if (content.isEmpty) {
      _stopMeTyping(roomId);
      notifyListeners();
      return;
    }

    // Bắt đầu typing: chỉ emit START một lần
    if (!_isMeTyping) {
      _isMeTyping = true;
      socketService.emitTypingStart(roomId);
    }

    // Mỗi lần gõ thì reset timer 3s
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopMeTyping(roomId);
    });

    notifyListeners();
  }

  void _stopMeTyping(String roomId) {
    _typingTimer?.cancel();

    if (_isMeTyping) {
      _isMeTyping = false;
      socketService.emitTypingStop(roomId);
    }
  }

  void _handleTypingStart(dynamic data) {
    final map = Map<String, dynamic>.from(data);

    final roomId = map['room_chat_id']?.toString();
    final userId = map['user_id']?.toString();

    if (roomId == null || roomId.isEmpty) return;
    if (userId == null || userId.isEmpty) return;

    // Không hiện typing của chính mình
    if (currentUser != null && userId == currentUser!.id) return;

    // Chỉ hiện typing nếu đang mở đúng room đó
    if (currentRoomData?.roomId != roomId) return;

    isReceiveTyping = true;
    typingRoomId = roomId;
    typingUserId = userId;
    typingFullName = map['fullName']?.toString();

    _receiveTypingTimer?.cancel();

    // Nếu bên kia bị mất mạng/chưa emit STOP thì sau 3s tự tắt
    _receiveTypingTimer = Timer(const Duration(seconds: 3), () {
      isReceiveTyping = false;
      typingRoomId = null;
      typingUserId = null;
      typingFullName = null;
      notifyListeners();
    });

    notifyListeners();
  }

  void _handleTypingStop(dynamic data) {
    final map = Map<String, dynamic>.from(data);

    final roomId = map['room_chat_id']?.toString();
    final userId = map['user_id']?.toString();

    if (roomId == null || roomId.isEmpty) return;
    if (userId == null || userId.isEmpty) return;

    if (currentRoomData?.roomId != roomId) return;

    _receiveTypingTimer?.cancel();

    isReceiveTyping = false;
    typingRoomId = null;
    typingUserId = null;
    typingFullName = null;

    notifyListeners();
  }

  // =========================
  // RECEIVE MESSAGE REALTIME
  // =========================
  bool _isSameOutgoingLocalMessage(ChatMessage local, ChatMessage server) {
    if (!local.id.startsWith('local_')) return false;

    if (local.roomChatId != server.roomChatId) return false;
    if (local.userId != server.userId) return false;

    final localContent = (local.content ?? '').trim();
    final serverContent = (server.content ?? '').trim();

    if (localContent != serverContent) return false;
    if (local.images.length != server.images.length) return false;

    if (local.images.isNotEmpty && server.images.isNotEmpty) {
      for (int i = 0; i < local.images.length; i++) {
        if (local.images[i].url != server.images[i].url) {
          return false;
        }
      }
    }

    final diffSeconds = local.createdAt
        .difference(server.createdAt)
        .inSeconds
        .abs();

    return diffSeconds <= 60;
  }

  List<ChatMessage> _replaceOrAppendMessage(
    List<ChatMessage> messages,
    ChatMessage incoming,
  ) {
    final existsByRealId = messages.any((m) => m.id == incoming.id);

    if (existsByRealId) {
      return messages;
    }

    final localIndex = messages.indexWhere(
      (m) => _isSameOutgoingLocalMessage(m, incoming),
    );

    if (localIndex != -1) {
      final next = [...messages];
      next[localIndex] = incoming;
      return next;
    }

    return [...messages, incoming];
  }

  void _changeAllMessages(ChatMessage incoming) {
    final roomId = incoming.roomChatId;

    if (roomId.isEmpty) return;

    bool found = false;

    final updated = roomList.map((room) {
      if (room.roomId == roomId) {
        found = true;

        final nextMessages = _replaceOrAppendMessage(room.messages, incoming);

        return room.copyWith(
          messages: nextMessages,
          lastMessage: ChatRoomLastMessage(
            messageId: incoming.id,
            sender: incoming.userId,
            content: incoming.content ?? '',
            imagesCount: incoming.images.length,
            createdAt: incoming.createdAt,
          ),
        );
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
          lastMessage: ChatRoomLastMessage(
            messageId: incoming.id,
            sender: incoming.userId,
            content: incoming.content ?? '',
            imagesCount: incoming.images.length,
            createdAt: incoming.createdAt,
          ),
        ),
      );
    }

    updated.sort(_sortRoomByLastMessageDesc);

    roomList = updated;
    sourceRoomList = updated;

    if (currentRoomData?.roomId == roomId) {
      allMessenger = _replaceOrAppendMessage(allMessenger, incoming);

      final matchedRoom = roomList.where((r) => r.roomId == roomId).toList();

      if (matchedRoom.isNotEmpty) {
        currentRoomData = matchedRoom.first;
      }
    }

    notifyListeners();
  }

  // =========================
  // ONLINE STATUS
  // =========================

  void updateUserOnlineStatus(
    String userId,
    bool isOnline, {
    DateTime? lastActiveAt,
  }) {
    ChatRoom updateRoom(ChatRoom room) {
      final nextMembers = room.members.map((member) {
        final id = member.userId ?? member.user.id;

        if (id == userId || member.user.id == userId) {
          return member.copyWith(
            user: member.user.copyWith(
              isOnline: isOnline,
              lastActiveAt: lastActiveAt,
            ),
          );
        }

        return member;
      }).toList();

      return room.copyWith(members: nextMembers);
    }

    roomList = roomList.map(updateRoom).toList();
    sourceRoomList = sourceRoomList.map(updateRoom).toList();

    if (currentRoomData != null) {
      currentRoomData = updateRoom(currentRoomData!);
      _resolveReceiveUser(currentRoomData!);
    }

    notifyListeners();
  }

  // =========================
  // HELPERS
  // =========================

  int _sortRoomByLastMessageDesc(ChatRoom a, ChatRoom b) {
    final lastA =
        a.lastMessage?.createdAt?.millisecondsSinceEpoch ??
        (a.messages.isNotEmpty
            ? a.messages.last.createdAt.millisecondsSinceEpoch
            : 0);

    final lastB =
        b.lastMessage?.createdAt?.millisecondsSinceEpoch ??
        (b.messages.isNotEmpty
            ? b.messages.last.createdAt.millisecondsSinceEpoch
            : 0);

    return lastB.compareTo(lastA);
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

  @override
  void dispose() {
    final roomId = currentRoomData?.roomId;
    if (roomId != null && roomId.isNotEmpty) {
      _stopMeTyping(roomId);
    }

    _typingTimer?.cancel();
    _receiveTypingTimer?.cancel();

    socketService.removeChatMessageListener();
    socketService.removeChatErrorListener();
    socketService.removeTypingListeners();
    socketService.removeOnlineStatusListeners();

    super.dispose();
  }
}
