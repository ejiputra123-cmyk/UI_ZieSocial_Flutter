import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['message'] ?? 'Terjadi kesalahan pada server.',
    );
  }

  Future<Map<String, dynamic>> post(
    String url, {
      Map<String, dynamic>? body,
      Map<String, String>? headers,
    }) async {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    }
}