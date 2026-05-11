class ApiService {
  // Nếu chạy app trên Android Emulator:
  static const String baseUrl = "http://172.8.80.134:5000/api/v1";

  // Nếu chạy app trên máy thật thì dùng IP máy tính, ví dụ:
  // static const String baseUrl = "http://192.168.1.5:5000/api/v1";

  static Map<String, String> headers({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}
