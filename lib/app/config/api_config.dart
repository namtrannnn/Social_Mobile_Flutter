import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://172.8.145.53:5000/api/v1';
    }

    // Android emulator
    // return 'http://172.8.145.53:5000/api/v1';
    // return 'http://192.168.100.174:5000/api/v1';
    return 'http://172.8.194.162:5000/api/v1';

    // baseUrl: 'http://192.168.100.174:5000',

    //return 'http://10.0.2.2:3000/api/v1';

    // Nếu chạy điện thoại thật thì đổi thành IP máy tính:
    // return 'http://192.168.1.10:3000/api/v1';
  }
}
