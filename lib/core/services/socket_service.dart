import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../features/notification/data/models/notification_model.dart';

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected == true;

  void connect({required String baseUrl, required String token}) {
    disconnect();

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
      print('✅ Socket connected');
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

    _socket!.on('SERVER_NOTIFICATION_NEW', (data) {
      print('🔔 SERVER_NOTIFICATION_NEW: $data');

      final notificationJson = data['notification'];

      if (notificationJson != null) {
        final notification = NotificationModel.fromJson(notificationJson);

        onNewNotification?.call(notification);
      }
    });

    _socket!.on('SERVER_FRIEND_REQUEST_RECEIVED', (data) {
      print('👥 SERVER_FRIEND_REQUEST_RECEIVED: $data');
    });

    _socket!.on('SERVER_ACCEPT_FRIEND_SUCCESS', (data) {
      print('✅ SERVER_ACCEPT_FRIEND_SUCCESS: $data');
    });

    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      print('🧹 Disconnect socket...');

      _socket!.clearListeners();

      _socket!.disconnect();

      _socket!.dispose();

      _socket!.destroy();

      _socket = null;

      print('✅ Socket disposed');
    }
  }

  void Function(NotificationModel notification)? onNewNotification;
}
