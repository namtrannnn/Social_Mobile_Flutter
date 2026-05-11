import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected == true;

  void connect({required String baseUrl, required String tokenUser}) {
    disconnect();

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .disableAutoConnect()
          .setAuth({'tokenUser': tokenUser})
          .setPath('/socket.io')
          .build(),
    );

    _socket!.onConnect((_) {
      log('✅ Socket connected: ${_socket?.id}');
    });

    _socket!.onConnectError((data) {
      log('❌ Connect error: $data');
    });

    _socket!.onDisconnect((data) {
      log('⚠️ Disconnected: $data');
    });

    _socket!.connect();
  }

  void joinRoom(String roomId) {
    _socket?.emit('CLIENT_JOIN_ROOM', roomId);
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket?.emit('CLIENT_SEND_MESSAGE', data);
  }

  void onServerReturnMessage(void Function(dynamic data) callback) {
    _socket?.off('SERVER_RETURN_MESSAGE');
    _socket?.on('SERVER_RETURN_MESSAGE', callback);
  }

  void removeServerReturnMessage() {
    _socket?.off('SERVER_RETURN_MESSAGE');
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
