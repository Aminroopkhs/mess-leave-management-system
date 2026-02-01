import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/config/app_config.dart';

class ApiClient {
  final String baseUrl = AppConfig.backendUrl;

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(url);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Object body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Object body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.delete(url);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null; // e.g. for DELETE that returns no content
    } else {
      throw Exception("API Error ${response.statusCode}: ${response.body}");
    }
  }
}
