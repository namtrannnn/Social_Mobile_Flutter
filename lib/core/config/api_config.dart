import 'package:flutter/foundation.dart';

class ApiConfig {
  /*
    Chỉ đổi IP ở đây.

    Home:
    static const String _host = '192.168.100.174';

    Trung Nguyen:
    static const String _host = '192.168.110.129';
  */

  static const String _host = '192.168.110.129';
  static const int _port = 5000;

  // URL gốc của server, dùng cho Socket.IO
  static String get serverUrl => 'http://$_host:$_port';

  // URL API, dùng cho các request HTTP
  static String get baseUrl => '$serverUrl/api/v1';

  // URL socket, không có /api/v1
  static String get socketUrl => serverUrl;

  static void printConfig() {
    if (kDebugMode) {
      print('================ API CONFIG ================');
      print('SERVER URL : $serverUrl');
      print('BASE URL   : $baseUrl');
      print('SOCKET URL : $socketUrl');
      print('============================================');
    }
  }
}
