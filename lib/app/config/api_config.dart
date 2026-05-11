import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // return 'http://172.8.80.134:5000/api/v1';
      // return 'http://172.8.145.53:5000/api/v1';
      return 'http://192.168.100.174:5000/api/v1'; //(home)
      // return 'http://192.168.110.137:5000/api/v1'; //(trung nguyen)
    }

    // Android emulator
    return 'http://172.8.83.92:5000/api/v1';
    // return 'http://172.8.145.53:5000/api/v1';
    // return 'http://192.168.100.174:5000/api/v1';
    // return 'http://172.8.194.162:5000/api/v1';
    // return 'http://192.168.100.174:5000/api/v1'; // (home)
    // return 'http://192.168.110.137:5000/api/v1'; //(trung nguyen)
  }
}
