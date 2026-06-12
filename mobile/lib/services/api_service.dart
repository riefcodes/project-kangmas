import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // GANTI IP ini sesuai dengan IPv4 laptop Anda (hasil ipconfig)
  // Pastikan port :8000 disertakan jika menggunakan php artisan serve
  static const String baseUrl = 'http://192.168.101.23:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _processResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  static Future<dynamic> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    return _processResponse(response);
  }

  static dynamic _processResponse(http.Response response) {
    final body = response.body;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body);
    } else {
      try {
        final errorData = jsonDecode(body);
        // Jika ada pesan dari server, pakai itu. Jika tidak, pakai status code.
        throw Exception(errorData['message'] ?? 'Error ${response.statusCode}');
      } catch (e) {
        // Jika body bukan JSON (misal HTML error page), tampilkan potongan body-nya untuk debug
        throw Exception('Server error (${response.statusCode}): ${body.length > 100 ? body.substring(0, 100) : body}');
      }
    }
  }
}
