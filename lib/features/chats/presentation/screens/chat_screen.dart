import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/chat_controller.dart';
import '../../data/models/chat_room.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_user.dart';
import '../widgets/group_avatar_widget.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/config/api_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? _lastRoomId;
  int _lastMessageCount = 0;
  String? _lastMessageId;
  bool _keepPinnedToBottom = true;
  static const Color primaryColor = Color(0xff1877F2);
  static const Color bgColor = Color(0xffF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xffE5E7EB);
  static const Color mutedText = Color(0xff6B7280);

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      _keepPinnedToBottom = _isNearBottom();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chat = context.read<ChatController>();

      final token = await SecureStorageService.getValidToken();
      final userId = await SecureStorageService.getUserId();

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ Không tìm thấy token hợp lệ');
        return;
      }

      if (userId == null || userId.isEmpty) {
        debugPrint('⚠️ Không tìm thấy userId trong SecureStorage');
        return;
      }

      if (!chat.socketService.isConnected) {
        await chat.socketService.connect(
          baseUrl: ApiConfig.socketUrl,
          token: token,
        );
      }

      final me = ChatUser(
        id: userId,
        fullName: 'Bạn',
        avatar: null,
        isOnline: true,
      );

      await chat.initData(me: me);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  bool _isShowingRoomList(ChatController chat, bool isDesktop) {
    if (isDesktop) return false;
    return chat.currentRoomData == null && !chat.isNewMessage;
  }

  void _goBackToRoomList(ChatController chat) {
    _lastRoomId = null;
    _lastMessageCount = 0;
    _lastMessageId = null;

    chat.backToRoomList();
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) return true;

    if (scrollController.positions.length != 1) {
      return true;
    }

    final position = scrollController.position;
    final distanceToBottom = position.pixels - position.minScrollExtent;

    debugPrint(
      '📌 isNearBottom reversed: pixels=${position.pixels}, '
      'min=${position.minScrollExtent}, '
      'distance=$distanceToBottom',
    );

    return distanceToBottom <= 220;
  }

  void _scrollToBottom({bool animated = true}) {
    void runAfter(int milliseconds, {required bool useAnimation}) {
      Future.delayed(Duration(milliseconds: milliseconds), () {
        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!scrollController.hasClients) return;
          if (scrollController.positions.length != 1) return;

          final position = scrollController.position;
          final target = position.minScrollExtent;

          _keepPinnedToBottom = true;

          debugPrint(
            '⬇️ scrollToBottom reversed: animated=$useAnimation, '
            'pixels=${position.pixels}, min=${position.minScrollExtent}, max=${position.maxScrollExtent}',
          );

          if (useAnimation) {
            scrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          } else {
            scrollController.jumpTo(target);
          }
        });
      });
    }

    runAfter(0, useAnimation: false);
    runAfter(80, useAnimation: animated);
    runAfter(180, useAnimation: animated);
  }

  void _handleAutoScroll(ChatController chat) {
    final roomId = chat.currentRoomData?.roomId;
    final messages = chat.allMessenger;

    if (roomId == null || roomId.isEmpty) return;

    final messageCount = messages.length;
    final lastMessage = messages.isNotEmpty ? messages.last : null;
    final lastMessageId = lastMessage?.id;

    final isRoomChanged = _lastRoomId != roomId;

    final hasNewMessage =
        messageCount != _lastMessageCount ||
        (lastMessageId != null &&
            lastMessageId.isNotEmpty &&
            lastMessageId != _lastMessageId);

    final isMyNewMessage =
        hasNewMessage &&
        lastMessage != null &&
        lastMessage.userId == chat.currentUser?.id;

    if (isRoomChanged) {
      _keepPinnedToBottom = true;
    }

    final shouldScroll =
        isRoomChanged ||
        isMyNewMessage ||
        (hasNewMessage && _keepPinnedToBottom);

    _lastRoomId = roomId;
    _lastMessageCount = messageCount;
    _lastMessageId = lastMessageId;

    debugPrint(
      '🧭 autoScroll: '
      'roomChanged=$isRoomChanged, '
      'hasNew=$hasNewMessage, '
      'isMy=$isMyNewMessage, '
      'keepBottom=$_keepPinnedToBottom, '
      'should=$shouldScroll, '
      'count=$messageCount, '
      'lastId=$lastMessageId',
    );

    if (shouldScroll) {
      _scrollToBottom(animated: !isRoomChanged);
    }
  }

  Future<void> _openRoomFullScreen(
    ChatController chat,
    ChatRoom room,
    bool isDesktop,
  ) async {
    _lastRoomId = null;
    _lastMessageCount = 0;
    _lastMessageId = null;
    _keepPinnedToBottom = true;

    await chat.selectRoomAndLoadMessages(room);

    if (!mounted) return;

    _scrollToBottom(animated: false);
  }

  List<ChatUser> _getOnlineFriends(ChatController chat) {
    final Map<String, ChatUser> onlineMap = {};
    final myId = chat.currentUser?.id;

    for (final room in chat.roomList) {
      if (room.typeRoom != 'friend') continue;

      for (final member in room.members) {
        final user = member.user;

        if (user.id == myId) continue;

        if (user.isOnline) {
          onlineMap[user.id] = user;
        }
      }
    }

    return onlineMap.values.toList();
  }

  Widget _buildActiveFriendsBar(ChatController chat) {
    final onlineFriends = _getOnlineFriends(chat);

    if (onlineFriends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: cardColor,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'Đang hoạt động',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: onlineFriends.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final user = onlineFriends[index];

                return SizedBox(
                  width: 62,
                  child: Column(
                    children: [
                      _AvatarWithStatus(
                        imageUrl: user.avatar,
                        name: user.fullName,
                        radius: 25,
                        isOnline: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chat, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAutoScroll(chat);
        });

        final isDesktop = _isDesktop(context);
        final showingRoomList = _isShowingRoomList(chat, isDesktop);

        return PopScope(
          canPop: isDesktop || showingRoomList,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (!isDesktop && !showingRoomList) {
              _goBackToRoomList(chat);
            }
          },
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: _buildAppBar(
              context: context,
              chat: chat,
              isDesktop: isDesktop,
              showingRoomList: showingRoomList,
            ),
            body: SafeArea(
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          width: 360,
                          color: cardColor,
                          child: _buildRoomList(chat, isDesktop: true),
                        ),
                        const VerticalDivider(width: 1, color: borderColor),
                        Expanded(child: _buildChatArea(chat, isDesktop: true)),
                      ],
                    )
                  : showingRoomList
                  ? _buildRoomList(chat, isDesktop: false)
                  : _buildChatArea(chat, isDesktop: false),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required ChatController chat,
    required bool isDesktop,
    required bool showingRoomList,
  }) {
    final room = chat.currentRoomData;

    return AppBar(
      elevation: 0,
      backgroundColor: cardColor,
      surfaceTintColor: cardColor,
      automaticallyImplyLeading: false,
      leading: !isDesktop && !showingRoomList
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => _goBackToRoomList(chat),
            )
          : null,
      titleSpacing: !isDesktop && !showingRoomList ? 0 : 16,
      title: !isDesktop && !showingRoomList && room != null
          ? _buildChatTitleHeader(chat, room)
          : const Text(
              'Đoạn chat',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
      actions: [
        if (showingRoomList || isDesktop)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Tin nhắn mới',
              onPressed: () {
                chat.openNewMessage();
                if (!isDesktop) {
                  chat.currentRoomData = null;
                  chat.notifyListeners();
                }
              },
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: borderColor),
      ),
    );
  }

  Widget _buildChatTitleHeader(ChatController chat, ChatRoom room) {
    final avatar = _friendAvatar(chat, room);
    final title = _roomTitle(chat, room);
    final isOnline = chat.receiveUser?.isOnline == true;
    // debugPrint('======== ROOM ONLINE DEBUG ========');
    // debugPrint('roomId: ${room.roomId}');
    // debugPrint('title: $title');
    // debugPrint('currentUser: ${chat.currentUser?.id}');
    for (final member in room.members) {
      debugPrint(
        'memberId=${member.user.id} name=${member.user.fullName} online=${member.user.isOnline}',
      );
    }
    debugPrint('isOnline result: $isOnline');
    return Row(
      children: [
        _AvatarWithStatus(
          imageUrl: avatar,
          name: title,
          radius: 18,
          isOnline: room.typeRoom == 'friend' && isOnline,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              if (room.typeRoom == 'friend')
                Text(
                  _activityText(chat.receiveUser),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green : mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _activityText(ChatUser? user) {
    if (user == null) return '';

    if (user.isOnline) {
      return 'Đang hoạt động';
    }

    final lastActiveAt = user.lastActiveAt;

    if (lastActiveAt == null) {
      return 'Ngoại tuyến';
    }

    final now = DateTime.now();
    final diff = now.difference(lastActiveAt.toLocal());

    if (diff.inMinutes < 1) {
      return 'Vừa hoạt động';
    }

    if (diff.inMinutes < 60) {
      return 'Hoạt động ${diff.inMinutes} phút trước';
    }

    if (diff.inHours < 24) {
      return 'Hoạt động ${diff.inHours} giờ trước';
    }

    if (diff.inDays < 7) {
      return 'Hoạt động ${diff.inDays} ngày trước';
    }

    return 'Hoạt động ${lastActiveAt.day}/${lastActiveAt.month}/${lastActiveAt.year}';
  }

  Widget _buildRoomList(ChatController chat, {required bool isDesktop}) {
    if (chat.isLoadingRooms) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Container(
      color: cardColor,
      child: Column(
        children: [
          if (chat.isNewMessage)
            _buildNewMessageHeader(chat)
          else ...[
            _buildSearchBox(),
            _buildActiveFriendsBar(chat),
          ],

          if (!chat.isNewMessage && chat.roomList.isEmpty)
            Expanded(
              child: _buildEmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Chưa có đoạn chat',
                subtitle: 'Bấm biểu tượng soạn tin để bắt đầu trò chuyện.',
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: chat.roomList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final room = chat.roomList[index];
                  final selected = room.roomId == chat.currentRoomData?.roomId;

                  return _buildRoomTile(
                    chat: chat,
                    room: room,
                    selected: selected,
                    onTap: () {
                      _openRoomFullScreen(chat, room, isDesktop);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewMessageHeader(ChatController chat) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tin nhắn mới',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (chat.listResultByPeopleSearch.isEmpty)
            const Text(
              'Chọn bạn bè để bắt đầu trò chuyện.',
              style: TextStyle(fontSize: 13, color: mutedText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chat.listResultByPeopleSearch.map((e) {
                final u = e['user'];
                return Chip(
                  label: Text(
                    u['fullName'].toString(),
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  deleteIconColor: primaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: primaryColor.withOpacity(0.2)),
                  onDeleted: () => chat.removePeopleResult(u['_id'].toString()),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trên Messenger...',
            hintStyle: TextStyle(color: mutedText),
            prefixIcon: Icon(Icons.search_rounded, color: mutedText),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTile({
    required ChatController chat,
    required ChatRoom room,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final title = _roomTitle(chat, room);
    final avatar = _friendAvatar(chat, room);
    final preview = _lastMessagePreview(chat, room);
    final isOnline = _isFriendOnline(chat, room);

    return Material(
      color: selected ? primaryColor.withOpacity(0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              room.typeRoom == 'group'
                  ? GroupAvatarWidget(
                      members: room.members,
                      currentUserId: chat.currentUser?.id ?? '',
                      size: 42,
                    )
                  : _AvatarWithStatus(
                      imageUrl: avatar,
                      name: title,
                      radius: 24,
                      isOnline: isOnline,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview.isEmpty ? 'Bắt đầu trò chuyện' : preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: preview.isEmpty ? mutedText : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _roomTime(room),
                    style: const TextStyle(
                      fontSize: 11,
                      color: mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selected)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(ChatController chat, {required bool isDesktop}) {
    final room = chat.currentRoomData;

    if (chat.isNewMessage) {
      return _buildNewMessageArea(chat);
    }

    if (room == null) {
      return _buildNoRoomSelected();
    }

    return Container(
      color: bgColor,
      child: Column(
        children: [
          if (isDesktop) _buildDesktopChatHeader(chat, room),
          Expanded(
            child: chat.allMessenger.isEmpty
                ? _buildEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'Chưa có tin nhắn',
                    subtitle: 'Hãy gửi lời chào đầu tiên.',
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    itemCount: chat.allMessenger.length,
                    itemBuilder: (context, index) {
                      final realIndex = chat.allMessenger.length - 1 - index;

                      final msg = chat.allMessenger[realIndex];

                      final previous = realIndex > 0
                          ? chat.allMessenger[realIndex - 1]
                          : null;

                      final next = realIndex < chat.allMessenger.length - 1
                          ? chat.allMessenger[realIndex + 1]
                          : null;

                      final showTime =
                          previous == null ||
                          msg.createdAt
                                  .difference(previous.createdAt)
                                  .inMinutes
                                  .abs() >
                              10;

                      final isLastInGroup =
                          next == null || next.userId != msg.userId;

                      return Column(
                        children: [
                          if (showTime) _buildTimeDivider(msg.createdAt),
                          _buildMessageBubble(
                            chat: chat,
                            msg: msg,
                            showAvatar: isLastInGroup,
                          ),
                        ],
                      );
                    },
                  ),
          ),

          if (chat.isReceiveTyping) _buildTypingIndicator(chat),

          _buildInputBar(chat),
        ],
      ),
    );
  }

  Widget _buildNewMessageArea(ChatController chat) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildNewMessageHeader(chat),

          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: searchController,
              onChanged: chat.searchPeople,
              decoration: const InputDecoration(
                hintText: 'Tìm bạn bè để nhắn tin...',
                hintStyle: TextStyle(color: mutedText),
                prefixIcon: Icon(Icons.search_rounded, color: mutedText),
                border: InputBorder.none,
              ),
            ),
          ),

          Expanded(
            child: chat.listPeopleToNewMessage.isEmpty
                ? _buildEmptyState(
                    icon: Icons.person_search_rounded,
                    title: chat.listResultByPeopleSearch.isEmpty
                        ? 'Tìm người để nhắn'
                        : 'Đã chọn người nhận',
                    subtitle: chat.listResultByPeopleSearch.isEmpty
                        ? 'Gõ tên hoặc username của bạn bè.'
                        : 'Nhập nội dung bên dưới rồi bấm gửi.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: chat.listPeopleToNewMessage.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final e = chat.listPeopleToNewMessage[index];
                      final u = e['user'];

                      final name = u?['fullName']?.toString() ?? 'Người dùng';
                      final avatar = u?['avatar']?.toString();

                      final userId = u?['_id']?.toString();
                      final selected =
                          userId != null &&
                          chat.listResultByPeopleSearch.any(
                            (x) => x['user']?['_id']?.toString() == userId,
                          );

                      return Material(
                        color: selected
                            ? primaryColor.withOpacity(0.08)
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: _AvatarWithStatus(
                            imageUrl: avatar,
                            name: name,
                            radius: 22,
                            isOnline: u?['isOnline'] == true,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            u?['username'] != null
                                ? '@${u['username']}'
                                : 'Bạn bè',
                            style: const TextStyle(color: mutedText),
                          ),
                          trailing: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded,
                            color: primaryColor,
                          ),
                          onTap: () {
                            chat.addPeopleResult(e);
                            searchController.clear();
                          },
                        ),
                      );
                    },
                  ),
          ),

          _buildInputBar(chat),
        ],
      ),
    );
  }

  Widget _buildNoRoomSelected() {
    return Container(
      color: bgColor,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 52,
                color: primaryColor,
              ),
              SizedBox(height: 14),
              Text(
                'Chọn một đoạn chat',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                'Danh sách trò chuyện nằm bên trái. Chọn một người để bắt đầu nhắn tin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: mutedText, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopChatHeader(ChatController chat, ChatRoom room) {
    final title = _roomTitle(chat, room);
    final avatar = _friendAvatar(chat, room);
    final isOnline = chat.receiveUser?.isOnline == true;
    final activityText = _activityText(chat.receiveUser);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          _AvatarWithStatus(
            imageUrl: avatar,
            name: title,
            radius: 22,
            isOnline: room.typeRoom == 'friend' && isOnline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (room.typeRoom == 'friend')
                  Text(
                    activityText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green : mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required ChatController chat,
    required ChatMessage msg,
    required bool showAvatar,
  }) {
    final myId = (chat.currentUser?.id ?? '').trim();
    final senderId = msg.userId.trim();
    final isMe = myId.isNotEmpty && senderId == myId;
    final sender = _resolveSender(chat, msg);

    final bubbleColor = isMe ? primaryColor : cardColor;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: showAvatar ? 10 : 2),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            SizedBox(
              width: 34,
              child: showAvatar
                  ? _AvatarWithStatus(
                      imageUrl: sender?['avatar']?.toString(),
                      name: sender?['fullName']?.toString() ?? '?',
                      radius: 15,
                      isOnline: false,
                    )
                  : const SizedBox(width: 30),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe && chat.isGroup && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      sender?['fullName']?.toString() ?? 'Thành viên',
                      style: const TextStyle(
                        fontSize: 12,
                        color: mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 20),
                    ),
                    border: isMe ? null : Border.all(color: borderColor),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((msg.content ?? '').isNotEmpty)
                        Text(
                          msg.content!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (msg.images.isNotEmpty) ...[
                        if ((msg.content ?? '').isNotEmpty)
                          const SizedBox(height: 8),
                        ...msg.images.map(
                          (img) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                img.url,
                                width: 240,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 240,
                                  height: 160,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Text('Không tải được ảnh'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTimeDivider(DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _formatDateTime(time),
        style: const TextStyle(
          fontSize: 11.5,
          color: mutedText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatController chat) {
    if (textController.text != chat.text) {
      textController.value = TextEditingValue(
        text: chat.text,
        selection: TextSelection.collapsed(offset: chat.text.length),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (chat.pickedImage != null) _buildPickedImagePreview(chat),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CircleIconButton(
                  icon: Icons.photo_camera_outlined,
                  onTap: () async {
                    try {
                      await chat.pickImage();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: textController,
                      onChanged: chat.onMessageTextChanged,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(color: mutedText),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: chat.loading
                      ? null
                      : () async {
                          try {
                            await chat.sendCurrentMessage();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: chat.loading ? Colors.grey.shade300 : primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: chat.loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ChatController chat) {
    final name =
        chat.typingFullName ?? chat.receiveUser?.fullName ?? 'Người dùng';

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(18, 0, 16, 8),
      alignment: Alignment.centerLeft,
      child: Text(
        '$name đang nhập...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12.5,
          color: mutedText,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildPickedImagePreview(ChatController chat) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          color: bgColor,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: kIsWeb
                    ? Image.network(
                        chat.pickedImage!.path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Text('Ảnh')),
                      )
                    : Image.file(
                        File(chat.pickedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Text('Ảnh')),
                      ),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: GestureDetector(
                onTap: chat.removeImage,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFriendOnline(ChatController chat, ChatRoom room) {
    if (room.typeRoom != 'friend') return false;

    final me = chat.currentUser?.id;
    final others = room.members
        .map((e) => e.user)
        .where((u) => u.id != me)
        .toList();

    return others.isNotEmpty && others.first.isOnline;
  }

  String _roomTitle(ChatController chat, ChatRoom room) {
    if (room.typeRoom == 'group') {
      final others = room.members
          .map((e) => e.user)
          .where((u) => u.id != chat.currentUser?.id)
          .toList();

      if (others.isEmpty) return room.title ?? 'Group chat';

      final pick = others.take(3).toList();
      final names = pick.map((u) {
        final parts = u.fullName.trim().split(' ');
        return parts.isNotEmpty ? parts.last : 'TV';
      }).toList();

      final remain = others.length - pick.length;
      return remain > 0 ? '${names.join(', ')} +$remain' : names.join(', ');
    }

    final me = chat.currentUser?.id;
    final other = room.members
        .map((e) => e.user)
        .where((u) => u.id != me)
        .toList();

    if (other.isNotEmpty) return other.first.fullName;
    return chat.receiveUser?.fullName ?? 'Người dùng';
  }

  String? _friendAvatar(ChatController chat, ChatRoom room) {
    final me = chat.currentUser?.id;
    final other = room.members
        .map((e) => e.user)
        .where((u) => u.id != me)
        .toList();

    return other.isNotEmpty ? other.first.avatar : null;
  }

  String _lastMessagePreview(ChatController chat, ChatRoom room) {
    final lastMessage = room.lastMessage;

    if (lastMessage != null) {
      final prefix = lastMessage.sender == chat.currentUser?.id ? 'Bạn: ' : '';

      if (lastMessage.content.trim().isNotEmpty) {
        return '$prefix${lastMessage.content}';
      }

      if (lastMessage.imagesCount > 0) {
        return '${prefix}Đã gửi ${lastMessage.imagesCount} hình ảnh';
      }
    }

    if (room.messages.isEmpty) return '';

    final last = room.messages.last;
    final prefix = last.userId == chat.currentUser?.id ? 'Bạn: ' : '';

    if ((last.content ?? '').isNotEmpty) {
      return '$prefix${last.content}';
    }

    if (last.images.isNotEmpty) {
      return '${prefix}Đã gửi ${last.images.length} hình ảnh';
    }

    return '';
  }

  String _roomTime(ChatRoom room) {
    final rawTime =
        room.lastMessage?.createdAt ??
        (room.messages.isNotEmpty ? room.messages.last.createdAt : null);

    if (rawTime == null) return '';

    final time = rawTime.toLocal();
    final now = DateTime.now();

    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes}p';
    if (diff.inDays < 1) return '${diff.inHours}g';
    if (diff.inDays < 7) return '${diff.inDays}n';

    return '${time.day}/${time.month}';
  }

  String _formatDateTime(DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();

    final sameDay =
        now.day == localTime.day &&
        now.month == localTime.month &&
        now.year == localTime.year;

    final hh = localTime.hour.toString().padLeft(2, '0');
    final mm = localTime.minute.toString().padLeft(2, '0');

    if (sameDay) return '$hh:$mm';

    return '${localTime.day}/${localTime.month} $hh:$mm';
  }

  Map<String, dynamic>? _resolveSender(ChatController chat, ChatMessage msg) {
    if (msg.userId == chat.currentUser?.id) {
      return {
        'fullName': chat.currentUser?.fullName,
        'avatar': chat.currentUser?.avatar,
      };
    }

    if (!chat.isGroup) {
      return {
        'fullName': chat.receiveUser?.fullName,
        'avatar': chat.receiveUser?.avatar,
      };
    }

    final members = chat.currentRoomData?.members ?? [];

    if (members.isEmpty) {
      return {'fullName': 'Thành viên', 'avatar': null};
    }

    final matched = members.where((m) {
      final id = m.userId ?? m.user.id;
      return id == msg.userId;
    }).toList();

    final member = matched.isNotEmpty ? matched.first : members.first;

    return {'fullName': member.user.fullName, 'avatar': member.user.avatar};
  }
}

class _AvatarWithStatus extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isOnline;

  const _AvatarWithStatus({
    required this.imageUrl,
    required this.name,
    required this.radius,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xffE5E7EB),
          backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
          child: !hasImage
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _ChatScreenState.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _ChatScreenState.primaryColor, size: 20),
      ),
    );
  }
}
