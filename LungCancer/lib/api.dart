import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.161.224.1:5079/api";

  // ----------------- Token -----------------
  static String? _token;

  static String? get token => _token; // token'ı dışarıdan okumak için getter

  // ----------------- Register -----------------
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/Auth/Register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Registration successful"};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data["message"] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  // ----------------- Login -----------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/Auth/Login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return {"success": true, "token": _token};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  // ----------------- Profile -----------------
  static Future<Map<String, dynamic>> getProfile() async {
    if (_token == null) return {"success": false, "message": "Not logged in"};

    final url = Uri.parse("$baseUrl/User/Profile");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 401) {
        return {"success": false, "message": "Unauthorized – token may be invalid"};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data["message"] ?? "Failed to load profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  // ----------------- Upload Prediction -----------------
  static Future<Map<String, dynamic>> uploadPrediction(File file) async {
    if (_token == null) return {"success": false, "message": "Not logged in"};

    final url = Uri.parse("$baseUrl/Prediction/Upload");
    try {
      var request = http.MultipartRequest("POST", url);
      request.files.add(await http.MultipartFile.fromPath("image", file.path));
      request.headers["Authorization"] = "Bearer $_token";

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else if (response.statusCode == 401) {
        return {"success": false, "message": "Unauthorized – token invalid"};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data["message"] ?? "Upload failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Exception: $e"};
    }
  }

  // ----------------- Logout -----------------
  static void logout() {
    _token = null;
  }

  // ----------------- Login Check -----------------
  static bool isLoggedIn() => _token != null;
}
