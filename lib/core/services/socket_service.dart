import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected == true;

  void connect({required String baseUrl, required String token}) {
    // Nếu đã có socket cũ thì hủy trước
    disconnect();

    print('=== SOCKET CONNECT START ===');
    print('baseUrl: $baseUrl');
    print('token: $token');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // test websocket only trước
          .setPath('/socket.io')
          .setAuth({'tokenUser': token})
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    // Gắn listener TRƯỚC khi connect
    _socket!.onConnect((_) {
      print('✅ Socket connected chat');
      print('socket id: ${_socket!.id}');
    });

    _socket!.onDisconnect((data) {
      print('❌ Socket disconnected: $data');
    });

    _socket!.onConnectError((data) {
      print('❌ Socket connect error: $data');
    });

    _socket!.onError((data) {
      print('❌ Socket error: $data');
    });

    _socket!.onReconnect((_) {
      print('🔁 Socket reconnected');
    });

    _socket!.onReconnectAttempt((data) {
      print('🔁 Reconnect attempt: $data');
    });

    _socket!.on('SERVER_OK', (data) {
      print('✅ SERVER_OK: $data');
    });

    // Cuối cùng mới connect
    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.off('SERVER_OK');
      _socket!.off('connect'); // sửa ở đây
      _socket!.off('disconnect'); // sửa ở đây
      _socket!.off('connect_error');
      _socket!.off('error');

      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  void addFriend(String userId) {
    if (isConnected) {
      _socket!.emit('CLIENT_ADD_FRIEND', userId);
      print('📤 CLIENT_ADD_FRIEND: $userId');
    } else {
      print('⚠️ Socket chưa connect');
    }
  }

  void cancelFriend(String userId) {
    if (isConnected) {
      _socket!.emit('CLIENT_CANCEL_FRIEND', userId);
      print('📤 CLIENT_CANCEL_FRIEND: $userId');
    } else {
      print('⚠️ Socket chưa connect');
    }
  }

  void refuseFriend(String userId) {
    if (isConnected) {
      _socket!.emit('CLIENT_REFUSE_FRIEND', userId);
      print('📤 CLIENT_REFUSE_FRIEND: $userId');
    } else {
      print('⚠️ Socket chưa connect');
    }
  }

  void acceptFriend(String userId) {
    if (isConnected) {
      _socket!.emit('CLIENT_ACCEPT_FRIEND', userId);
      print('📤 CLIENT_ACCEPT_FRIEND: $userId');
    } else {
      print('⚠️ Socket chưa connect');
    }
  }
}
