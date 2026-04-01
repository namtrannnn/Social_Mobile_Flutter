import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/controllers/chat_controller.dart';
import '../../data/models/chat_room.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_user.dart';
import '../widgets/group_avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool _didInitMobileState = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chat = context.read<ChatController>();

      // Không có currentUser thật thì không init chat
      if (chat.currentUser == null || chat.currentUser!.id.trim().isEmpty) {
        chat.currentRoomData = null;
        chat.roomList = [];
        chat.sourceRoomList = [];
        chat.allMessenger = [];
        chat.isNewMessage = false;
        chat.isGroup = false;
        chat.receiveUser = null;
        chat.notifyListeners();
        return;
      }

      await chat.initData(me: chat.currentUser!);

      if (!mounted) return;

      final isDesktop = MediaQuery.of(context).size.width >= 900;
      if (!isDesktop && !_didInitMobileState) {
        _didInitMobileState = true;
        chat.currentRoomData = null;
        chat.isNewMessage = false;
        chat.notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool _isShowingRoomList(ChatController chat, bool isDesktop) {
    if (isDesktop) return false;
    return chat.currentRoomData == null && !chat.isNewMessage;
  }

  void _goBackToRoomList(ChatController chat) {
    chat.currentRoomData = null;
    chat.isNewMessage = false;
    chat.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chat, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && chat.currentRoomData != null) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });

        final isDesktop = MediaQuery.of(context).size.width >= 900;
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
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                !isDesktop && !showingRoomList && chat.currentRoomData != null
                    ? _roomTitle(chat, chat.currentRoomData!)
                    : 'Đoạn chat',
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    chat.openNewMessage();
                    if (!isDesktop) {
                      chat.currentRoomData = null;
                      chat.notifyListeners();
                    }
                  },
                  icon: const Icon(Icons.add_box_outlined),
                ),
              ],
            ),
            body: isDesktop
                ? Row(
                    children: [
                      SizedBox(
                        width: 340,
                        child: _buildRoomList(chat, isDesktop: true),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _buildChatArea(chat, isDesktop: true)),
                    ],
                  )
                : showingRoomList
                ? _buildRoomList(chat, isDesktop: false)
                : _buildChatArea(chat, isDesktop: false),
          ),
        );
      },
    );
  }

  Widget _buildRoomList(ChatController chat, {required bool isDesktop}) {
    return Column(
      children: [
        if (chat.isNewMessage)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff8EABB4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                const Text(
                  'Tin nhắn mới gửi đến:',
                  style: TextStyle(color: Colors.white),
                ),
                ...chat.listResultByPeopleSearch.map((e) {
                  final u = e['user'];
                  return Chip(
                    label: Text(
                      u['fullName'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    deleteIconColor: Colors.white,
                    backgroundColor: Colors.black26,
                    onDeleted: () =>
                        chat.removePeopleResult(u['_id'].toString()),
                  );
                }),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm trên Messenger...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: chat.roomList.length,
            itemBuilder: (context, index) {
              final room = chat.roomList[index];

              return ListTile(
                selected: room.roomId == chat.currentRoomData?.roomId,
                leading: room.typeRoom == 'group'
                    ? GroupAvatarWidget(
                        members: room.members,
                        currentUserId: chat.currentUser?.id ?? '',
                      )
                    : CircleAvatar(
                        backgroundImage: _friendAvatar(chat, room) != null
                            ? NetworkImage(_friendAvatar(chat, room)!)
                            : null,
                        child: _friendAvatar(chat, room) == null
                            ? Text(
                                _roomTitle(chat, room).isNotEmpty
                                    ? _roomTitle(chat, room)[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                title: Text(_roomTitle(chat, room)),
                subtitle: Text(_lastMessagePreview(chat, room)),
                onTap: () {
                  chat.selectRoom(room);

                  if (!isDesktop) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea(ChatController chat, {required bool isDesktop}) {
    final room = chat.currentRoomData;

    if (chat.isNewMessage) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: chat.searchPeople,
              decoration: const InputDecoration(
                hintText: 'Search user...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (chat.listPeopleToNewMessage.isNotEmpty)
            Expanded(
              child: ListView(
                children: chat.listPeopleToNewMessage.map((e) {
                  final u = e['user'];
                  return ListTile(
                    title: Text(u['fullName'].toString()),
                    leading: CircleAvatar(
                      backgroundImage: u['avatar'] != null
                          ? NetworkImage(u['avatar'].toString())
                          : null,
                      child: u['avatar'] == null
                          ? Text(
                              u['fullName'].toString().isNotEmpty
                                  ? u['fullName'].toString()[0].toUpperCase()
                                  : '?',
                            )
                          : null,
                    ),
                    onTap: () => chat.addPeopleResult(e),
                  );
                }).toList(),
              ),
            ),
          _buildInputBar(chat),
        ],
      );
    }

    if (room == null) {
      return Column(
        children: [
          const Expanded(child: Center(child: Text('Chưa có tin nhắn'))),
          _buildInputBar(chat),
        ],
      );
    }

    return Column(
      children: [
        if (isDesktop)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xffdddddd))),
            ),
            child: Row(
              children: [
                if (!chat.isGroup && chat.receiveUser != null)
                  CircleAvatar(
                    backgroundImage: chat.receiveUser!.avatar != null
                        ? NetworkImage(chat.receiveUser!.avatar!)
                        : null,
                    child: chat.receiveUser!.avatar == null
                        ? Text(
                            chat.receiveUser!.fullName.isNotEmpty
                                ? chat.receiveUser!.fullName[0].toUpperCase()
                                : '?',
                          )
                        : null,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _roomTitle(chat, room),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: chat.allMessenger.isEmpty
              ? const Center(child: Text('Chưa có tin nhắn'))
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: chat.allMessenger.length,
                  itemBuilder: (context, index) {
                    final msg = chat.allMessenger[index];
                    final myId = (chat.currentUser?.id ?? '').trim();
                    final senderId = msg.userId.trim();
                    final isMe = myId.isNotEmpty && senderId == myId;
                    final sender = _resolveSender(chat, msg);

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: sender?['avatar'] != null
                                    ? NetworkImage(sender!['avatar'].toString())
                                    : null,
                                child: sender?['avatar'] == null
                                    ? Text(
                                        (sender?['fullName']
                                                    ?.toString()
                                                    .isNotEmpty ??
                                                false)
                                            ? sender!['fullName']
                                                  .toString()[0]
                                                  .toUpperCase()
                                            : '?',
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe && chat.isGroup)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        sender?['fullName']?.toString() ??
                                            'Thành viên',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xff8eabb4)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xffdddddd),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if ((msg.content ?? '').isNotEmpty)
                                          Text(
                                            msg.content!,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        if (msg.images.isNotEmpty) ...[
                                          if ((msg.content ?? '').isNotEmpty)
                                            const SizedBox(height: 8),
                                          ...msg.images.map(
                                            (img) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  img.url,
                                                  height: 220,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                        height: 220,
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                          'Không tải được ảnh',
                                                        ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        _buildInputBar(chat),
      ],
    );
  }

  Widget _buildInputBar(ChatController chat) {
    textController.value = TextEditingValue(
      text: chat.text,
      selection: TextSelection.collapsed(offset: chat.text.length),
    );

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xffdddddd))),
        ),
        child: Column(
          children: [
            if (chat.pickedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          chat.pickedImage!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('Ảnh')),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: chat.removeImage,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    onChanged: (v) {
                      chat.text = v;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    try {
                      await chat.pickImage();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                IconButton(
                  onPressed: chat.loading
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
                  icon: chat.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
