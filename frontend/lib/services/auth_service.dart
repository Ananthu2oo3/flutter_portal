import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'http://localhost:3000/api';

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // Save expiry as now + 30 mins (same as backend)
        final expiry = DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch;
        await prefs.setInt('jwt_expiry', expiry);

        return true;
      }
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('jwt_expiry');
  }

  Future<http.Response> getProtectedData(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
