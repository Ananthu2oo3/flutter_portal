import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  final String _baseUrl = 'http://localhost:3000/api';

  Future<String> login(String username, String password) async {
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
      return data['status'];
    } else {
      return 'FAILED';
    }
  }
}
