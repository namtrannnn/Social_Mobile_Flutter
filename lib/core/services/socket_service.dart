import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/notification/data/models/notification_model.dart';
import 'dart:async';

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected == true;

  Future<void> connect({required String baseUrl, required String token}) async {
    disconnect();

    final completer = Completer<void>();

    print('=== SOCKET CONNECT START ===');
    print('baseUrl: $baseUrl');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'tokenUser': token})
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
      print('socket id: ${_socket!.id}');
    });

    _socket!.off('SERVER_ONLINE_READY');
    _socket!.on('SERVER_ONLINE_READY', (data) {
      print(' SERVER_ONLINE_READY: $data');

      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onDisconnect((data) {
      print(' Socket disconnected: $data');
    });

    _socket!.onConnectError((data) {
      print(' Socket connect error: $data');

      if (!completer.isCompleted) {
        completer.completeError(data);
      }
    });

    _socket!.onError((data) {
      print(' Socket error: $data');
    });

    _listenNotificationEvents();
    _listenFriendEvents();

    _socket!.connect();

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print(' Socket online ready timeout');
      },
    );
  }

  // =========================
  // NOTIFICATION EVENTS
  // =========================

  void _listenNotificationEvents() {
    _socket?.off('SERVER_NOTIFICATION_NEW');
    _socket?.on('SERVER_NOTIFICATION_NEW', (data) {
      print('SERVER_NOTIFICATION_NEW: $data');

      final notificationJson = data['notification'];

      if (notificationJson != null) {
        final notification = NotificationModel.fromJson(notificationJson);
        onNewNotification?.call(notification);
      }
    });
  }

  void Function(NotificationModel notification)? onNewNotification;

  // =========================
  // FRIEND EVENTS
  // =========================

  void _listenFriendEvents() {
    _socket?.off('SERVER_FRIEND_REQUEST_RECEIVED');
    _socket?.on('SERVER_FRIEND_REQUEST_RECEIVED', (data) {
      print('SERVER_FRIEND_REQUEST_RECEIVED: $data');
      onFriendRequestReceived?.call(data);
    });

    _socket?.off('SERVER_ACCEPT_FRIEND_SUCCESS');
    _socket?.on('SERVER_ACCEPT_FRIEND_SUCCESS', (data) {
      print('SERVER_ACCEPT_FRIEND_SUCCESS: $data');
      onAcceptFriendSuccess?.call(data);
    });
  }

  void Function(dynamic data)? onFriendRequestReceived;
  void Function(dynamic data)? onAcceptFriendSuccess;

  // =========================
  // CHAT EVENTS
  // =========================

  void joinRoom(String roomId) {
    if (!isConnected) {
      print(' Socket chưa connect, không thể join room');
      return;
    }

    print(' CLIENT_JOIN_ROOM: $roomId');
    _socket?.emit('CLIENT_JOIN_ROOM', roomId);
  }

  void sendMessage(Map<String, dynamic> data) {
    if (!isConnected) {
      print(' Socket chưa connect, không thể gửi tin nhắn');
      return;
    }

    print(' CLIENT_SEND_MESSAGE: $data');
    _socket?.emit('CLIENT_SEND_MESSAGE', data);
  }

  void emitTypingStart(String roomChatId) {
    if (!isConnected) {
      print(' Socket chưa connect, không thể gửi typing start');
      return;
    }

    final data = {'room_chat_id': roomChatId};

    print('CLIENT_TYPING_START: $data');
    _socket?.emit('CLIENT_TYPING_START', data);
  }

  void emitTypingStop(String roomChatId) {
    if (!isConnected) {
      print(' Socket chưa connect, không thể gửi typing stop');
      return;
    }

    final data = {'room_chat_id': roomChatId};

    print('CLIENT_TYPING_STOP: $data');
    _socket?.emit('CLIENT_TYPING_STOP', data);
  }

  void listenTypingStart(void Function(dynamic data) callback) {
    _socket?.off('SERVER_TYPING_START');
    _socket?.on('SERVER_TYPING_START', (data) {
      print('⌨SERVER_TYPING_START: $data');
      callback(data);
    });
  }

  void listenTypingStop(void Function(dynamic data) callback) {
    _socket?.off('SERVER_TYPING_STOP');
    _socket?.on('SERVER_TYPING_STOP', (data) {
      print('SERVER_TYPING_STOP: $data');
      callback(data);
    });
  }

  void removeTypingListeners() {
    _socket?.off('SERVER_TYPING_START');
    _socket?.off('SERVER_TYPING_STOP');
  }

  void listenChatMessage(void Function(dynamic data) callback) {
    _socket?.off('SERVER_RETURN_MESSAGE');
    _socket?.on('SERVER_RETURN_MESSAGE', (data) {
      print('SERVER_RETURN_MESSAGE: $data');
      callback(data);
    });
  }

  void removeChatMessageListener() {
    _socket?.off('SERVER_RETURN_MESSAGE');
  }

  void listenChatError(void Function(dynamic data) callback) {
    _socket?.off('SERVER_CHAT_ERROR');
    _socket?.on('SERVER_CHAT_ERROR', (data) {
      print(' SERVER_CHAT_ERROR: $data');
      callback(data);
    });
  }

  void removeChatErrorListener() {
    _socket?.off('SERVER_CHAT_ERROR');
  }

  // =========================
  // ONLINE / OFFLINE EVENTS
  // =========================

  void listenUserOnline(void Function(dynamic data) callback) {
    _socket?.off('SERVER_USER_ONLINE');
    _socket?.on('SERVER_USER_ONLINE', (data) {
      print(' SERVER_USER_ONLINE: $data');
      callback(data);
    });
  }

  void listenUserOffline(void Function(dynamic data) callback) {
    _socket?.off('SERVER_USER_OFFLINE');
    _socket?.on('SERVER_USER_OFFLINE', (data) {
      print('SERVER_USER_OFFLINE: $data');
      callback(data);
    });
  }

  void removeOnlineStatusListeners() {
    _socket?.off('SERVER_USER_ONLINE');
    _socket?.off('SERVER_USER_OFFLINE');
  }

  // =========================
  // DISCONNECT
  // =========================

  void disconnect() {
    if (_socket != null) {
      print('Disconnect socket...');

      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket!.destroy();

      _socket = null;

      print('Socket disposed');
    }
  }
}
