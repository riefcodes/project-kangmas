import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String storageUrl = 'http://localhost:8000/storage';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (kDebugMode) {
      print("API Request Token: ${token != null ? 'Bearer ${token.substring(0, 10)}...' : 'MISSING'}");
    }

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

  static Future<dynamic> multipartPost({
    required String endpoint,
    Map<String, String>? fields,
    XFile? singleFile,
    String singleFileKey = 'file',
    List<XFile>? multiFiles,
    String multiFilesKey = 'files[]',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (singleFile != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          singleFileKey,
          await singleFile.readAsBytes(),
          filename: singleFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(singleFileKey, singleFile.path));
      }
    }

    if (multiFiles != null) {
      for (var file in multiFiles) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            multiFilesKey,
            await file.readAsBytes(),
            filename: file.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(multiFilesKey, file.path));
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  static dynamic _processResponse(http.Response response) {
    final body = response.body;
    if (kDebugMode) {
      print("API Response (${response.statusCode}): $body");
    }

    final decodedBody = jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    } else {
      final message = decodedBody['message'] ?? 'Terjadi kesalahan (${response.statusCode})';

      if (response.statusCode == 401 || (response.statusCode == 403 && message == "Unauthorized")) {
        throw Exception("Sesi Anda telah berakhir atau akses ditolak. Silakan login kembali.");
      }

      throw Exception(message);
    }
  }
}
