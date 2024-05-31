import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<T>> getJsonList<T>(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Basic $token',
      },
    );

    List<dynamic> list = json.decode(response.body);

    return list.cast();
  }
}
